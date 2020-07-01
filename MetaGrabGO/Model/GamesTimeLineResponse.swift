//
//  GamesTimeLineResponse.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-26.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct GamesTimeLineResponse: Hashable, Codable {
    var gameArr: [Game]
    var timeScores: [Double]
}
