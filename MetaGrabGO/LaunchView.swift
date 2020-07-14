//
//  ContentView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-20.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        MainView()
            .environmentObject(UserDataStore())
    }
}
