//
//  BlockHiddenDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-21.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

class BlockHiddenDataStore: ObservableObject {
    @Published var hiddenThreadIdArr = [Int]()
    @Published var hiddenCommentIdArr = [Int]()
    @Published var blacklistedUsersById = [Int: User]()
    @Published var hiddenThreadsById = [Int: HiddenThread]()
    @Published var hiddenCommentsById = [Int: HiddenComment]()
    @Published var isUserBlockedByUserId = [Int: Bool]()
    @Published var isThreadHiddenByThreadId = [Int: Bool]()
    @Published var isCommentHiddenByCommentId = [Int: Bool]()
    @Published var blacklistedUserIdArr = [Int]()
    
    let API = APIClient()
    
    func hideThread(threadId: Int, userDataStore: UserDataStore) {
        let json: [String: Any] = ["hide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)

        API.sessionHandler(request: request, userDataStore: userDataStore) { _ in
            DispatchQueue.main.async {
                self.hiddenThreadIdArr.append(threadId)
                self.isThreadHiddenByThreadId[threadId] = true
            }
        }
    }
    
    func unhideThread(threadId: Int, userDataStore: UserDataStore) {
        let json: [String: Any] = ["unhide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { _ in
            DispatchQueue.main.async {
                let itemToRemoveIndex = self.hiddenThreadIdArr.firstIndex(of: threadId)
                self.hiddenThreadIdArr.remove(at: itemToRemoveIndex!)
                self.hiddenThreadsById.removeValue(forKey: threadId)
                self.isThreadHiddenByThreadId[threadId] = false
            }
        }
    }
    
    func hideComment(commentId: Int, userDataStore: UserDataStore) {
        let json: [String: Any] = ["hide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)

        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            DispatchQueue.main.async {
                self.hiddenCommentIdArr.append(commentId)
                self.isCommentHiddenByCommentId[commentId] = true
            }
        }
    }
    
    func unhideComment(commentId: Int, userDataStore: UserDataStore) {
        let json: [String: Any] = ["unhide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { _ in
            DispatchQueue.main.async {
                let itemToRemoveIndex = self.hiddenCommentIdArr.firstIndex(of: commentId)
                self.hiddenCommentIdArr.remove(at: itemToRemoveIndex!)
                self.hiddenCommentsById.removeValue(forKey: commentId)
                self.isCommentHiddenByCommentId[commentId] = false
            }
        }
    }
    
    func blockUser(targetBlockUser: User, taskGroup: DispatchGroup? = nil, userDataStore: UserDataStore) {
        let json: [String: Any] = ["blacklist_user_id": targetBlockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.blockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)

        API.sessionHandler(request: request, userDataStore: userDataStore) { _ in
            DispatchQueue.main.async {
                self.blacklistedUsersById[targetBlockUser.id] = targetBlockUser
                self.blacklistedUserIdArr.append(targetBlockUser.id)
            }
        }
    }
    
    func unblockUser(targetUnblockUser: User, taskGroup: DispatchGroup? = nil, userDataStore: UserDataStore) {
        let json: [String: Any] = ["unblacklist_user_id": targetUnblockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unblockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)

        API.sessionHandler(request: request, userDataStore: userDataStore) { _ in
            DispatchQueue.main.async {
                let indexToBeRemoved = self.blacklistedUserIdArr.firstIndex(of: targetUnblockUser.id)
                self.blacklistedUserIdArr.remove(at: indexToBeRemoved!)
                self.blacklistedUsersById.removeValue(forKey: targetUnblockUser.id)
            }
        }
    }
    
    func fetchBlacklistedUsers(userId: Int, userDataStore: UserDataStore) {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getBlacklist)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)

        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let blacklistedUsersResponse: BlacklistedUsersResponse = load(jsonData: jsonString.data(using: .utf8)!)
                
                DispatchQueue.main.async {
                    for blacklistedUser in blacklistedUsersResponse.blacklistedUsers {
                        if self.isUserBlockedByUserId[blacklistedUser.id] != nil && self.isUserBlockedByUserId[blacklistedUser.id]! == true {
                            continue
                        }
                        self.isUserBlockedByUserId[blacklistedUser.id] = true
                        self.blacklistedUsersById[blacklistedUser.id] = blacklistedUser
                        self.blacklistedUserIdArr.append(blacklistedUser.id)
                    }
                }
            }
        }
    }
    
    func fetchHiddenThreads(userId: Int, userDataStore: UserDataStore) {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenThreads)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let hiddenThreadsResponse: HiddenThreadsResponse = load(jsonData: jsonString.data(using: .utf8)!)
                
                DispatchQueue.main.async {
                    for hiddenThread in hiddenThreadsResponse.hiddenThreads {
                        if self.isThreadHiddenByThreadId[hiddenThread.id] != nil && self.isThreadHiddenByThreadId[hiddenThread.id]! == true {
                            continue
                        }
                        
                        self.hiddenThreadIdArr.append(hiddenThread.id)
                        self.hiddenThreadsById[hiddenThread.id] = hiddenThread
                        self.isThreadHiddenByThreadId[hiddenThread.id] = true
                    }
                }
            }
        }
    }
    
    func fetchHiddenComments(userId: Int, userDataStore: UserDataStore) {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenComments)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)

        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let hiddenCommentsResponse: HiddenCommentsResponse = load(jsonData: jsonString.data(using: .utf8)!)
                
                DispatchQueue.main.async {
                    for hiddenComment in hiddenCommentsResponse.hiddenComments {
                        if self.isCommentHiddenByCommentId[hiddenComment.id] != nil && self.isCommentHiddenByCommentId[hiddenComment.id]! == true {
                            continue
                        }
                        self.hiddenCommentIdArr.append(hiddenComment.id)
                        self.hiddenCommentsById[hiddenComment.id] = hiddenComment
                        self.isCommentHiddenByCommentId[hiddenComment.id] = true
                    }
                }
            }
        }
    }
}
