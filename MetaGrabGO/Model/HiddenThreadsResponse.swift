//
//  HiddenThreadsResponse.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-05-12.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct HiddenThreadsResponse: Hashable, Codable {
    var hiddenThreads: [Thread]
}
