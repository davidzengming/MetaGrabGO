//
//  Genre.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

struct Genre: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
}
