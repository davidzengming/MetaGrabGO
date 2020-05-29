//
//  NewThreadResponse.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-11-21.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation

struct NewThreadResponse: Hashable, Codable {
    var threadResponse: Thread
    var voteResponse: Vote
    var userResponse: User
}
