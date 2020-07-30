//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-21.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI

let appWideAssets = AppWideAssets()

struct AppWideAssets {
    // Emojis
    var emojiArray = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    var emojis = [
        0: UIImage(named: ":thumbs_up:"),
        1: UIImage(named: ":thumbs_down:"),
        2: UIImage(named: ":tongue_out:"),
        3: UIImage(named: ":sweat:"),
        4: UIImage(named: ":sunglasses:"),
        5: UIImage(named: ":laugh_out_loud:"),
        6: UIImage(named: ":hearts:"),
        7: UIImage(named: ":ecks_dee:"),
        8: UIImage(named: ":ecks_dee_tongue:"),
        9: UIImage(named: ":cry:"),
        10: UIImage(named: ":belgium:"),
        11: UIImage(named: ":lemon:")
    ]

//    let notQuiteBlack = hexStringToUIColor(hex: "#23272a")
//    let darkButNotBlack = hexStringToUIColor(hex: "#2C2F33")
//    let blurple = hexStringToUIColor(hex: "#7289DA")
//    let teal = hexStringToUIColor(hex: "#0297cf")
//    let kindaDarkGray = hexStringToUIColor(hex: "#232424")
//    let veryDarkGray = hexStringToUIColor(hex: "#0c0c0c")
//
    var colors = ["notQuiteBlack": Color(hexStringToUIColor(hex: "#23272a")), "darkButNotBlack": Color(hexStringToUIColor(hex: "#2C2F33")), "blurple": Color(hexStringToUIColor(hex: "#7289DA")), "teal": Color(hexStringToUIColor(hex: "#0297cf")), "kindaDarkGray": Color(hexStringToUIColor(hex: "#232424")), "veryDarkGray": Color(hexStringToUIColor(hex: "#0c0c0c"))]
    var uiColors = ["notQuiteBlack": hexStringToUIColor(hex: "#23272a"), "darkButNotBlack": hexStringToUIColor(hex: "#2C2F33"), "blurple": hexStringToUIColor(hex: "#7289DA"), "teal": hexStringToUIColor(hex: "#0297cf"), "kindaDarkGray": hexStringToUIColor(hex: "#232424"), "veryDarkGray": hexStringToUIColor(hex: "#0c0c0c")]
    
    var leadingLineColors = [Color.purple, Color.red, Color.orange, Color.yellow, Color.green]
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
