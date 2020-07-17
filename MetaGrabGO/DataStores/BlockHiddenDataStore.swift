//
//  BlockHiddenDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-21.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import Combine

final class BlockHiddenDataStore: ObservableObject {
    @Published private(set) var hiddenThreadIdArr = [Int]()
    @Published private(set) var hiddenCommentIdArr = [Int]()
    @Published private(set) var blacklistedUsersById = [Int: User]()
    @Published private(set) var hiddenThreadsById = [Int: HiddenThread]()
    @Published private(set) var hiddenCommentsById = [Int: HiddenComment]()
    @Published private(set) var isUserBlockedByUserId = [Int: Bool]()
    @Published private(set) var isThreadHiddenByThreadId = [Int: Bool]()
    @Published private(set) var isCommentHiddenByCommentId = [Int: Bool]()
    @Published private(set) var blacklistedUserIdArr = [Int]()
    
    private let API = APIClient()
    private var cancellableSet: Set<AnyCancellable> = []
    
    func hideThread(threadId: Int) {
        let json: [String: Any] = ["hide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)

        API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()

        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.hiddenThreadIdArr.append(threadId)
                    self.isThreadHiddenByThreadId[threadId] = true
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { _ in
                print("done") })
            .store(in: &self.cancellableSet)
        }
    }
    
    func unhideThread(threadId: Int) {
        let json: [String: Any] = ["unhide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()

        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    let itemToRemoveIndex = self.hiddenThreadIdArr.firstIndex(of: threadId)
                    self.hiddenThreadIdArr.remove(at: itemToRemoveIndex!)
                    self.hiddenThreadsById.removeValue(forKey: threadId)
                    self.isThreadHiddenByThreadId[threadId] = false
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { _ in
                print("done") })
            .store(in: &self.cancellableSet)
        }
    }
    
    func hideComment(commentId: Int) {
        let json: [String: Any] = ["hide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.hiddenCommentIdArr.append(commentId)
                    self.isCommentHiddenByCommentId[commentId] = true
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { _ in
                print("done") })
            .store(in: &self.cancellableSet)
        }
    }
    
    func unhideComment(commentId: Int) {
        let json: [String: Any] = ["unhide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    let itemToRemoveIndex = self.hiddenCommentIdArr.firstIndex(of: commentId)
                    self.hiddenCommentIdArr.remove(at: itemToRemoveIndex!)
                    self.hiddenCommentsById.removeValue(forKey: commentId)
                    self.isCommentHiddenByCommentId[commentId] = false
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { _ in
                print("done") })
            .store(in: &self.cancellableSet)
        }
    }
    
    func blockUser(targetBlockUser: User, taskGroup: DispatchGroup? = nil) {
        let json: [String: Any] = ["blacklist_user_id": targetBlockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.blockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.blacklistedUsersById[targetBlockUser.id] = targetBlockUser
                    self.blacklistedUserIdArr.append(targetBlockUser.id)
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { _ in
                print("done") })
            .store(in: &self.cancellableSet)
        }
    }
    
    func unblockUser(targetUnblockUser: User, taskGroup: DispatchGroup? = nil) {
        let json: [String: Any] = ["unblacklist_user_id": targetUnblockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unblockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    let indexToBeRemoved = self.blacklistedUserIdArr.firstIndex(of: targetUnblockUser.id)
                    self.blacklistedUserIdArr.remove(at: indexToBeRemoved!)
                    self.blacklistedUsersById.removeValue(forKey: targetUnblockUser.id)
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { _ in
                print("done") })
            .store(in: &self.cancellableSet)
        }
    }
    
    func fetchBlacklistedUsers() {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getBlacklist)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: BlacklistedUsersResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { [unowned self] blacklistedUsersResponse in
               for blacklistedUser in blacklistedUsersResponse.blacklistedUsers {
                   if self.isUserBlockedByUserId[blacklistedUser.id] != nil && self.isUserBlockedByUserId[blacklistedUser.id]! == true {
                       continue
                   }
                   self.isUserBlockedByUserId[blacklistedUser.id] = true
                   self.blacklistedUsersById[blacklistedUser.id] = blacklistedUser
                   self.blacklistedUserIdArr.append(blacklistedUser.id)
               }
            })
            .store(in: &self.cancellableSet)
        }
    }
    
    func fetchHiddenThreads() {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenThreads)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: HiddenThreadsResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { [unowned self] hiddenThreadsResponse in
               for hiddenThread in hiddenThreadsResponse.hiddenThreads {
                   if self.isThreadHiddenByThreadId[hiddenThread.id] != nil && self.isThreadHiddenByThreadId[hiddenThread.id]! == true {
                       continue
                   }
                   
                   self.hiddenThreadIdArr.append(hiddenThread.id)
                   self.hiddenThreadsById[hiddenThread.id] = hiddenThread
                   self.isThreadHiddenByThreadId[hiddenThread.id] = true
               }
            })
            .store(in: &self.cancellableSet)
        }
    }
    
    func fetchHiddenComments() {
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenComments)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: HiddenCommentsResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { [unowned self] hiddenCommentsResponse in
               for hiddenComment in hiddenCommentsResponse.hiddenComments {
                   if self.isCommentHiddenByCommentId[hiddenComment.id] != nil && self.isCommentHiddenByCommentId[hiddenComment.id]! == true {
                       continue
                   }
                   self.hiddenCommentIdArr.append(hiddenComment.id)
                   self.hiddenCommentsById[hiddenComment.id] = hiddenComment
                   self.isCommentHiddenByCommentId[hiddenComment.id] = true
               }
            })
            .store(in: &self.cancellableSet)
        }
    }
}
