//
//  CommentLoadTree.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-11-12.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation

struct CommentLoadTree: Hashable, Codable {
    var addedComments: [Comment]
    var moreComments: [Comment]
    var addedVotes: [Vote]
    var usersResponse: [User]
}
