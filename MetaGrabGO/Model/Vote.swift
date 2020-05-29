//
//  Vote.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-11-20.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation

struct Vote: Hashable, Codable, Identifiable {
    var id: Int
    var thread: Int?
    var comment: Int?
    var direction: Int
}
