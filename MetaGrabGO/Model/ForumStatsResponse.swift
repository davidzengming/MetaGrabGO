//
//  ForumStatsResponse.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-25.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct ForumStatsResponse: Hashable, Codable {
    var isFollowed: Bool
    var followerCount: Int
    var threadCount: Int
}
