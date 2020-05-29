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
    }
    
    var body: some View {
        TabView {
            NavigationView {
                FrontHubView()
                    .navigationBarTitle("Front")
                    .navigationBarHidden(true)
                
            }
            .tabItem {
                Image(systemName: "square.stack.3d.up.fill")
                Text("Front")
            }
            
            NavigationView {
                PopularGamesView()
                    .navigationBarTitle("Popular")
                    .navigationBarHidden(true)
                
            }
            .tabItem {
                Image(systemName: "flame.fill")
                Text("Popular")
            }
            
            NavigationView {
                TimelineGamesView()
                    .navigationBarTitle("Upcoming")
                    .navigationBarHidden(true)
                
            }
            .tabItem {
                Image(systemName: "hourglass.bottomhalf.fill")
                Text("Upcoming")
            }
            
            NavigationView {
                UserProfileView(blockHiddenDataStore: BlockHiddenDataStore())
                    .navigationBarTitle("Profile")
                    .navigationBarHidden(true)
                
                //.edgesIgnoringSafeArea(.top)
            }
                
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
            
        }
        .onAppear() {
            self.assetsDataStore.loadEmojis()
            self.assetsDataStore.loadColors()
            self.assetsDataStore.loadLeadingLineColors()
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