//
//  ImageUrls.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-02-20.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageUrls: Hashable, Codable {
    var urls: [String]
}

struct ImageWidths: Hashable, Codable {
    var widths: [String]
}

struct ImageHeights: Hashable, Codable {
    var heights: [String]
}
