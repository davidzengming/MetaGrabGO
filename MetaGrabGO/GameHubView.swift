//
//  GameList.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct GameHubView: View {
    @EnvironmentObject var gameDataStore: GameDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    
    @State var selectedTab = 0
    
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
        
        print("game hub view created")
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                FrontHubView(homeGamesDataStore: HomeGamesDataStore(), followGamesDataStore: FollowGamesDataStore(), visitedGamesDataStore: VisitedGamesDataStore(), selectedTab: self.$selectedTab)
                    .navigationBarTitle("Home")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "square.stack.3d.up.fill")
                Text("Home")
            }
                .tag(0)
            .background(self.assetsDataStore.colors["darkButNotBlack"])
            
            NavigationView {
                PopularGamesView(popularListDataStore: PopularListDataStore(access: self.userDataStore.token!.access))
                    .navigationBarTitle("Popular")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "flame.fill")
                Text("Popular")
            }
            .tag(1)
            .background(self.assetsDataStore.colors["darkButNotBlack"])
            
            NavigationView {
                TimelineGamesView(timelineDataStore: TimelineDataStore())
                    .navigationBarTitle("Upcoming")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "hourglass.bottomhalf.fill")
                Text("Upcoming")
            }
            .tag(2)
            .background(self.assetsDataStore.colors["darkButNotBlack"])
            
            NavigationView {
                UserProfileView(blockHiddenDataStore: BlockHiddenDataStore())
                    .navigationBarTitle("Profile")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            .tag(3)
            .background(self.assetsDataStore.colors["darkButNotBlack"])
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(self.assetsDataStore.colors["darkButNotBlack"])
    }
}

// Use this to delay instantiation when using `NavigationLink`, etc...
struct LazyView<Content: View>: View {
    var content: () -> Content
    var body: some View {
        self.content()
    }
}
