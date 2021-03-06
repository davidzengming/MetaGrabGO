//
//  Token.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

struct Token: Hashable, Codable {
    var refresh: String
    var access: String
    var userId: Int
    var refreshExpDateEpoch: Int
    var accessExpDateEpoch: Int
    var email: String
    
    var profileImageUrl: String
    var profileImageWidth: String
    var profileImageHeight: String
}
