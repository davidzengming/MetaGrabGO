//
//  GamesTimeLineResponse.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-26.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct GamesTimeLineResponseAtEpochTime: Hashable, Codable {
    var gameArr: [Game]
    var timeScores: [Double]
    var hasPrevPage: Bool
    var hasNextPage: Bool
}

struct GamesTimeLineResponseBeforeEpochTime: Hashable, Codable {
    var gameArr: [Game]
    var timeScores: [Double]
    var hasPrevPage: Bool
}

struct GamesTimeLineResponseAfterEpochTime: Hashable, Codable {
    var gameArr: [Game]
    var timeScores: [Double]
    var hasNextPage: Bool
}
