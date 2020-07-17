//
//  GlobalGamesDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-22.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

final class GlobalGamesDataStore: ObservableObject {
    private(set) var games: [Int: Game]
    
    init() {
        self.games = [:]
    }
    
    func addGame(game: Game) {
        if games[game.id] == nil {
            self.games[game.id] = game
        }
    }
}
