//
//  DarkHostingController.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-24.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI
import Swift
import Foundation

class DarkHostingController<Content> : UIHostingController<Content> where Content : View {
    @objc override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}
