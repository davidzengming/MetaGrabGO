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

class RecentFollowDataStore: ObservableObject {
    var recentVisitGames: [Int]
    var followGames: Set<Int>
    
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


class HomeGamesDataStore: ObservableObject {
    @Published var isLoaded: Bool
    
    let API = APIClient()
    
    init() {
        self.isLoaded = false
    }
    
    func updateGameHistory(visitedGamesDataStore: VisitedGamesDataStore, recentFollowDataStore: RecentFollowDataStore) {
        if recentFollowDataStore.recentVisitGames != visitedGamesDataStore.visitedGamesId {
            DispatchQueue.main.async {
                visitedGamesDataStore.visitedGamesId = recentFollowDataStore.recentVisitGames
            }
        }
    }
    
    func updateFollowGames(followGamesDataStore: FollowGamesDataStore, recentFollowDataStore: RecentFollowDataStore) {
        
        if followGamesDataStore.followGamesIdSet != recentFollowDataStore.followGames {
            followGamesDataStore.followGamesIdSet = recentFollowDataStore.followGames
            var newFollowGamesList: [Int] = []
            for gameId in followGamesDataStore.followGamesIdSet {
                newFollowGamesList.append(gameId)
            }
            
            DispatchQueue.main.async {
                followGamesDataStore.followedGamesId = newFollowGamesList
            }
        }
    }
    
    func fetchFollowGames(globalGamesDataStore: GlobalGamesDataStore, followGamesDataStore: FollowGamesDataStore, userDataStore: UserDataStore, start:Int = 0, count:Int = 10, recentFollowDataStore: RecentFollowDataStore, taskGroup: DispatchGroup?) {
        
        taskGroup?.enter()
        let params = ["start": String(start), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getFollowGameByUserId, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let followGames: [Game] = load(jsonData: jsonString.data(using: .utf8)!)
                
                var newFollowGamesIdArr: [Int] = []
                
                for game in followGames {
                    newFollowGamesIdArr.append(game.id)
                    
                    recentFollowDataStore.followGames.insert(game.id)
                    followGamesDataStore.followGamesIdSet.insert(game.id)
                    
                    // could optimize a bit further by putting this in same background queue as visited API call, but will create crash if same resource used by different threads - race condition
                    globalGamesQueue.async {
                        if globalGamesDataStore.games[game.id] == nil {
                            globalGamesDataStore.games[game.id] = game
                        }
                    }
                }
                
                if followGamesDataStore.followedGamesId != newFollowGamesIdArr {
                    DispatchQueue.main.async {
                        followGamesDataStore.followedGamesId = newFollowGamesIdArr
                    }
                }
                
                taskGroup?.leave()
            }
        }
    }
    
    func getGameHistory(globalGamesDataStore: GlobalGamesDataStore, visitedGamesDataStore: VisitedGamesDataStore, recentFollowDataStore: RecentFollowDataStore, taskGroup: DispatchGroup?, userDataStore: UserDataStore) {
        taskGroup?.enter()
        
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGameHistoryByUserId)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let gameHistoryResponse: GameHistoryResponse = load(jsonData: jsonString.data(using: .utf8)!)
                
                var newVisitedGamesIdArr: [Int] = []
                
                for game in gameHistoryResponse.gameHistory  {
                    newVisitedGamesIdArr.append(game.id)
                    
                    // could optimize a bit further by putting this in same background queue as visited API call, but will create crash if same resource used by different threads - race condition
                    globalGamesQueue.async {
                        if globalGamesDataStore.games[game.id] == nil {
                            globalGamesDataStore.games[game.id] = game
                        }
                    }
                }
                
                recentFollowDataStore.recentVisitGames = newVisitedGamesIdArr
                
                DispatchQueue.main.async {
                    visitedGamesDataStore.visitedGamesId = newVisitedGamesIdArr
                }
                taskGroup?.leave()
            }
        }
    }
}

class FollowGamesDataStore: ObservableObject {
    @Published var followedGamesId: [Int] = []
    var followGamesIdSet: Set<Int> = []
}

class VisitedGamesDataStore: ObservableObject {
    @Published var visitedGamesId: [Int] = []
}
