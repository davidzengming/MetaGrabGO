//
//  Comment.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-22.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation

struct Comment: Hashable, Codable, Identifiable {
    var id: Int
    var contentString: String
    var contentAttributes: Attributes
    var upvotes: Int
    var downvotes: Int
    var author: Int
    var parentThread: Int?
    var parentPost: Int?
    var numChilds: Int
    var numSubtreeNodes: Int
    var created: Date
//    var emojis: Emojis?
}
