//
//  NewCommentResponse.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-11-21.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation

struct NewCommentResponse: Hashable, Codable {
    var commentResponse: Comment
    var voteResponse: Vote
    var userResponse: User
}
