//
//  CommentsResponse.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-01.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct CommentsResponse: Hashable, Codable {
    var commentsResponse: [Comment]
    var commentBreaksArr: [Int]
    var hasNextPage: Bool
}
