//
//  HomeGamesDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-19.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

private let globalGamesQueue = DispatchQueue(label: "com.domain.app.blocks")

final class RecentFollowDataStore: ObservableObject {
    var recentVisitGames: [Int]
    var followGames: Set<Int>
    var shouldRefreshDataStore = false
    
    init() {
        self.recentVisitGames = []
        self.followGames = []
    }
    
    func insertVisitGame(gameId: Int) {
        let addedGameId = gameId
        var newVisitGameList: [Int] = []
        newVisitGameList.append(addedGameId)
        var seenGameId: Set<Int> = []
        seenGameId.insert(addedGameId)
        
        for gameId in self.recentVisitGames {
            if !seenGameId.contains(gameId) {
                seenGameId.insert(gameId)
                newVisitGameList.append(gameId)
            }
        }
        
        self.recentVisitGames = Array(newVisitGameList[0...min(9, newVisitGameList.count - 1)])
    }
}


final class HomeGamesDataStore: ObservableObject {
    @Published var isLoaded: Bool

    private let API = APIClient()
    
    private var gameHistoryProcess: AnyCancellable?
    private var followGameProcess: AnyCancellable?
    @Environment(\.imageCache) private var cache: ImageCache
    
    init() {
        self.isLoaded = false
    }
    
    deinit {
        self.cancelGameHistoryProcess()
        self.cancelFollowGameProcess()
    }
    
    func cancelGameHistoryProcess() {
        self.gameHistoryProcess?.cancel()
        self.gameHistoryProcess = nil
    }
    
    func cancelFollowGameProcess() {
        self.followGameProcess?.cancel()
        self.followGameProcess = nil
    }
    
    func updateGameHistory(visitedGamesDataStore: VisitedGamesDataStore, recentFollowDataStore: RecentFollowDataStore, globalGamesDataStore: GlobalGamesDataStore) {
        
        var numOfNewGames = 0
        
        var recentGamesSet = Set<Int>()
        
        for gameId in recentFollowDataStore.recentVisitGames {
            recentGamesSet.insert(gameId)
            if visitedGamesDataStore.imageLoaders[gameId] == nil {
                visitedGamesDataStore.addImageLoader(gameId: gameId, url: globalGamesDataStore.games[gameId]!.icon, cache: cache, whereIsThisFrom: "update game history image loader", loadManually: true)
                numOfNewGames += 1
            }
        }
        
        let numOfItemsToBeRemoved = max(0, numOfNewGames - (10 - visitedGamesDataStore.visitedGamesId.count))
        
        var gamesAboutToBeRemoved: [Int] = []
        if numOfItemsToBeRemoved > 0 {
            gamesAboutToBeRemoved = visitedGamesDataStore.visitedGamesId.suffix(numOfItemsToBeRemoved)
        }
        
        if recentFollowDataStore.recentVisitGames != visitedGamesDataStore.visitedGamesId {
            DispatchQueue.main.async {
//                print("old: ", visitedGamesDataStore.visitedGamesId)
//                print("new: ", recentFollowDataStore.recentVisitGames)
//                print("remove: ", gamesAboutToBeRemoved)
                visitedGamesDataStore.visitedGamesId = recentFollowDataStore.recentVisitGames
                
                for gameId in gamesAboutToBeRemoved {
                    if recentGamesSet.contains(gameId) {
                        continue
                    }
                    visitedGamesDataStore.removeImageLoader(gameId: gameId)
                }
            }
        }
    }
    
    func updateFollowGames(followGamesDataStore: FollowGamesDataStore, recentFollowDataStore: RecentFollowDataStore, globalGamesDataStore: GlobalGamesDataStore) {

        var gamesAboutToBeRemoved : [Int] = []
        
        for gameId in recentFollowDataStore.followGames {
            if followGamesDataStore.followGamesIdSet.contains(gameId) == false {
                followGamesDataStore.addImageLoader(gameId: gameId, url: globalGamesDataStore.games[gameId]!.icon, cache: cache, whereIsThisFrom: "update game history image loader", loadManually: true)
            }
        }
        
        for gameId in followGamesDataStore.followGamesIdSet {
            if recentFollowDataStore.followGames.contains(gameId) == false {
                gamesAboutToBeRemoved.append(gameId)
            }
        }
        
        if followGamesDataStore.followGamesIdSet != recentFollowDataStore.followGames {
            followGamesDataStore.followGamesIdSet = recentFollowDataStore.followGames
            var newFollowGamesList: [Int] = []
            for gameId in followGamesDataStore.followGamesIdSet {
                newFollowGamesList.append(gameId)
            }
            
            DispatchQueue.main.async {
                followGamesDataStore.followedGamesId = newFollowGamesList
                for gameId in gamesAboutToBeRemoved {
                    followGamesDataStore.removeImageLoader(gameId: gameId)
                }
            }
        }
    }
    
    func fetchFollowGames(globalGamesDataStore: GlobalGamesDataStore, followGamesDataStore: FollowGamesDataStore, start:Int = 0, count:Int = 10, recentFollowDataStore: RecentFollowDataStore, taskGroup: DispatchGroup?) {
        
        taskGroup?.enter()
        let params = ["start": String(start), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getFollowGameByUserId, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()

            self.followGameProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: [Game].self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelFollowGameProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelFollowGameProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] followGames in
                    var newFollowGamesIdArr: [Int] = []
                    
                    for game in followGames {
                        globalGamesDataStore.addGame(game: game)
                        
                        newFollowGamesIdArr.append(game.id)
                        
                        recentFollowDataStore.followGames.insert(game.id)
                        followGamesDataStore.followGamesIdSet.insert(game.id)
                        
                        // could optimize a bit further by putting this in same background queue as visited API call, but will create crash if same resource used by different threads - race condition
                        
                        followGamesDataStore.addImageLoader(gameId: game.id, url: globalGamesDataStore.games[game.id]!.icon, cache: self.cache, whereIsThisFrom: "update game history image loader", loadManually: true)
                    }
                    
                    if followGamesDataStore.followedGamesId != newFollowGamesIdArr {
                        followGamesDataStore.followedGamesId = newFollowGamesIdArr
                    }
                    taskGroup?.leave()
                })
        }
    }
    
    func getGameHistory(globalGamesDataStore: GlobalGamesDataStore, visitedGamesDataStore: VisitedGamesDataStore, recentFollowDataStore: RecentFollowDataStore, taskGroup: DispatchGroup?) {
        taskGroup?.enter()
        
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGameHistoryByUserId)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.gameHistoryProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: GameHistoryResponse.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelGameHistoryProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        self.cancelGameHistoryProcess()
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] gameHistoryResponse in
                    var newVisitedGamesIdArr: [Int] = []
                    for game in gameHistoryResponse.gameHistory  {
                        
                        globalGamesDataStore.addGame(game: game)
                        
                        newVisitedGamesIdArr.append(game.id)
                        visitedGamesDataStore.addImageLoader(gameId: game.id, url: globalGamesDataStore.games[game.id]!.icon, cache: self.cache, whereIsThisFrom: "update game history image loader", loadManually: true)
                        
                        // could optimize a bit further by putting this in same background queue as visited API call, but will create crash if same resource used by different threads - race condition
                        
                    }
                    
                    recentFollowDataStore.recentVisitGames = newVisitedGamesIdArr
                    visitedGamesDataStore.visitedGamesId = newVisitedGamesIdArr
                    taskGroup?.leave()
                })
        }
    }
}

final class FollowGamesDataStore: ObservableObject {
    @Published var followedGamesId: [Int] = []
    var followGamesIdSet: Set<Int> = []
    
    private(set) var imageLoaders: [Int: ImageLoader] = [:]
    private var imageLoaderSubs = [Int: AnyCancellable]()
    
    func addImageLoader(gameId: Int, url: String, cache: ImageCache, whereIsThisFrom: String, loadManually: Bool) {
        self.imageLoaders[gameId] = ImageLoader(url: url, cache: cache, whereIsThisFrom: whereIsThisFrom, loadManually: true)
        self.addImageLoaderSub(gameId: gameId)
    }
    
    func addImageLoaderSub(gameId: Int) {
        self.imageLoaderSubs[gameId] = self.imageLoaders[gameId]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
    }
    
    func removeImageLoader(gameId: Int) {
        self.imageLoaders[gameId]!.cancelProcess()
        self.imageLoaders.removeValue(forKey: gameId)
        self.imageLoaderSubs.removeValue(forKey: gameId)
    }
    
    deinit {
        for (_, sub) in imageLoaderSubs {
            sub.cancel()
        }
        imageLoaderSubs = [:]
    }
}

final class VisitedGamesDataStore: ObservableObject {
    @Published var visitedGamesId: [Int] = []
    
    private(set) var imageLoaders: [Int: ImageLoader] = [:]
    private var imageLoaderSubs = [Int: AnyCancellable]()
    
    func addImageLoader(gameId: Int, url: String, cache: ImageCache, whereIsThisFrom: String, loadManually: Bool) {
        self.imageLoaders[gameId] = ImageLoader(url: url, cache: cache, whereIsThisFrom: whereIsThisFrom, loadManually: true)
        self.addImageLoaderSub(gameId: gameId)
    }
    
    func addImageLoaderSub(gameId: Int) {
        self.imageLoaderSubs[gameId] = self.imageLoaders[gameId]!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
    }
    
    func removeImageLoader(gameId: Int) {
        self.imageLoaders[gameId]!.cancelProcess()
        self.imageLoaders.removeValue(forKey: gameId)
        self.imageLoaderSubs.removeValue(forKey: gameId)
    }
    
    deinit {
        for (_, sub) in imageLoaderSubs {
            sub.cancel()
        }
        imageLoaderSubs = [:]
    }
}
