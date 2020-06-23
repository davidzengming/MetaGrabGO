//
//  RecentFollowDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-22.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

class RecentFollowDataStore: ObservableObject {
    var recentVisitGames: [Int]
    var followGames: Set<Int>
    
    init() {
        self.recentVisitGames = []
        self.followGames = []
    }
    
    func insertVisitGame(gameId: Int) {
        var addedGameId = gameId
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
