//
//  HiddenThread.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-08.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct HiddenThread: Hashable, Codable, Identifiable {
    var id: Int
    var title: String
    var contentString: String
    var contentAttributes: Attributes
    var upvotes: Int
    var downvotes: Int
    var flair: Int
    var author: Int
    var forum: Int
    var numChilds: Int
    var numSubtreeNodes: Int
    var imageUrls: ImageUrls
    var created: Date
    var emojis: Emojis?
}

struct HiddenComment: Hashable, Codable, Identifiable {
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
}
