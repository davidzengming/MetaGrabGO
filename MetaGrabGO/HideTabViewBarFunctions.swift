//
//  HideTabViewBarFunctions.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-27.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct Global {
    static var tabBar : UITabBar?
}

extension UITabBar {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        Global.tabBar = self
        print("Tab Bar moved to superview")
    }
}
