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

    private var threadProcess: AnyCancellable?
    private var commentProcess: AnyCancellable?
    private var blockUserProcess: AnyCancellable?
    
    @Published private(set) var isLoadingThreads = false
    @Published private(set) var isLoadingComments = false
    @Published private(set) var isLoadingBlockUsers = false
    
    deinit {
        cancelThreadProcess()
        cancelCommentProcess()
        cancelBlockUserProcess()
    }
    
    func cancelThreadProcess() {
        self.threadProcess?.cancel()
        self.threadProcess = nil
    }
    
    func cancelCommentProcess() {
        self.commentProcess?.cancel()
        self.commentProcess = nil
    }
    
    func cancelBlockUserProcess() {
        self.blockUserProcess?.cancel()
        self.blockUserProcess = nil
    }
    
    func hideThread(threadId: Int) {
        if threadProcess != nil {
            return
        }
        
        let json: [String: Any] = ["hide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)

        API.accessTokenRefreshHandler(request: request)
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.threadProcess = session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.hiddenThreadIdArr.append(threadId)
                    self.isThreadHiddenByThreadId[threadId] = true
                    processingRequestsTaskGroup.leave()
                    self.cancelThreadProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelThreadProcess()
                    break
                }
            }, receiveValue: { _ in
            })
        }
    }
    
    func unhideThread(threadId: Int) {
        if threadProcess != nil {
            return
        }
        
        let json: [String: Any] = ["unhide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.threadProcess = session.dataTaskPublisher(for: request)
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
                    self.cancelThreadProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelThreadProcess()
                    break
                }
            }, receiveValue: { _ in
            })
        }
    }
    
    func hideComment(commentId: Int) {
        if commentProcess != nil {
            return
        }
        
        let json: [String: Any] = ["hide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.commentProcess = session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.hiddenCommentIdArr.append(commentId)
                    self.isCommentHiddenByCommentId[commentId] = true
                    processingRequestsTaskGroup.leave()
                    self.cancelCommentProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelCommentProcess()
                    break
                }
            }, receiveValue: { _ in
            })
        }
    }
    
    func unhideComment(commentId: Int) {
        if commentProcess != nil {
            return
        }
        
        let json: [String: Any] = ["unhide_comment_id": commentId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.commentProcess = session.dataTaskPublisher(for: request)
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
                    self.cancelCommentProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelCommentProcess()
                    break
                }
            }, receiveValue: { _ in
            })
        }
    }
    
    func blockUser(targetBlockUser: User, taskGroup: DispatchGroup? = nil) {
        if blockUserProcess != nil {
            return
        }
        
        let json: [String: Any] = ["blacklist_user_id": targetBlockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.blockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.blockUserProcess = session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.blacklistedUsersById[targetBlockUser.id] = targetBlockUser
                    self.blacklistedUserIdArr.append(targetBlockUser.id)
                    processingRequestsTaskGroup.leave()
                    self.cancelBlockUserProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelBlockUserProcess()
                    break
                }
            }, receiveValue: { _ in
            })
        }
    }
    
    func unblockUser(targetUnblockUser: User, taskGroup: DispatchGroup? = nil) {
        if self.blockUserProcess != nil {
            return
        }
        
        let json: [String: Any] = ["unblacklist_user_id": targetUnblockUser.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unblockUser)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.blockUserProcess = session.dataTaskPublisher(for: request)
            .map(\.data)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    let indexToBeRemoved = self.blacklistedUserIdArr.firstIndex(of: targetUnblockUser.id)
                    self.blacklistedUserIdArr.remove(at: indexToBeRemoved!)
                    self.blacklistedUsersById.removeValue(forKey: targetUnblockUser.id)
                    processingRequestsTaskGroup.leave()
                    self.cancelBlockUserProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelBlockUserProcess()
                    break
                }
            }, receiveValue: { _ in
            })
        }
    }
    
    func fetchBlacklistedUsers() {
        if self.blockUserProcess != nil {
            return
        }
        
        self.isLoadingBlockUsers = true
        
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getBlacklist)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.blockUserProcess = session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: BlacklistedUsersResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    self.cancelBlockUserProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelBlockUserProcess()
                    break
                }
                self.isLoadingBlockUsers = false
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
        }
    }
    
    func fetchHiddenThreads() {
        if self.threadProcess != nil {
            return
        }
        
        self.isLoadingThreads = true
        
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenThreads)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.threadProcess = session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: HiddenThreadsResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    self.cancelThreadProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelThreadProcess()
                    break
                }
                self.isLoadingThreads = false
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
        }
    }
    
    func fetchHiddenComments() {
        if self.commentProcess != nil {
            return
        }
        
        self.isLoadingComments = true
        
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.getHiddenComments)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.commentProcess = session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: HiddenCommentsResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    self.cancelCommentProcess()
                    break
                case .failure(let error):
                    #if DEBUG
                    print("error: ", error)
                    #endif
                    processingRequestsTaskGroup.leave()
                    self.cancelCommentProcess()
                    break
                }
                self.isLoadingComments = false
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
        }
    }
}
