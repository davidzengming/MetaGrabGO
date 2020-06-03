//
//  ThreadsResponse.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-11-13.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation

struct ThreadsResponse: Hashable, Codable {
    var threadsResponse: [Thread]
    var hasNextPage: Bool
}
