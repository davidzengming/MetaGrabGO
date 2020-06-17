//
//  ForumDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-22.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Cloudinary

class ForumDataStore: ObservableObject {
    @Environment(\.imageCache) var cache: ImageCache
    @Published var threadsList: [Int]
    @Published var threadDataStores: [Int: ThreadDataStore]
    @Published var isFollowed: Bool
    
    //    private var childThreadSubs = [Int: AnyCancellable]()
    
    @Published var game: Game
    @Published var forumNextPageStartIndex : Int?
    @Published var isLoaded: Bool
    @Published var isLoadingNextPage: Bool = false
    
    let API = APIClient()
    
    init(game: Game, isFollowed: Bool) {
        self.threadsList = []
        self.threadDataStores = [:]
        self.game = game
        self.forumNextPageStartIndex = nil
        self.isLoaded = false
        self.isFollowed = isFollowed
        
        print("created forum for game: " + String(game.id))
    }
    
    deinit {
        print("destroyed forum for game: " + String(game.id))
    }
    
    func insertGameHistory(access: String, gameId: Int) {
        //        if self.myGameVisitHistory.count > 0 && self.myGameVisitHistory[0] == gameId {
        //            return
        //        }
        //
        let params = ["game_id": String(gameId)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.insertGameHistoryByUserId, params: params)
        let request = API.generateRequest(url: url!, method: .POST)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                var newGameHistoryArr : [Int] = [gameId]
                let maxGameHistoryLimit = 10
                
                print("Updated game history - (Backend only, no states updated)")
            }
        }.resume()
    }
    
    func followGame(access: String, gameId: Int) {
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.followGameByGameId, detail: String(gameId))
        let request = API.generateRequest(url: url!, method: .POST)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.isFollowed = true
                    self.game.followerCount += 1
                }
            }
        }.resume()
    }
    
    func unfollowGame(access: String, gameId: Int) {
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.unfollowGameByGameId, detail: String(gameId))
        let request = API.generateRequest(url: url!, method: .POST)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.isFollowed = false
                    self.game.followerCount -= 1
                }
            }
        }.resume()
    }
    
    func fetchThreads(access: String, start:Int = 0, count:Int = 10, refresh: Bool = false, userId: Int, containerWidth: CGFloat) {
        if self.isLoadingNextPage == true {
            return
        }
        
        DispatchQueue.main.async {
            if refresh == true {
                self.threadDataStores = [:]
                self.threadsList = []
                self.forumNextPageStartIndex = nil
            }
        }
        
        if start != 0 {
            self.isLoadingNextPage = true
        }
        
        let params = ["start": String(start), "count": String(count), "game": String(game.id)]
        let url = API.generateURL(resource: Resource.threads, endPoint: EndPoint.getThreadsByGameId, params: params)
        let request = API.generateRequest(url: url!, method: .GET)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    
                    let tempThreadsResponse: ThreadsResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    
                    if tempThreadsResponse.threadsResponse.count == 0 && self.forumNextPageStartIndex == nil {
                        DispatchQueue.main.async {
                            self.forumNextPageStartIndex = -1
                            self.isLoaded = true
                        }
                        return
                    }
                    
                    var newThreadsList: [Int] = []
                    for thread in tempThreadsResponse.threadsResponse {
                        if self.threadDataStores[thread.id] != nil {
                            continue
                        }
                        
                        newThreadsList.append(thread.id)
                        
                        var myVote: Vote? = nil
                        if thread.votes.count > 0 {
                            myVote = thread.votes[0]
                        }
                        
                        let author = thread.users[0]
                        
                        
                        let threadDataStore = ThreadDataStore(gameId: self.game.id, thread: thread, vote: myVote, author: author, cache: self.cache, emojiArr: thread.emojis!.emojisIdArr, emojiReactionCount: thread.emojis!.emojiReactionCountDict, userArrPerEmoji: thread.emojis!.userArrPerEmojiDict, didReactToEmojiDict: thread.emojis!.didReactToEmojiDict, containerWidth: containerWidth)
                        
                        DispatchQueue.main.async {
                            self.threadDataStores[thread.id] = threadDataStore
                        }
                        
                        //                            self.childThreadSubs[thread.id] = self.threadDataStores[thread.id]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
                        //                            })
                    }
                    
                    DispatchQueue.main.async {
                        self.threadsList += newThreadsList
                        
                        if tempThreadsResponse.hasNextPage == true {
                            self.forumNextPageStartIndex = start + count
                        } else {
                            self.forumNextPageStartIndex = -1
                        }
                        
                        if start == 0 {
                            self.isLoaded = true
                        } else {
                            self.isLoadingNextPage = false
                        }
                    }
                }
            }
        }.resume()
    }
    
    func submitThread(forumDataStore: ForumDataStore, access: String, title: String, flair: Int, content: NSTextStorage, imageData: [UUID: Data], imagesArray: [UUID], userId:
        Int, containerWidth: CGFloat) {
        
        let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: "dzengcdn", apiKey: "348513889264333", secure: true))
        let taskGroup = DispatchGroup()
        
        var imageUrls : [String] = []
        
        if imagesArray.count != 0 {
            for id in imagesArray {
                if imageData[id] == nil {
                    continue
                }
                
                taskGroup.enter()
                let preprocessChain = CLDImagePreprocessChain()
                    .addStep(CLDPreprocessHelpers.limit(width: 500, height: 500))
                    .addStep(CLDPreprocessHelpers.dimensionsValidator(minWidth: 10, maxWidth: 500, minHeight: 10, maxHeight: 500))
                _ = cloudinary.createUploader().upload(data: imageData[id]!, uploadPreset: "cyr1nlwn", preprocessChain: preprocessChain)
                    .response({response, error in
                        if error == nil {
                            imageUrls.append(response!.secureUrl!)
                            taskGroup.leave()
                        }
                    })
            }
        }
        
        taskGroup.notify(queue: DispatchQueue.global()) {
            let params = ["game_id": String(forumDataStore.game.id)]
            let json: [String: Any] = ["title": title, "content_string": content.string, "content_attributes": ["attributes": TextViewHelper.parseTextStorageAttributesAsBitRep(content: content)], "flair": flair, "image_urls": ["urls": imageUrls]]
            
            let url = self.API.generateURL(resource: Resource.threads, endPoint: EndPoint.postThreadByGameId, params: params)
            let request = self.API.generateRequest(url: url!, method: .POST, json: json)
            let session = self.API.generateSession(access: access)
            
            session.dataTask(with: request) {(data, response, error) in
                if let data = data {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        let tempNewThreadResponse: NewThreadResponse = load(jsonData: jsonString.data(using: .utf8)!)
                        let tempThread = tempNewThreadResponse.threadResponse
                        let vote = tempNewThreadResponse.voteResponse
                        
                        DispatchQueue.main.async {
                            self.threadDataStores[tempThread.id] = ThreadDataStore(gameId: forumDataStore.game.id, thread: tempThread, vote: vote, author: tempThread.users[0], cache: self.cache, emojiArr: tempThread.emojis!.emojisIdArr, emojiReactionCount: tempThread.emojis!.emojiReactionCountDict, userArrPerEmoji: tempThread.emojis!.userArrPerEmojiDict, didReactToEmojiDict: tempThread.emojis!.didReactToEmojiDict, containerWidth: containerWidth)
                            
                            //                            self.childThreadSubs[tempThread.id] = self.threadDataStores[tempThread.id]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
                            //                            })
                            //
                            self.threadsList.insert(tempThread.id, at: 0)
                            self.game.threadCount += 1
                        }
                    }
                }
            }.resume()
        }
    }
}

var attributesEncodingCache: [Int: Any] = [:]
func generateTextStorageFromJson(contentString: String, contentAttributes: Attributes) -> NSTextStorage {
    let generatedTextStorage = NSTextStorage(string: contentString)
    
    for attribute in contentAttributes.attributes {
        let encode = attribute[0]
        let location = attribute[1]
        let length = attribute[2]
        
        if attributesEncodingCache[encode] != nil {
            generatedTextStorage.addAttributes(attributesEncodingCache[encode] as! [NSAttributedString.Key : Any], range: NSMakeRange(location, length))
        } else {
            let attributesToBeApplied = TextViewHelper.generateAttributesFromEncoding(encode: encode)
            generatedTextStorage.addAttributes(attributesToBeApplied, range: NSMakeRange(location, length))
            attributesEncodingCache[encode] = attributesToBeApplied
        }
    }
    return generatedTextStorage
}

class ThreadDataStore: ObservableObject {
    @Published var childCommentList: [Int]
    @Published var childComments: [Int: CommentDataStore]
    @Published var relativeDateString: String?
    @Published var desiredHeight: CGFloat
    @Published var textStorage: NSTextStorage
    
    @Published var imageLoaders: [Int: ImageLoader] = [:]
    @Published var imageArr: [Int] = []
    @Published var isHidden: Bool = false
    
    @Published var threadNextPageStartIndex: Int?
    
    //    private var childCommentSubs = [Int: AnyCancellable]()
    private var imageLoaderSubs = [Int: AnyCancellable]()
    
    @ObservedObject var emojis: EmojiDataStore
    private var emojisSub: AnyCancellable?
    
    @Published var areCommentsLoaded: Bool = false
    @Published var isLoadingNextPage: Bool = false
    
    var threadImagesHeight: CGFloat = 0
    var cache: ImageCache
    var gameId: Int
    var thread: Thread
    var vote: Vote?
    var author: User
    
    let API = APIClient()
    
    init(gameId: Int, thread: Thread, vote: Vote?, author: User, cache: ImageCache, emojiArr: [Int], emojiReactionCount: [Int: Int], userArrPerEmoji: [Int: [User]], didReactToEmojiDict: [Int: Bool], containerWidth: CGFloat) {
        self.relativeDateString = RelativeDateTimeFormatter().localizedString(for: thread.created, relativeTo: Date())
        let textStorage = generateTextStorageFromJson(contentString: thread.contentString, contentAttributes: thread.contentAttributes)
        
        self.textStorage = textStorage
        self.desiredHeight = textStorage.height(containerWidth: containerWidth)
        self.gameId = gameId
        self.thread = thread
        self.vote = vote
        self.author = author
        
        self.childCommentList = []
        self.childComments = [:]
        
        self.cache = cache
        self.emojis = EmojiDataStore(serializedEmojiArr: emojiArr, emojiReactionCount: emojiReactionCount, userArrPerEmoji: userArrPerEmoji, didReactToEmojiDict: didReactToEmojiDict)
        self.emojisSub = emojis.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
        })
        
        self.mountImages()
        self.loadImages()
    }
    
    func mountImages() {
        for (index, imageUrl) in thread.imageUrls.urls.enumerated() {
            imageLoaders[index] = ImageLoader(url: imageUrl, cache: cache, whereIsThisFrom: "thread: " + String(self.thread.id) + " image: " + String(index), loadManually: true)
            self.imageLoaderSubs[index] = imageLoaders[index]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
            imageArr.append(index)
        }
    }
    
    func loadImages() {
        let taskGroup = DispatchGroup()
        
        for index in imageArr {
            imageLoaders[index]!.load(dispatchGroup: taskGroup)
        }
        
        // need to add on server side remember image size
        //        taskGroup.notify(queue: .global()) {
        //            var maxHeight: CGFloat = 0
        //            for index in self.imageArr {
        //                maxHeight = max(maxHeight, self.imageLoaders[index]!.imageHeight!)
        //            }
        //
        //            self.threadImagesHeight = maxHeight
        //        }
    }
    
    func upvoteByExistingVoteId(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.upvoteByExistingVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.thread.upvotes += 1
                    self.vote!.direction = 1
                    self.emojis.addEmojiToStore(emojiId: 0, user: user, newEmojiCount: self.thread.upvotes)
                    self.emojis.isLoading = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func downvoteByExistingVoteId(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.downvoteByVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.thread.downvotes += 1
                    self.vote!.direction = -1
                    self.emojis.addEmojiToStore(emojiId: 1, user: user, newEmojiCount: self.thread.downvotes)
                    self.emojis.isLoading = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func addNewUpvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewUpvoteByThreadId)
        let json: [String: Any] = ["thread_id": thread.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let newVote: Vote = load(jsonData: jsonString.data(using: .utf8)!)
                    DispatchQueue.main.async {
                        self.vote = newVote
                        self.thread.upvotes += 1
                        self.emojis.addEmojiToStore(emojiId: 0, user: user, newEmojiCount: self.thread.upvotes)
                        self.emojis.isLoading = false
                        taskGroup?.leave()
                    }
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func switchUpvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchUpvoteByThreadId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.vote!.direction = 1
                    self.thread.upvotes += 1
                    self.thread.downvotes -= 1
                    
                    self.emojis.removeEmojiFromStore(emojiId: 1, user: user, newEmojiCount: self.thread.downvotes)
                    self.emojis.addEmojiToStore(emojiId: 0, user: user, newEmojiCount: self.thread.upvotes)
                    self.emojis.isLoading = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func addNewDownvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewDownvoteByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let newVote: Vote = load(jsonData: jsonString.data(using: .utf8)!)
                    DispatchQueue.main.async {
                        self.vote = newVote
                        self.thread.downvotes += 1
                        self.emojis.addEmojiToStore(emojiId: 1, user: user, newEmojiCount: self.thread.downvotes)
                        self.emojis.isLoading = false
                        taskGroup?.leave()
                    }
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func switchDownvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchDownvoteByThreadId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.vote!.direction = -1
                    self.thread.upvotes -= 1
                    self.thread.downvotes += 1
                    
                    self.emojis.removeEmojiFromStore(emojiId: 0, user: user, newEmojiCount: self.thread.upvotes)
                    self.emojis.addEmojiToStore(emojiId: 1, user: user, newEmojiCount: self.thread.downvotes)
                    self.emojis.isLoading = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func addEmojiByThreadId(access: String, emojiId: Int, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.emojis, endPoint: EndPoint.addEmojiByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id, "emoji_id": emojiId]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let emojiResponse: EmojiResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    if emojiResponse.isSuccess == false {
                        self.emojis.isLoading = false
                        return
                    }
                    
                    self.emojis.addEmojiToStore(emojiId: emojiId, user: user, newEmojiCount: emojiResponse.newEmojiCount)
                    self.emojis.isLoading = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func removeEmojiByThreadId(access: String, emojiId: Int, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        let url = self.API.generateURL(resource: Resource.emojis, endPoint: EndPoint.removeEmojiByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id, "emoji_id": emojiId]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let emojiResponse: EmojiResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    if emojiResponse.isSuccess == false {
                        self.emojis.isLoading = false
                        return
                    }
                    
                    self.emojis.removeEmojiFromStore(emojiId: emojiId, user: user, newEmojiCount: emojiResponse.newEmojiCount)
                    self.emojis.isLoading = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func deleteVote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.emojis.isLoading == true {
                print("Already operating an emoji, abort.")
                return
            }
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.deleteVoteByVoteIdThread)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if self.vote!.direction == 1 {
                        self.thread.upvotes -= 1
                    } else {
                        self.thread.downvotes -= 1
                    }
                    
                    let originalVoteDirection = self.vote!.direction
                    self.vote!.direction = 0
                    
                    print(self.emojis)
                    
                    self.emojis.removeEmojiFromStore(emojiId: originalVoteDirection == 1 ? 0 : 1, user: user, newEmojiCount: originalVoteDirection == 1 ? self.thread.upvotes : self.thread.downvotes)
                    
                    print(self.emojis)
                    self.emojis.isLoading = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func sendReportByThreadId(access: String, reason: String, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        let url = self.API.generateURL(resource: Resource.reports, endPoint: EndPoint.addReportByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id, "report_reason": reason]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Report has been sent for thread: ", self.thread.id)
                taskGroup?.leave()
                return
            }
        }.resume()
    }
    
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
                self.isHidden = true
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
                self.isHidden = false
            }
        }.resume()
    }
    
    func postMainComment(access: String, content: NSTextStorage, containerWidth: CGFloat) {
        let params = ["thread_id": String(self.thread.id)]
        let url = API.generateURL(resource: Resource.comments, endPoint: EndPoint.postCommentByThreadId, params: params)
        let json: [String: Any] = ["content_string": content.string, "content_attributes": ["attributes": TextViewHelper.parseTextStorageAttributesAsBitRep(content: content)]]
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let tempNewCommentResponse: NewCommentResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    let tempMainComment = tempNewCommentResponse.commentResponse
                    let tempVote = tempNewCommentResponse.voteResponse
                    let user = tempNewCommentResponse.userResponse
                    
                    let commentDataStore = CommentDataStore(ancestorThreadId: self.thread.id, gameId: self.gameId, comment: tempMainComment, vote: tempVote, author: user, containerWidth: containerWidth)
                    
                    DispatchQueue.main.async {
                        self.childComments[tempMainComment.id] = commentDataStore
                        self.childCommentList.insert(tempMainComment.id, at: 0)
                    }
                }
            }
        }.resume()
    }
    
    func fetchCommentTreeByThreadId(access: String, start:Int = 0, count:Int = 10, size:Int = 50, refresh: Bool = false, userId: Int, containerWidth: CGFloat, leadPadding: CGFloat) {
        
        //        if refresh == true {
        //            self.childCommentSubs = [:]
        
        //            DispatchQueue.main.async {
        //                self.areCommentsLoaded = false
        //                self.childCommentList = []
        //            }
        //        }
        
        if start != 0 {
            DispatchQueue.main.async {
                self.isLoadingNextPage = true
            }
        }
        
        let params = ["parent_thread_id": String(self.thread.id), "start": String(start), "count": String(count), "size": String(size)]
        let url = API.generateURL(resource: Resource.comments, endPoint: EndPoint.getCommentTreeByThreadId, params: params)
        let request = API.generateRequest(url: url!, method: .GET)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let serializedComments: CommentsResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    if serializedComments.commentsResponse.count == 0 {
                        DispatchQueue.main.async {
                            //                            self.threadNextPageStartIndex = -1
                            self.areCommentsLoaded = true
                        }
                        return
                    }
                    
                    var levelArr = [Int]()
                    var levelStore = [Int: CommentDataStore]()
                    
                    var nextLevelArr = [Int]()
                    var nextLevelStore = [Int: CommentDataStore]()
                    
                    var levelCount = 0
                    var i = 0
                    var j = 0
                    
                    var x = 0 // level pointer
                    
                    var firstLevelArr = [Int]()
                    var firstLevelStore = [Int: CommentDataStore]()
                    
                    while i < serializedComments.commentsResponse.count {
                        // end of level
                        while j < serializedComments.commentBreaksArr.count && serializedComments.commentBreaksArr[j] < i {
                            if levelCount == 0 {
                                firstLevelArr = nextLevelArr
                                firstLevelStore = nextLevelStore
                                
                                levelArr = nextLevelArr
                                levelStore = nextLevelStore
                                
                                nextLevelArr = []
                                nextLevelStore = [:]
                                
                                levelCount += 1
                            } else {
                                x += 1
                                if x >= levelArr.count {
                                    levelArr = nextLevelArr
                                    levelStore = nextLevelStore
                                    
                                    nextLevelArr = []
                                    nextLevelStore = [:]
                                    
                                    x = 0
                                    levelCount += 1
                                }
                            }
                            j += 1
                        }
                        
                        let commentId = serializedComments.commentsResponse[i].id
                        nextLevelArr.append(commentId)
                        
                        var vote: Vote?
                        if serializedComments.commentsResponse[i].votes.count > 0 {
                            vote = serializedComments.commentsResponse[i].votes[0]
                        }
                        
                        let commentDataStore = CommentDataStore(ancestorThreadId: self.thread.id, gameId: self.gameId, comment:  serializedComments.commentsResponse[i], vote: vote, author: serializedComments.commentsResponse[i].users[0], containerWidth: containerWidth - leadPadding * CGFloat(levelCount))
                        
                        nextLevelStore[commentId] = commentDataStore
                        
                        if levelCount > 0 {
                            let parentCommentId = levelArr[x]
                            
                            levelStore[parentCommentId]!.childCommentList.append(commentId)
                            levelStore[parentCommentId]!.childComments[commentId] = nextLevelStore[commentId]
                            //                            levelStore[parentCommentId]!.childCommentSubs[commentId] = nextLevelStore[commentId]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
                            //                            })
                        }
                        
                        i += 1
                    }
                    
                    if levelCount == 0 {
                        firstLevelArr = nextLevelArr
                        firstLevelStore = nextLevelStore
                    }
                    
                    for commentId in firstLevelArr {
                        //                            self.childCommentSubs[commentId] = firstLevelStore[commentId]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
                        //                            })
                        DispatchQueue.main.async {
                            self.childComments[commentId] = firstLevelStore[commentId]!
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.childCommentList += firstLevelArr
                        
                        if start == 0 {
                            self.areCommentsLoaded = true
                        }
                        
                        if start != 0 {
                            self.isLoadingNextPage = false
                        }
                    }
                }
            }
        }.resume()
    }
}

class CommentDataStore: ObservableObject {
    @Published var childCommentList: [Int]
    @Published var childComments: [Int: CommentDataStore]
    @Published var relativeDateString: String?
    @Published var textStorage: NSTextStorage
    @Published var isHidden: Bool = false
    @Published var desiredHeight: CGFloat
    
    @Published var isLoadingNextPage: Bool = false
    
    @Published var comment: Comment
    @Published var vote: Vote?
    
    @Published var isVoting: Bool = false
    
    var ancestorThreadId: Int
    var gameId: Int
    var author: User
    let API = APIClient()
    
    init(ancestorThreadId: Int, gameId: Int, comment: Comment, vote: Vote?, author: User, containerWidth: CGFloat) {
        
        self.ancestorThreadId = ancestorThreadId
        self.gameId = gameId
        self.comment = comment
        self.vote = vote
        self.author = author
        
        self.relativeDateString = RelativeDateTimeFormatter().localizedString(for: comment.created, relativeTo: Date())
        
        let generatedTextStorage = generateTextStorageFromJson(contentString: comment.contentString, contentAttributes: comment.contentAttributes)
        self.textStorage = generatedTextStorage
        self.desiredHeight = generatedTextStorage.height(containerWidth: containerWidth)
        
        self.childCommentList = []
        self.childComments = [:]
    }
    
    func upvoteByExistingVoteId(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        
        DispatchQueue.main.async {
            if self.isVoting == true {
                print("Already operating a vote, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.upvoteByExistingVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.comment.upvotes += 1
                    self.vote!.direction = 1
                    self.isVoting = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func downvoteByExistingVoteId(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        
        DispatchQueue.main.async {
            if self.isVoting == true {
                print("Already operating a vote, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.downvoteByVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.comment.downvotes += 1
                    self.vote!.direction = -1
                    self.isVoting = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func addNewUpvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.isVoting == true {
                print("Already operating a vote, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewUpvoteByCommentId)
        let json: [String: Any] = ["comment_id": comment.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let newVote: Vote = load(jsonData: jsonString.data(using: .utf8)!)
                    DispatchQueue.main.async {
                        self.vote = newVote
                        self.comment.upvotes += 1
                        self.isVoting = false
                        taskGroup?.leave()
                    }
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func switchUpvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.isVoting == true {
                print("Already operating a vote, abort.")
                return
            }
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchUpvoteByCommentId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.vote!.direction = 1
                    self.comment.upvotes += 1
                    self.comment.downvotes -= 1
                    
                    self.isVoting = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func addNewDownvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.isVoting == true {
                print("Already operating a vote, abort.")
                return
            }
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewDownvoteByCommentId)
        let json: [String: Any] = ["comment_id": self.comment.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let newVote: Vote = load(jsonData: jsonString.data(using: .utf8)!)
                    DispatchQueue.main.async {
                        self.vote = newVote
                        self.comment.downvotes += 1
                        self.isVoting = false
                        taskGroup?.leave()
                    }
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func switchDownvote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.isVoting == true {
                print("Already operating a vote, abort.")
                return
            }
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchDownvoteByCommentId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.vote!.direction = -1
                    self.comment.upvotes -= 1
                    self.comment.downvotes += 1
                    self.isVoting = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func deleteVote(access: String, user: User, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        DispatchQueue.main.async {
            if self.isVoting == true {
                print("Already operating a vote, abort.")
                return
            }
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.deleteVoteByVoteIdComment)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    
                    if self.vote!.direction == 1 {
                        self.comment.upvotes -= 1
                    } else {
                        self.comment.downvotes -= 1
                    }
                    
                    self.vote!.direction = 0
                    self.isVoting = false
                    taskGroup?.leave()
                }
            } else {
                taskGroup?.leave()
            }
        }.resume()
    }
    
    func sendReportByCommentId(access: String, reason: String, taskGroup: DispatchGroup? = nil) {
        taskGroup?.enter()
        let url = self.API.generateURL(resource: Resource.reports, endPoint: EndPoint.addReportByCommentId)
        let json: [String: Any] = ["comment_id": self.comment.id, "report_reason": reason]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        let session = self.API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("Report has been sent for thread: ", self.comment.id)
                taskGroup?.leave()
                return
            }
        }.resume()
    }
    
    func hideComment(access: String) {
        let json: [String: Any] = ["hide_comment_id": self.comment.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.isHidden = true
            }
        }.resume()
    }
    
    func unhideComment(access: String) {
        let json: [String: Any] = ["unhide_thread_id": self.comment.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                return
            }
            
            DispatchQueue.main.async {
                self.isHidden = false
            }
        }.resume()
    }
    
    func fetchCommentTreeByCommentId(access: String, start:Int = 0, count:Int = 10, size:Int = 50, refresh: Bool = false, userId: Int, containerWidth: CGFloat, leadPadding: CGFloat) {
        
        DispatchQueue.main.async {
            self.isLoadingNextPage = true
        }
        
        //        if refresh == true {
        //            //            self.childCommentSubs = [:]
        //
        //            DispatchQueue.main.async {
        //                self.childCommentList = []
        //            }
        //        }
        
        let params = ["parent_comment_id": String(self.comment.id), "start": String(start), "count": String(count), "size": String(size)]
        let url = API.generateURL(resource: Resource.comments, endPoint: EndPoint.getCommentTreeByCommentId, params: params)
        let request = API.generateRequest(url: url!, method: .GET)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let serializedComments: CommentsResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    var levelArr = [Int]()
                    var levelStore = [Int: CommentDataStore]()
                    
                    var nextLevelArr = [Int]()
                    var nextLevelStore = [Int: CommentDataStore]()
                    
                    var levelCount = 0
                    var i = 0
                    var j = 0
                    
                    var x = 0 // level pointer
                    
                    var firstLevelArr = [Int]()
                    var firstLevelStore = [Int: CommentDataStore]()
                    
                    while i < serializedComments.commentsResponse.count {
                        // end of level
                        while j < serializedComments.commentBreaksArr.count && serializedComments.commentBreaksArr[j] < i {
                            if levelCount == 0 {
                                firstLevelArr = nextLevelArr
                                firstLevelStore = nextLevelStore
                                
                                levelArr = nextLevelArr
                                levelStore = nextLevelStore
                                
                                nextLevelArr = []
                                nextLevelStore = [:]
                                
                                levelCount += 1
                            } else {
                                x += 1
                                if x >= levelArr.count {
                                    levelArr = nextLevelArr
                                    levelStore = nextLevelStore
                                    
                                    nextLevelArr = []
                                    nextLevelStore = [:]
                                    
                                    x = 0
                                    levelCount += 1
                                }
                            }
                            j += 1
                        }
                        
                        let commentId = serializedComments.commentsResponse[i].id
                        nextLevelArr.append(commentId)
                        
                        var vote: Vote?
                        if serializedComments.commentsResponse[i].votes.count > 0 {
                            vote = serializedComments.commentsResponse[i].votes[0]
                        }
                        
                        nextLevelStore[commentId] = CommentDataStore(ancestorThreadId: self.ancestorThreadId, gameId: self.gameId, comment:  serializedComments.commentsResponse[i], vote: vote, author: serializedComments.commentsResponse[i].users[0], containerWidth: containerWidth - leadPadding * CGFloat(levelCount))
                        
                        if levelCount > 0 {
                            let parentCommentId = levelArr[x]
                            
                            levelStore[parentCommentId]!.childCommentList.append(commentId)
                            levelStore[parentCommentId]!.childComments[commentId] = nextLevelStore[commentId]
                            //                                    levelStore[parentCommentId]!.childCommentSubs[commentId] = nextLevelStore[commentId]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
                            //                                    })
                        }
                        
                        i += 1
                    }
                    
                    if levelCount == 0 {
                        firstLevelArr = nextLevelArr
                        firstLevelStore = nextLevelStore
                    }
                    
                    for commentId in firstLevelArr {
                        //                            self.childCommentSubs[commentId] = firstLevelStore[commentId]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
                        //                            })
                        
                        DispatchQueue.main.async {
                            self.childComments[commentId] = firstLevelStore[commentId]!
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.childCommentList += firstLevelArr
                        self.isLoadingNextPage = false
                    }
                }
            }
        }.resume()
    }
    
    func postChildComment(access: String, content: NSTextStorage, containerWidth: CGFloat) {
        let params = ["parent_comment_id": String(self.comment.id)]
        let url = API.generateURL(resource: Resource.comments, endPoint: EndPoint.postCommentByParentCommentId, params: params)
        let json: [String: Any] = ["content_string": content.string, "content_attributes": ["attributes": TextViewHelper.parseTextStorageAttributesAsBitRep(content: content)]]
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let tempNewCommentResponse: NewCommentResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    let tempChildComment = tempNewCommentResponse.commentResponse
                    let tempVote = tempNewCommentResponse.voteResponse
                    let user = tempNewCommentResponse.userResponse
                    
                    let commentDataStore = CommentDataStore(ancestorThreadId: self.ancestorThreadId, gameId: self.gameId, comment: tempChildComment, vote: tempVote, author: user, containerWidth: containerWidth)
                    
                    DispatchQueue.main.async {
                        self.childComments[tempChildComment.id] = commentDataStore
                        self.childCommentList.insert(tempChildComment.id, at: 0)
                    }
                }
            }
        }.resume()
    }
}
