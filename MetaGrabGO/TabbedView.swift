//
//  TabbedView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-07-31.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct TabbedView: View {
    @EnvironmentObject private var globalGamesDataStore: GlobalGamesDataStore
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                FrontHubView(homeGamesDataStore: HomeGamesDataStore(), followGamesDataStore: FollowGamesDataStore(), visitedGamesDataStore: VisitedGamesDataStore(), selectedTab: self.$selectedTab)
                    // hack for adding some additional space for back button since < is a bit thin
                    .navigationBarTitle("          ")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "heart.circle")
                Text("Home")
            }
            .tag(0)
            .background(appWideAssets.colors["darkButNotBlack"])
            
            NavigationView {
                PopularGamesView(popularListDataStore: PopularListDataStore(globalGamesDataStore: self.globalGamesDataStore))
                    .navigationBarTitle("          ")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "flame.fill")
                Text("Popular")
            }
            .tag(1)
            .background(appWideAssets.colors["darkButNotBlack"])
            
            NavigationView {
                TimelineGamesView(timelineDataStore: TimelineDataStore())
                    .navigationBarTitle("          ")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "hourglass")
                Text("Upcoming")
            }
            .tag(2)
            .background(appWideAssets.colors["darkButNotBlack"])
            
            NavigationView {
                UserProfileView(blockHiddenDataStore: BlockHiddenDataStore())
                //                            .navigationBarTitle("          ")
                //                            .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Settings")
            }
            .tag(3)
            .background(appWideAssets.colors["darkButNotBlack"])
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(appWideAssets.colors["darkButNotBlack"])
    }
}
