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

class ForumOtherDataStore: ObservableObject {
    private(set) var gameId: Int
    var forumNextPageStartIndex: Int?
    @Published var isLoadingNextPage: Bool = false
    @Published var isFollowed: Bool?
    @Published var threadCount: Int?
    @Published var followerCount: Int?
    
    private let API = APIClient()
    
    private var forumStatsLoadingProcess: AnyCancellable?
    private var followLoadingProcess: AnyCancellable?
    
    init(gameId: Int) {
        self.gameId = gameId
        self.forumNextPageStartIndex = nil
        self.isFollowed = nil
        self.threadCount = nil
        self.followerCount = nil
        
        self.fetchForumStats()
    }
    
    deinit {
        self.cancelForumStatsLoadingProcess()
        self.cancelFollowLoadingProcess()
    }
    
    func cancelForumStatsLoadingProcess() {
        self.forumStatsLoadingProcess?.cancel()
        self.forumStatsLoadingProcess = nil
    }
    
    func cancelFollowLoadingProcess() {
        self.followLoadingProcess?.cancel()
        self.followLoadingProcess = nil
    }
    
    func fetchForumStats() {
        let params = ["game_id": String(self.gameId)]
        let url = API.generateURL(resource: Resource.forums, endPoint: EndPoint.getForumStats, params: params)
        let request = API.generateRequest(url: url!, method: .GET)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.forumStatsLoadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: ForumStatsResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelForumStatsLoadingProcess()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        break
                    }
                    processingRequestsTaskGroup.leave()
                    
                }, receiveValue: { [unowned self] tempForumStatsResponse in
                    self.isFollowed = tempForumStatsResponse.isFollowed
                    self.threadCount = tempForumStatsResponse.threadCount
                    self.followerCount = tempForumStatsResponse.followerCount
                })
        }
    }
    
    func followGame(gameId: Int) {
        if self.followLoadingProcess != nil {
            return
        }
        
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.followGameByGameId, detail: String(gameId))
        let request = API.generateRequest(url: url!, method: .POST)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.followLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isFollowed = true
                        self.followerCount! += 1
                        self.cancelFollowLoadingProcess()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        break
                    }
                    processingRequestsTaskGroup.leave()
                }, receiveValue: { _ in
                })
        }
    }
    
    func unfollowGame(gameId: Int) {
        if self.followLoadingProcess != nil {
            return
        }
        
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.unfollowGameByGameId, detail: String(gameId))
        let request = API.generateRequest(url: url!, method: .POST)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.followLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isFollowed = false
                        self.followerCount! -= 1
                        self.cancelFollowLoadingProcess()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        break
                    }
                    processingRequestsTaskGroup.leave()
                }, receiveValue: { _ in
                })
        }
    }
}

class ForumDataStore: ObservableObject {
    @Published var threadsList: [Int]?
    
    var threadDataStores: [Int: ThreadDataStore]
    var game: Game
    
    let API = APIClient()
    private var cancellableSet: Set<AnyCancellable> = []
    private var loadingProcess: AnyCancellable?
    private var submitThreadProcess: AnyCancellable?
    
    init(game: Game) {
        self.threadsList = nil
        self.threadDataStores = [:]
        self.game = game
        //        print("created forum for game: " + String(game.id))
    }
    
    deinit {
        cancelLoadingProcess()
        cancellableSet.forEach { $0.cancel() }
        cancellableSet = []
    }
    
    func cancelLoadingProcess() {
        loadingProcess?.cancel()
        loadingProcess = nil
    }
    
    func cancelSubmitThreadProcess() {
        submitThreadProcess?.cancel()
        submitThreadProcess = nil
    }
    
    func insertGameHistory() {
        let gameId = self.game.id
        //        if self.myGameVisitHistory.count > 0 && self.myGameVisitHistory[0] == gameId {
        //            return
        //        }
        //
        let params = ["game_id": String(gameId)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.insertGameHistoryByUserId, params: params)
        let request = API.generateRequest(url: url!, method: .POST)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        #if DEBUG
                        print("success - added to game history")
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                })
                .store(in: &self.cancellableSet)
        }
    }
    
    func fetchThreads(start:Int = 0, count:Int = 10, refresh: Bool = false, containerWidth: CGFloat, forumOtherDataStore: ForumOtherDataStore, maxImageHeight: CGFloat) {
        if forumOtherDataStore.isLoadingNextPage == true {
            return
        }
        
        DispatchQueue.main.async {
            if refresh == true {
                self.threadDataStores = [:]
                self.threadsList = nil
                forumOtherDataStore.forumNextPageStartIndex = nil
            }
        }
        
        if start != 0 {
            forumOtherDataStore.isLoadingNextPage = true
        }
        
        let params = ["start": String(start), "count": String(count), "game": String(game.id)]
        let url = API.generateURL(resource: Resource.threads, endPoint: EndPoint.getThreadsByGameId, params: params)
        let request = API.generateRequest(url: url!, method: .GET)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.loadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: ThreadsResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelLoadingProcess()
                        forumOtherDataStore.isLoadingNextPage = false
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] tempThreadsResponse in
                    if tempThreadsResponse.threadsResponse.count == 0 && forumOtherDataStore.forumNextPageStartIndex == nil {
                        self.threadsList = []
                        forumOtherDataStore.forumNextPageStartIndex = -1
                        return
                    }
                    
                    var newThreadsList = [Int]()
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

                        let threadDataStore = ThreadDataStore(gameId: self.game.id, thread: thread, vote: myVote, author: author, emojiArr: thread.emojis!.emojisIdArr, emojiReactionCount: thread.emojis!.emojiReactionCountDict, userArrPerEmoji: thread.emojis!.userArrPerEmojiDict, didReactToEmojiDict: thread.emojis!.didReactToEmojiDict, containerWidth: containerWidth, maxImageHeight: maxImageHeight)
                        
                        self.threadDataStores[thread.id] = threadDataStore
                    }
                    
                    if tempThreadsResponse.hasNextPage == true {
                        forumOtherDataStore.forumNextPageStartIndex = start + count
                    } else {
                        forumOtherDataStore.forumNextPageStartIndex = -1
                    }
                    
                    if newThreadsList.count == 0 {
                        return
                    }
                    
                    if self.threadsList != nil {
                        self.threadsList! += newThreadsList
                    } else {
                        self.threadsList = newThreadsList
                    }
                })
        }
    }
    
    func submitThread(forumDataStore: ForumDataStore, title: String, flair: Int, content: NSTextStorage, imageData: [UUID: Data], imagesArray: [UUID], userId:
        Int, containerWidth: CGFloat, forumOtherDataStore: ForumOtherDataStore, maxImageHeight: CGFloat) {
        
        if self.submitThreadProcess != nil {
            return
        }
        
        let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: "dzengcdn", apiKey: "348513889264333", secure: true))
        let taskGroup = DispatchGroup()
        var imageUrls: [String] = []
        var imageWidths: [String] = []
        var imageHeights: [String] = []
        
        if imagesArray.count != 0 {
            for id in imagesArray {
                if imageData[id] == nil {
                    continue
                }
                
                taskGroup.enter()
                let preprocessChain = CLDImagePreprocessChain()
                    .addStep(CLDPreprocessHelpers.limit(width: 800, height: 800))
                    .addStep(CLDPreprocessHelpers.dimensionsValidator(minWidth: 10, maxWidth: 800, minHeight: 10, maxHeight: 800))
                _ = cloudinary.createUploader().upload(data: imageData[id]!, uploadPreset: "cyr1nlwn", preprocessChain: preprocessChain)
                    .response({response, error in
                        if error == nil {
                            imageUrls.append(response!.secureUrl!)
                            imageWidths.append(String(response!.width!))
                            imageHeights.append(String(response!.height!))
                            taskGroup.leave()
                        }
                    })
            }
        }
        
        taskGroup.notify(queue: DispatchQueue.global()) {
            let params = ["game_id": String(forumDataStore.game.id)]
            let json: [String: Any] = ["title": title, "content_string": content.string, "content_attributes": ["attributes": TextViewHelper.parseTextStorageAttributesAsBitRep(content: content)], "flair": flair, "image_urls": ["urls": imageUrls], "image_widths": ["widths": imageWidths], "image_heights": ["heights": imageHeights]]
            
            let url = self.API.generateURL(resource: Resource.threads, endPoint: EndPoint.postThreadByGameId, params: params)
            let request = self.API.generateRequest(url: url!, method: .POST, json: json)
            
            self.API.accessTokenRefreshHandler(request: request)
            
            refreshingRequestTaskGroup.notify(queue: .global()) {
                let session = self.API.generateSession()
                processingRequestsTaskGroup.enter()
                self.submitThreadProcess = session.dataTaskPublisher(for: request)
                    .map(\.data)
                    .decode(type: NewThreadResponse.self, decoder: self.API.getJSONDecoder())
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            self.cancelSubmitThreadProcess()
                            processingRequestsTaskGroup.leave()
                            break
                        case .failure(let error):
                            self.cancelSubmitThreadProcess()
                            #if DEBUG
                            print("error: ", error)
                            #endif
                            processingRequestsTaskGroup.leave()
                            break
                        }
                    }, receiveValue: { [unowned self] tempNewThreadResponse in
                        let tempThread = tempNewThreadResponse.threadResponse
                        let vote = tempNewThreadResponse.voteResponse
                        
                        DispatchQueue.main.async {
                            self.threadDataStores[tempThread.id] = ThreadDataStore(gameId: forumDataStore.game.id, thread: tempThread, vote: vote, author: tempThread.users[0], emojiArr: tempThread.emojis!.emojisIdArr, emojiReactionCount: tempThread.emojis!.emojiReactionCountDict, userArrPerEmoji: tempThread.emojis!.userArrPerEmojiDict, didReactToEmojiDict: tempThread.emojis!.didReactToEmojiDict, containerWidth: containerWidth, maxImageHeight: maxImageHeight)
                            
                            //                            self.childThreadSubs[tempThread.id] = self.threadDataStores[tempThread.id]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
                            //                            })
                            //
                            self.threadsList!.insert(tempThread.id, at: 0)
                            forumOtherDataStore.threadCount! += 1
                        }
                    })
            }
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

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

class ThreadDataStore: ObservableObject {
    @Published private(set) var childCommentList: [Int]?
    private(set) var childComments: [Int: CommentDataStore]
    var desiredHeight: CGFloat
    var textStorage: NSTextStorage
    
    private(set) var imageLoaders: [Int: ImageLoader] = [:]
    private var imageLoaderSubs = [Int: AnyCancellable]()
    
    @Published private(set) var imageArr: [Int] = []
    @Published private(set) var isHidden: Bool = false
    @ObservedObject private(set) var emojis: EmojiDataStore
    private var emojisSub: AnyCancellable?
    
    @Published var hasNextPage: Bool = true
    @Published private(set) var isLoadingNextPage: Bool = false
    @Environment(\.imageCache) private var cache: ImageCache
    
    private(set) var gameId: Int
    private(set) var thread: Thread
    private(set) var vote: Vote?
    private(set) var author: User
    private(set) var relativeDateString: String?
    
    private let API = APIClient()
    private var cancellableSet: Set<AnyCancellable> = []
    private var loadingProcess: AnyCancellable?
    
    private var emojiLoadingProcess: AnyCancellable?
    private var submitCommentProcess: AnyCancellable?
    private var hideProcess: AnyCancellable?
    private var sendReportProcess: AnyCancellable?
    
    private(set) var containerWidth: CGFloat
    private var spacingBetweenImages: CGFloat = 10
    private(set) var maxImageHeight: CGFloat = 0
    private(set) var imageDimensions: [(width: CGFloat, height: CGFloat)] = []
    
    private(set) var authorProfileImageLoader: ImageLoader?
    private var authorProfileImageLoaderSub: AnyCancellable?
    
    init(gameId: Int, thread: Thread, vote: Vote?, author: User, emojiArr: [Int], emojiReactionCount: [Int: Int], userArrPerEmoji: [Int: [User]], didReactToEmojiDict: [Int: Bool], containerWidth: CGFloat, maxImageHeight: CGFloat) {
        
        let currDate = Date()
        if currDate.timeIntervalSince1970 - thread.created.timeIntervalSince1970 <= 30 {
            self.relativeDateString = "just now"
        } else if currDate.timeIntervalSince1970 - thread.created.timeIntervalSince1970 > 172800 { // longer 2 days
            let components = thread.created.get(.day, .month)
            self.relativeDateString = String(format: "%02d", components.month!) + "-" + String(format: "%02d", components.day!)
        } else {
            self.relativeDateString = RelativeDateTimeFormatter().localizedString(for: thread.created, relativeTo: currDate)
        }
        
        let textStorage = generateTextStorageFromJson(contentString: thread.contentString, contentAttributes: thread.contentAttributes)
        
        self.textStorage = textStorage
        self.containerWidth = containerWidth
        self.desiredHeight = textStorage.height(containerWidth: containerWidth)
        self.gameId = gameId
        self.thread = thread
        self.vote = vote
        self.author = author
        
        self.childCommentList = nil
        self.childComments = [:]
        
        self.emojis = EmojiDataStore(serializedEmojiArr: emojiArr, emojiReactionCount: emojiReactionCount, userArrPerEmoji: userArrPerEmoji, didReactToEmojiDict: didReactToEmojiDict)
        self.emojisSub = emojis.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send()
        })
        
        self.calculateImagesDimensions(imageWidths: thread.imageWidths, imageHeights: thread.imageHeights, maxImageHeightLimit: maxImageHeight)

        self.mountImages()
        self.mountAuthorProfileImage()
        //        self.loadImages()
    }
    
    deinit {
        cancelLoadingProcess()
        cancellableSet.forEach { $0.cancel() }
        cancellableSet = []
        
        self.cancelSubmitCommentProcess()
        self.cancelEmojiLoadingProcess()
        self.cancelHideProcess()
        self.cancelReportProcess()
    }
    
    func cancelSubmitCommentProcess() {
        self.submitCommentProcess?.cancel()
        self.submitCommentProcess = nil
    }
    
    func cancelEmojiLoadingProcess() {
        self.emojiLoadingProcess?.cancel()
        self.emojiLoadingProcess = nil
    }
    
    func cancelHideProcess() {
        self.hideProcess?.cancel()
        self.hideProcess = nil
    }
    
    func cancelReportProcess() {
        self.sendReportProcess?.cancel()
        self.sendReportProcess = nil
    }
    
    func calculateImagesDimensions(imageWidths: ImageWidths, imageHeights: ImageHeights, maxImageHeightLimit: CGFloat) {
        var dimensions: [(width: CGFloat, height: CGFloat)] = []
        var maximumHeight: CGFloat = 0
        var totalScaledWidth: CGFloat = 0
        let numImages = imageWidths.widths.count
        
        for i in 0..<numImages {
            let cgHeight = CGFloat(truncating: NumberFormatter().number(from: imageHeights.heights[i])!)
            let scaleDownHeight = min(cgHeight, maxImageHeightLimit)
            
            let overHeightScaleDownFactor = scaleDownHeight / cgHeight
            let scaledWidth = overHeightScaleDownFactor * CGFloat(truncating: NumberFormatter().number(from: imageWidths.widths[i])!)
            
            totalScaledWidth += scaledWidth
            dimensions.append((scaledWidth, scaleDownHeight))
            maximumHeight = max(maximumHeight, cgHeight)
        }
        
        let availableWidth = self.containerWidth - CGFloat(numImages) * spacingBetweenImages
        
        var scaleFactorDueToWidthConstraint: CGFloat = 1
        if availableWidth < totalScaledWidth {
            scaleFactorDueToWidthConstraint = availableWidth / totalScaledWidth
        }
        
        for i in 0..<numImages {
            dimensions[i].width *= scaleFactorDueToWidthConstraint
            dimensions[i].height *= scaleFactorDueToWidthConstraint
            
            self.maxImageHeight = max(self.maxImageHeight, dimensions[i].height)
        }
        
        self.imageDimensions = dimensions
        return
    }
    
    func cancelLoadingProcess() {
        loadingProcess?.cancel()
        loadingProcess = nil
    }
    
    func addCommentToChildList(commentDataStore: CommentDataStore) {
        if self.childComments[commentDataStore.comment.id] == nil {
            self.childCommentList!.append(commentDataStore.comment.id)
            self.childComments[commentDataStore.comment.id] = commentDataStore
        }
    }
    
    func mountImages() {
        for (index, imageUrl) in thread.imageUrls.urls.enumerated() {
            imageLoaders[index] = ImageLoader(url: imageUrl, cache: cache, whereIsThisFrom: "thread: " + String(self.thread.id) + " image: " + String(index), loadManually: true)
            self.imageLoaderSubs[index] = imageLoaders[index]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
            imageArr.append(index)
        }
    }
    
    func mountAuthorProfileImage() {
        if author.profileImageUrl != "" {
            self.authorProfileImageLoader = ImageLoader(url: author.profileImageUrl, cache: cache, whereIsThisFrom: "thread image loader", loadManually: true)
            self.authorProfileImageLoaderSub = authorProfileImageLoader!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
        } else {
            print("no profile picture to mount")
        }
    }
    
    //    func getCopyDataStore() -> ThreadDataStore {
    //        var emojiArr: [Int] = []
    //
    //        for row in self.emojis.emojiArr {
    //            for emoji in row {
    //                if emoji == 999 {
    //                    continue
    //                }
    //                emojiArr.append(emoji)
    //            }
    //        }
    //
    //        let detailThreadDataStore = ThreadDataStore(gameId: self.gameId, thread: self.thread, vote: self.vote, author: self.author, emojiArr: emojiArr, emojiReactionCount: self.emojis.emojiCount, userArrPerEmoji: self.emojis.usersArrReactToEmoji, didReactToEmojiDict: self.emojis.didReactToEmoji, containerWidth: self.containerWidth)
    //
    //        self.threadDetailDataStore = detailThreadDataStore
    //        return self.threadDetailDataStore!
    //    }
    
    func loadImages() {
        for index in imageArr {
            imageLoaders[index]!.load()
        }
    }
    
    func upvoteByExistingVoteId() {
        if self.emojiLoadingProcess != nil {
            return
        }

        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.upvoteByExistingVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.thread.upvotes += 1
                        self.vote!.direction = 1
                        self.emojis.addEmojiToStore(emojiId: 0, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.upvotes)
                        self.emojis.isLoading = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                         self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                })
        }
    }
    
    func downvoteByExistingVoteId() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.downvoteByVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.thread.downvotes += 1
                        self.vote!.direction = -1
                        self.emojis.addEmojiToStore(emojiId: 1, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.downvotes)
                        self.emojis.isLoading = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func addNewUpvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewUpvoteByThreadId)
        let json: [String: Any] = ["thread_id": thread.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Vote.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] vote in
                    self.vote = vote
                    self.thread.upvotes += 1
                    self.emojis.addEmojiToStore(emojiId: 0, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.upvotes)
                    self.emojis.isLoading = false
                })
        }
    }
    
    func switchUpvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchUpvoteByThreadId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.vote!.direction = 1
                        self.thread.upvotes += 1
                        self.thread.downvotes -= 1
                        
                        self.emojis.removeEmojiFromStore(emojiId: 1, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.downvotes)
                        self.emojis.addEmojiToStore(emojiId: 0, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.upvotes)
                        self.emojis.isLoading = false
                        
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func addNewDownvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewDownvoteByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Vote.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] vote in
                    self.vote = vote
                    self.thread.downvotes += 1
                    self.emojis.addEmojiToStore(emojiId: 1, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.downvotes)
                    self.emojis.isLoading = false
                })
        }
    }
    
    func switchDownvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchDownvoteByThreadId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.vote!.direction = -1
                        self.thread.upvotes -= 1
                        self.thread.downvotes += 1
                        
                        self.emojis.removeEmojiFromStore(emojiId: 0, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.upvotes)
                        self.emojis.addEmojiToStore(emojiId: 1, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: self.thread.downvotes)
                        self.emojis.isLoading = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func addEmojiByThreadId(emojiId: Int) {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.emojis, endPoint: EndPoint.addEmojiByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id, "emoji_id": emojiId]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: EmojiResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.emojis.isLoading = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        self.emojis.isLoading = false
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] emojiResponse in
                    self.emojis.addEmojiToStore(emojiId: emojiId, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: emojiResponse.newEmojiCount)
                })
        }
    }
    
    func removeEmojiByThreadId(emojiId: Int) {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.emojis, endPoint: EndPoint.removeEmojiByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id, "emoji_id": emojiId]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: EmojiResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.emojis.isLoading = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        self.emojis.isLoading = false
                        self.cancelEmojiLoadingProcess()
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] emojiResponse in
                    self.emojis.removeEmojiFromStore(emojiId: emojiId, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: emojiResponse.newEmojiCount)
                })
        }
    }
    
    func deleteVote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.deleteVoteByVoteIdThread)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        if self.vote!.direction == 1 {
                            self.thread.upvotes -= 1
                        } else {
                            self.thread.downvotes -= 1
                        }
                        
                        let originalVoteDirection = self.vote!.direction
                        self.vote!.direction = 0
                        
                        self.emojis.removeEmojiFromStore(emojiId: originalVoteDirection == 1 ? 0 : 1, user: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), newEmojiCount: originalVoteDirection == 1 ? self.thread.upvotes : self.thread.downvotes)
                        
                        self.emojis.isLoading = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func sendReportByThreadId(reason: String, taskGroup: DispatchGroup?) {
        if self.sendReportProcess != nil {
            return
        }
        
        taskGroup?.enter()
        let url = self.API.generateURL(resource: Resource.reports, endPoint: EndPoint.addReportByThreadId)
        let json: [String: Any] = ["thread_id": self.thread.id, "report_reason": reason]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.sendReportProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Report has been sent for thread: ", self.thread.id)
                        self.cancelReportProcess()
                        processingRequestsTaskGroup.leave()
                        taskGroup?.leave()
                        break
                    case .failure(let error):
                        self.cancelReportProcess()
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        taskGroup?.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
        
    }
    
    func hideThread(threadId: Int) {
        if self.hideProcess != nil {
            return
        }
        
        let json: [String: Any] = ["hide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.hideProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isHidden = true
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func unhideThread(threadId: Int) {
        if self.hideProcess != nil {
            return
        }
        
        let json: [String: Any] = ["unhide_thread_id": threadId]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideThreadByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.hideProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isHidden = false
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }    }
    
    func postMainComment(content: NSTextStorage, containerWidth: CGFloat) {
        if self.submitCommentProcess != nil {
            return
        }
        
        let params = ["thread_id": String(self.thread.id)]
        let url = API.generateURL(resource: Resource.comments, endPoint: EndPoint.postCommentByThreadId, params: params)
        let json: [String: Any] = ["content_string": content.string, "content_attributes": ["attributes": TextViewHelper.parseTextStorageAttributesAsBitRep(content: content)]]
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.submitCommentProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: NewCommentResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelSubmitCommentProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelSubmitCommentProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] tempNewCommentResponse in
                    let tempMainComment = tempNewCommentResponse.commentResponse
                    let tempVote = tempNewCommentResponse.voteResponse
//                    let user = tempNewCommentResponse.userResponse
                    
                    let commentDataStore = CommentDataStore(ancestorThreadId: self.thread.id, gameId: self.gameId, comment: tempMainComment, vote: tempVote, author: User(id: keychainService.getUserId(), username: keychainService.getUserName(), profileImageUrl: myUserImage!.profileImageUrl, profileImageWidth: myUserImage!.profileImageWidth, profileImageHeight: myUserImage!.profileImageHeight), containerWidth: containerWidth, hasNextPage: false)
                    
                    self.childComments[tempMainComment.id] = commentDataStore
                    self.childCommentList!.insert(tempMainComment.id, at: 0)
                    
                    UIApplication.shared.endEditing()
                })
        }
    }
    
    func fetchCommentTreeByThreadId(start:Int = 0, count:Int = 20, size:Int = 50, refresh: Bool = false, containerWidth: CGFloat, leadPadding: CGFloat) {
        if self.loadingProcess != nil || self.hasNextPage == false {
            return
        }
        
        if start != 0 {
            self.isLoadingNextPage = true
        }
        
        let params = ["parent_thread_id": String(self.thread.id), "start": String(start), "count": String(count), "size": String(size)]
        let url = API.generateURL(resource: Resource.comments, endPoint: EndPoint.getCommentTreeByThreadId, params: params)
        let request = API.generateRequest(url: url!, method: .GET)
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.loadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: CommentsResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelLoadingProcess()
                        self.isLoadingNextPage = false
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] serializedComments in
                    
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
                        
                        let commentDataStore = CommentDataStore(ancestorThreadId: self.thread.id, gameId: self.gameId, comment:  serializedComments.commentsResponse[i], vote: vote, author: serializedComments.commentsResponse[i].users[0], containerWidth: containerWidth - leadPadding * CGFloat(levelCount), hasNextPage: serializedComments.hasNextPage)
                        
                        nextLevelStore[commentId] = commentDataStore
                        
                        if levelCount > 0 {
                            let parentCommentId = levelArr[x]
                            
                            levelStore[parentCommentId]!.addCommentToChildList(commentDataStore: nextLevelStore[commentId]!)
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
                        self.childComments[commentId] = firstLevelStore[commentId]!
                    }
                    
                    if self.childCommentList == nil {
                        
                        self.childCommentList = firstLevelArr
                    } else {
                        self.childCommentList! += firstLevelArr
                    }
                    
                    self.hasNextPage = serializedComments.hasNextPage
                })
        }
    }
}

class CommentDataStore: ObservableObject {
    @Published private(set) var childCommentList: [Int]
    @Published var isLoadingNextPage: Bool = false
    @Published var isHidden: Bool = false
    @Published var vote: Vote?
    @Published var isVoting: Bool = false
    @Published var hasNextPage: Bool
    @Published var showChildComments: Bool = true
    
    var textStorage: NSTextStorage
    var desiredHeight: CGFloat
    
    private(set) var childComments: [Int: CommentDataStore]
    private(set) var comment: Comment
    private(set) var relativeDateString: String?
    private(set) var ancestorThreadId: Int
    private(set) var gameId: Int
    private(set) var author: User
    
    private let API = APIClient()
    private var cancellableSet: Set<AnyCancellable> = []
    private var loadingProcess: AnyCancellable?
    private var submitCommentProcess: AnyCancellable?
    private var emojiLoadingProcess: AnyCancellable?
    private var hideProcess: AnyCancellable?
    private var reportProcess: AnyCancellable?
    
    private(set) var authorProfileImageLoader: ImageLoader?
    private var authorProfileImageLoaderSub: AnyCancellable?
    @Environment(\.imageCache) private var cache: ImageCache
    
    init(ancestorThreadId: Int, gameId: Int, comment: Comment, vote: Vote?, author: User, containerWidth: CGFloat, hasNextPage: Bool) {
        self.hasNextPage = hasNextPage
        self.ancestorThreadId = ancestorThreadId
        self.gameId = gameId
        self.comment = comment
        self.vote = vote
        self.author = author
        
        let currDate = Date()
        if currDate.timeIntervalSince1970 - comment.created.timeIntervalSince1970 <= 30 {
            self.relativeDateString = "just now"
        } else if currDate.timeIntervalSince1970 - comment.created.timeIntervalSince1970 > 172800 { // longer 2 days
            let components = comment.created.get(.day, .month)
            self.relativeDateString = String(format: "%02d", components.month!) + "-" + String(format: "%02d", components.day!)
        } else {
            self.relativeDateString = RelativeDateTimeFormatter().localizedString(for: comment.created, relativeTo: currDate)
        }
        
        let generatedTextStorage = generateTextStorageFromJson(contentString: comment.contentString, contentAttributes: comment.contentAttributes)
        self.textStorage = generatedTextStorage
        self.desiredHeight = generatedTextStorage.height(containerWidth: containerWidth)
        
        self.childCommentList = []
        self.childComments = [:]
        
        self.mountAuthorProfileImage()
    }
    
    deinit {
        cancelLoadingProcess()
        cancellableSet.forEach { $0.cancel() }
        cancellableSet = []
        self.cancelHideProcess()
        self.cancelReportProcess()
        self.cancelEmojiLoadingProcess()
    }
    
    func cancelLoadingProcess() {
        loadingProcess?.cancel()
        loadingProcess = nil
    }
    
    func cancelEmojiLoadingProcess() {
        self.emojiLoadingProcess?.cancel()
        self.emojiLoadingProcess = nil
    }
    
    func cancelSubmitCommentProcess() {
        self.submitCommentProcess?.cancel()
        self.submitCommentProcess = nil
    }
    
    func cancelHideProcess() {
        self.hideProcess?.cancel()
        self.hideProcess = nil
    }
    
    func cancelReportProcess() {
        self.reportProcess?.cancel()
        self.reportProcess = nil
    }
    
    func toggleShowChildComments() {
        self.showChildComments.toggle()
    }
    
    func mountAuthorProfileImage() {
        if author.profileImageUrl != "" {
            self.authorProfileImageLoader = ImageLoader(url: author.profileImageUrl, cache: cache, whereIsThisFrom: "comment profile image loader", loadManually: true)
            self.authorProfileImageLoaderSub = authorProfileImageLoader!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
        } else {
            print("no profile picture to mount")
        }
    }
    
    func upvoteByExistingVoteId() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.upvoteByExistingVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.comment.upvotes += 1
                        self.vote!.direction = 1
                        self.isVoting = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func downvoteByExistingVoteId() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.downvoteByVoteId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in    
                    switch completion {
                    case .finished:
                        self.comment.downvotes += 1
                        self.vote!.direction = -1
                        self.isVoting = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func addCommentToChildList(commentDataStore: CommentDataStore) {
        if self.childComments[commentDataStore.comment.id] == nil {
            self.childCommentList.append(commentDataStore.comment.id)
            self.childComments[commentDataStore.comment.id] = commentDataStore
        }
    }
    
    func addNewUpvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewUpvoteByCommentId)
        let json: [String: Any] = ["comment_id": comment.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Vote.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] vote in
                    self.vote = vote
                    self.comment.upvotes += 1
                    self.isVoting = false
                })
        }
    }
    
    func switchUpvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchUpvoteByCommentId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.vote!.direction = 1
                        self.comment.upvotes += 1
                        self.comment.downvotes -= 1
                        self.isVoting = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func addNewDownvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.addNewDownvoteByCommentId)
        let json: [String: Any] = ["comment_id": self.comment.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Vote.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] vote in
                    self.vote = vote
                    self.comment.downvotes += 1
                    self.isVoting = false
                })
        }
    }
    
    func switchDownvote() {
        if self.emojiLoadingProcess != nil {
            return
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.switchDownvoteByCommentId)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.vote!.direction = -1
                        self.comment.upvotes -= 1
                        self.comment.downvotes += 1
                        self.isVoting = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func deleteVote(taskGroup: DispatchGroup? = nil) {
        if self.emojiLoadingProcess != nil {
            return
        }
        let url = self.API.generateURL(resource: Resource.votes, endPoint: EndPoint.deleteVoteByVoteIdComment)
        let json: [String: Any] = ["vote_id": self.vote!.id]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.emojiLoadingProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        if self.vote!.direction == 1 {
                            self.comment.upvotes -= 1
                        } else {
                            self.comment.downvotes -= 1
                        }
                        
                        self.vote!.direction = 0
                        self.isVoting = false
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelEmojiLoadingProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
        
    }
    
    func sendReportByCommentId(reason: String, taskGroup: DispatchGroup? = nil) {
        if self.reportProcess != nil {
            return
        }
        
        taskGroup?.enter()
        let url = self.API.generateURL(resource: Resource.reports, endPoint: EndPoint.addReportByCommentId)
        let json: [String: Any] = ["comment_id": self.comment.id, "report_reason": reason]
        let request = self.API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.reportProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Report has been sent for thread: ", self.comment.id)
                        self.cancelReportProcess()
                        taskGroup?.leave()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelReportProcess()
                        taskGroup?.leave()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func hideComment() {
        if self.hideProcess != nil {
            return
        }
        
        let json: [String: Any] = ["hide_comment_id": self.comment.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.hideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.hideProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isHidden = true
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func unhideComment() {
        if self.hideProcess != nil {
            return
        }
        
        let json: [String: Any] = ["unhide_thread_id": self.comment.id]
        let url = API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.unhideCommentByUserId)
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.hideProcess = session.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isHidden = false
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelHideProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { _ in
                    
                })
        }
    }
    
    func fetchCommentTreeByCommentId(start:Int = 0, count:Int = 20, size:Int = 50, refresh: Bool = false, containerWidth: CGFloat, leadPadding: CGFloat) {
        if self.loadingProcess != nil {
            return
        }
        
        self.isLoadingNextPage = true
        
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
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.loadingProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: CommentsResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelLoadingProcess()
                        self.isLoadingNextPage = false
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] serializedComments in
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
                        
                        nextLevelStore[commentId] = CommentDataStore(ancestorThreadId: self.ancestorThreadId, gameId: self.gameId, comment:  serializedComments.commentsResponse[i], vote: vote, author: serializedComments.commentsResponse[i].users[0], containerWidth: containerWidth - leadPadding * CGFloat(levelCount), hasNextPage: serializedComments.hasNextPage)
                        
                        if levelCount > 0 {
                            let parentCommentId = levelArr[x]
                            
                            levelStore[parentCommentId]!.childCommentList.append(commentId)
                            levelStore[parentCommentId]!.childComments[commentId] = nextLevelStore[commentId]
                        }
                        
                        i += 1
                    }
                    
                    if levelCount == 0 {
                        firstLevelArr = nextLevelArr
                        firstLevelStore = nextLevelStore
                    }
                    
                    for commentId in firstLevelArr {
                        self.childComments[commentId] = firstLevelStore[commentId]!
                    }
                    
                    self.childCommentList += firstLevelArr
                })
        }
    }
    
    func postChildComment(content: NSTextStorage, containerWidth: CGFloat) {
        let params = ["parent_comment_id": String(self.comment.id)]
        let url = API.generateURL(resource: Resource.comments, endPoint: EndPoint.postCommentByParentCommentId, params: params)
        let json: [String: Any] = ["content_string": content.string, "content_attributes": ["attributes": TextViewHelper.parseTextStorageAttributesAsBitRep(content: content)]]
        let request = API.generateRequest(url: url!, method: .POST, json: json)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: NewCommentResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.isLoadingNextPage = false
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] tempNewCommentResponse in
                    let tempChildComment = tempNewCommentResponse.commentResponse
                    let tempVote = tempNewCommentResponse.voteResponse
                    let user = tempNewCommentResponse.userResponse
                    
                    let commentDataStore = CommentDataStore(ancestorThreadId: self.ancestorThreadId, gameId: self.gameId, comment: tempChildComment, vote: tempVote, author: user, containerWidth: containerWidth, hasNextPage: false)
                    
                    self.childComments[tempChildComment.id] = commentDataStore
                    
                    var reversedChildCommentList = self.childCommentList
                    reversedChildCommentList.reverse()
                    reversedChildCommentList.append(tempChildComment.id)
                    reversedChildCommentList.reverse()
                    self.childCommentList = reversedChildCommentList
                    
                    UIApplication.shared.endEditing()
                })
                .store(in: &self.cancellableSet)
        }
    }
}
