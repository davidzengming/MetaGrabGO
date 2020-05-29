//
//  EmojiResponse.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-02.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct EmojiResponse: Hashable, Codable {
    var isSuccess: Bool
    var newEmojiCount: Int
}
