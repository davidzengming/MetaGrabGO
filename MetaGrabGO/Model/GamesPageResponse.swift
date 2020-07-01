//
//  GamePageResponse.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-24.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct GamesPageResponse: Hashable, Codable {
    var gamesArr: [Game]
    var hasNextPage: Bool
}
