//
//  GameList.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct GameHubView: View {
    @EnvironmentObject private var userDataStore: UserDataStore
    
    init() {
        // To remove only extra separators below the list:
        // UITableView.appearance().tableFooterView = UIView()
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
        //        let navBarAppearance = UINavigationBar.appearance()
        //
        //        let kern = 2
        //
        //        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, NSAttributedString.Key.kern: kern]
        //        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, NSAttributedString.Key.kern: kern]
        //
//        print("game hub view created")
    }
    
    var body: some View {
        Group {
            if userDataStore.isAuthenticated == false {
                UserView()
                    .transition(.slide)
            } else {
                TabbedView()
                    .environmentObject(RecentFollowDataStore())
            }
        }
    }
}

// Use this to delay instantiation when using `NavigationLink`, etc...
struct LazyView<Content: View>: View {
    var content: () -> Content
    var body: some View {
        self.content()
    }
}
