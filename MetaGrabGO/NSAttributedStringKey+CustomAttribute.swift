//
//  NSAttributedStringKey+CustomAttribute.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-01-13.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

extension NSAttributedString.Key {
    static let numberedListAttribute = NSAttributedString.Key(rawValue: "NumberedListAttribute")
    static let numberHeaderInBulletList = NSAttributedString.Key(rawValue: "NumberHeaderInBulletListAttribute")
    
    static let dashListAttribute = NSAttributedString.Key(rawValue: "DashListAttribute")
    static let dashHeaderInBulletList = NSAttributedString.Key(rawValue: "DashHeaderInBulletListAttribute")
    
    static let mask = NSAttributedString.Key(rawValue: "Mask")
}
