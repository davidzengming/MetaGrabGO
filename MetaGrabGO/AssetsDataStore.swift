//
//  AssetsDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-21.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

class AssetsDataStore: ObservableObject {
    

    
    // Emojis
    var emojiArray = [Int]()
    var emojis = [Int: UIImage]()
    
    let emojiNames = [
        ":thumbs_up:",
        ":thumbs_down:",
        ":tongue_out:",
        ":sweat:",
        ":sunglasses:",
        ":laugh_out_loud:",
        ":hearts:",
        ":ecks_dee:",
        ":ecks_dee_tongue:",
        ":cry:",
        ":belgium:",
        ":lemon:"
    ]
    
    init() {
        self.loadEmojis()
        self.loadColors()
        self.loadLeadingLineColors()
    }
    
    func loadEmojis() {
        emojiArray = []
        
        for index in (0..<emojiNames.count) {
            emojis[index] = UIImage(named: emojiNames[index])
            emojiArray.append(index)
        }
    }
    
    
    // Colors
    
    @Published var colors = [String: Color]()
    @Published var uiColors = [String: UIColor]()
    @Published var leadingLineColors = [Color]()
    
    func loadLeadingLineColors() {
        if self.leadingLineColors.count != 0 {
            return
        }
        
        var leadingLineColors : [Color] = []
        leadingLineColors.append(Color.purple)
        leadingLineColors.append(Color.red)
        leadingLineColors.append(Color.orange)
        leadingLineColors.append(Color.yellow)
        leadingLineColors.append(Color.green)
        self.leadingLineColors = leadingLineColors
        return
    }
    
    func loadColors() {
        if self.colors.count != 0 {
            return
        }
        
        let notQuiteBlack = hexStringToUIColor(hex: "#23272a")
        let deepButNotBlack = hexStringToUIColor(hex: "#2C2F33")
        let blurple = hexStringToUIColor(hex: "#7289DA")
        let deepBlue = hexStringToUIColor(hex: "#15202d")
        let lightBlue = hexStringToUIColor(hex: "#1a2838")
        let teal = hexStringToUIColor(hex: "#0297cf")
        
        self.colors["notQuiteBlack"] = Color(notQuiteBlack)
        self.colors["darkButNotBlack"] = Color(deepButNotBlack)
        self.colors["blurple"] = Color(blurple)
        self.colors["deepBlue"] = Color(deepBlue)
        self.colors["lightBlue"] = Color(lightBlue)
        self.colors["teal"] = Color(teal)
        
        self.uiColors["notQuiteBlack"] = notQuiteBlack
        self.uiColors["darkButNotBlack"] = deepButNotBlack
        self.uiColors["blurple"] = blurple
        self.uiColors["deepBlue"] = deepBlue
        self.uiColors["lightBlue"] = lightBlue
        self.uiColors["teal"] = teal
    }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
