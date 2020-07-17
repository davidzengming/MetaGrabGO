//
//  Thread.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

struct Thread: Hashable, Codable, Identifiable {
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
    var imageWidths: ImageWidths
    var imageHeights: ImageHeights
    var created: Date
    var emojis: Emojis?
    var votes: [Vote]
    var users: [User]
}
