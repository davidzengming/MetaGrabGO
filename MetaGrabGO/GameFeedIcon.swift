//
//  GameFeedIcon.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI
import Combine

struct GameFeedIcon : View {
    
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    @Environment(\.imageCache) var cache: ImageCache
    
    @ObservedObject var imageLoader: ImageLoader
    @State private var showModal = false
    
    var game: Game
    let placeholder = Image(systemName: "rectangle.fill")
    
    var body: some View {
        GeometryReader { a in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if self.imageLoader.downloadedImage != nil {
                        Image(uiImage: self.imageLoader.downloadedImage!)
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                    } else {
                        self.placeholder
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                    }
                }
                // there seems to be some optimization SwiftUI uses for .onAppear() that causes it not be called again when the struct is re-computed/initialized
                //                .onAppear() {
                //                    self.imageLoader.load()
                //                }
                
                HStack(spacing: 0) {
                    Button(action: {
                        self.showModal.toggle()
                    }) {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(a.size.width * 0.07)
                            .foregroundColor(Color.orange)
                    }
                    .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                    .sheet(isPresented: self.$showModal) {
                        GameModalView(game: self.game, imageLoader: ImageLoader(url: self.game.banner, cache: self.cache, whereIsThisFrom: "game modal view, game:" + String(self.game.id)))
                            .environmentObject(self.userDataStore)
                            .environmentObject(self.assetsDataStore)
                            .environmentObject(self.recentFollowDataStore)
                    }
                    
                    NavigationLink(destination: LazyView { ForumView(forumDataStore: ForumDataStore(game: self.game), forumOtherDataStore: ForumOtherDataStore(gameId: self.game.id, userDataStore: self.userDataStore), gameIconLoader: self.imageLoader).onAppear(perform: {
                        Global.tabBar!.isHidden = true
                    })
                    }) {
                        Image(systemName: "text.bubble.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(a.size.width * 0.07)
                        .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                    }
                }
                .background(self.assetsDataStore.colors["notQuiteBlack"]!)
            }
        }
    }
}

// Extra game feed view for time line specifically due to disclosure arrow bug with navigationview
struct GameFeedTimelineIcon : View {
    
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    @Environment(\.imageCache) var cache: ImageCache
    
    @ObservedObject var imageLoader: ImageLoader
    @State private var showModal = false
    
    var game: Game
    let placeholder = Image(systemName: "rectangle.fill")
    
    var body: some View {
        GeometryReader { a in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if self.imageLoader.downloadedImage != nil {
                        Image(uiImage: self.imageLoader.downloadedImage!)
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                    } else {
                        self.placeholder
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                    }
                }
                // there seems to be some optimization SwiftUI uses for .onAppear() that causes it not be called again when the struct is re-computed/initialized
                //                .onAppear() {
                //                    self.imageLoader.load()
                //                }
                
                HStack(spacing: 0) {
                    Button(action: {
                        self.showModal.toggle()
                    }) {
                        Image(systemName: "gamecontroller.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(a.size.width * 0.07)
                            .foregroundColor(Color.orange)
                    }
                    .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                    .sheet(isPresented: self.$showModal) {
                        GameModalView(game: self.game, imageLoader: ImageLoader(url: self.game.banner, cache: self.cache, whereIsThisFrom: "game modal view, game:" + String(self.game.id)))
                            .environmentObject(self.userDataStore)
                            .environmentObject(self.assetsDataStore)
                            .environmentObject(self.recentFollowDataStore)
                    }
                    
                    
                    ZStack {
                        Image(systemName: "text.bubble.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.blue)
                        .padding(a.size.width * 0.07)
                        
                        .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                        
                        NavigationLink(destination: LazyView { ForumView(forumDataStore: ForumDataStore(game: self.game), forumOtherDataStore: ForumOtherDataStore(gameId: self.game.id, userDataStore: self.userDataStore), gameIconLoader: self.imageLoader).onAppear(perform: {
                            Global.tabBar!.isHidden = true
                        })
                        }) {
                            EmptyView()
                        }
                    }
                    
                }
                .background(self.assetsDataStore.colors["notQuiteBlack"]!)
            }
        }
    }
}
