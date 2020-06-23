//
//  GlobalGamesDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-22.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

class GlobalGamesDataStore: ObservableObject {
    var games: [Int: Game]
    
    init() {
        self.games = [:]
    }
}
