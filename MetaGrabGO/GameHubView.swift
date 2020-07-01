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
        TabView {
            NavigationView {
                FrontHubView(frontGamesDataStore: FrontGamesDataStore(), followGamesDataStore: FollowGamesDataStore(), visitedGamesDataStore: VisitedGamesDataStore())
                    .navigationBarTitle("Front")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "square.stack.3d.up.fill")
                Text("Front")
            }
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
