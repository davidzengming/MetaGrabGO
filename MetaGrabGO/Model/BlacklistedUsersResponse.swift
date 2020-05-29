//
//  BlacklistedUsersResponse.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-05-12.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

struct BlacklistedUsersResponse: Hashable, Codable {
    var blacklistedUsers: [User]
}
