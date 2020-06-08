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
    
    func hideThread(access: String, threadId: Int) {
        let json: [String: Any] = ["hide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.hiddenThreadIdArr.append(threadId)
                self.isThreadHiddenByThreadId[threadId] = true
            }
        }.resume()
    }
    
    func unhideThread(access: String, threadId: Int) {
        let json: [String: Any] = ["unhide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                let itemToRemoveIndex = self.hiddenThreadIdArr.firstIndex(of: threadId)
                self.hiddenThreadIdArr.remove(at: itemToRemoveIndex!)
                self.hiddenThreadsById.removeValue(forKey: threadId)
                self.isThreadHiddenByThreadId[threadId] = false
            }
        }.resume()
    }
    
    func hideComment(access: String, commentId: Int) {
        let json: [String: Any] = ["hide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.hiddenCommentIdArr.append(commentId)
                self.isCommentHiddenByCommentId[commentId] = true
            }
        }.resume()
    }
    
    func unhideComment(access: String, commentId: Int) {
        let json: [String: Any] = ["unhide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                let itemToRemoveIndex = self.hiddenCommentIdArr.firstIndex(of: commentId)
                self.hiddenCommentIdArr.remove(at: itemToRemoveIndex!)
                self.hiddenCommentsById.removeValue(forKey: commentId)
                self.isCommentHiddenByCommentId[commentId] = false
            }
        }.resume()
    }
    
    func blockUser(access: String, targetBlockUser: User, taskGroup: DispatchGroup? = nil) {
        let json: [String: Any] = ["blacklist_user_id": targetBlockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.blockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) {(data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.blacklistedUsersById[targetBlockUser.id] = targetBlockUser
                self.blacklistedUserIdArr.append(targetBlockUser.id)
            }
        }.resume()
    }
    
    func unblockUser(access: String, targetUnblockUser: User, taskGroup: DispatchGroup? = nil) {
        let json: [String: Any] = ["unblacklist_user_id": targetUnblockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unblockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) {(data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                let indexToBeRemoved = self.blacklistedUserIdArr.firstIndex(of: targetUnblockUser.id)
                self.blacklistedUserIdArr.remove(at: indexToBeRemoved!)
                self.blacklistedUsersById.removeValue(forKey: targetUnblockUser.id)
            }
        }.resume()
    }
    
    func fetchBlacklistedUsers(access: String, userId: Int) {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getBlacklist)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
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
        }.resume()
    }
    
    func fetchHiddenThreads(access: String, userId: Int) {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenThreads)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
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
        }.resume()
    }
    
    func fetchHiddenComments(access: String, userId: Int) {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenComments)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
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
        }.resume()
    }
}
