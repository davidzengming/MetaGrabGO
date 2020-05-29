//
//  Emojis.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-02.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct Emojis: Hashable, Codable {
    var emojisIdArr: [Int]
    var userArrPerEmojiDict: [Int: [User]]
    var emojiReactionCountDict: [Int: Int]
    var didReactToEmojiDict: [Int: Bool]
}
