//
//  Game.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

struct Game: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var releaseDate: Date
    var nextExpansionReleaseDate: Date?
    var developer: Developer
    var lastUpdated: Date
    var genre: Genre
    var icon: String
    var banner: String
    var threadCount: Int
    var gameSummary: String
    var followerCount: Int
}
