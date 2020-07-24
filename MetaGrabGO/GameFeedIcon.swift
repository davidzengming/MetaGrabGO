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
    @EnvironmentObject private var recentFollowDataStore: RecentFollowDataStore
    @Environment(\.imageCache) private var cache: ImageCache
    
    @ObservedObject var imageLoader: ImageLoader
    @State private var showModal = false
    
    var game: Game
    
    var body: some View {
        GeometryReader { a in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if self.imageLoader.downloadedImage != nil {
                        Image(uiImage: self.imageLoader.downloadedImage!)
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                    } else {
                        Rectangle()
                            .fill(appWideAssets.colors["darkButNotBlack"]!)
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                            .onAppear() {
                                self.imageLoader.load()
                        }
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
                            .padding(a.size.width * 0.065)
                            .foregroundColor(Color.orange)
                    }
                    .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                    .sheet(isPresented: self.$showModal) {
                        GameModalView(game: self.game, imageLoader: ImageLoader(url: self.game.banner, cache: self.cache, whereIsThisFrom: "game modal view, game:" + String(self.game.id)))
                            .environmentObject(self.recentFollowDataStore)
                    }
                    
                    NavigationLink(destination: LazyView { ForumView(forumDataStore: ForumDataStore(game: self.game), forumOtherDataStore: ForumOtherDataStore(gameId: self.game.id), gameIconLoader: self.imageLoader).onAppear(perform: {
                        Global.tabBar!.isHidden = true
                    })
                    }) {
                        Image(systemName: "text.bubble.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(a.size.width * 0.065)
                        .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                    }
                }
                .background(appWideAssets.colors["notQuiteBlack"]!)
            }
        }
    }
}

// Extra game feed view for time line specifically due to disclosure arrow bug with navigationview
struct GameFeedTimelineIcon : View {
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    @Environment(\.imageCache) var cache: ImageCache
    
    @ObservedObject var imageLoader: ImageLoader
    @State private var showModal = false
    
    var game: Game
    
    init(imageLoader: ImageLoader, game: Game) {
        self.imageLoader = imageLoader
        self.game = game
    }
    
    var body: some View {
        GeometryReader { a in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    if self.imageLoader.downloadedImage != nil {
                        Image(uiImage: self.imageLoader.downloadedImage!)
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                    } else {
                        Rectangle()
                            .fill(appWideAssets.colors["darkButNotBlack"]!)
                            .frame(width: a.size.width, height: a.size.height * 0.75)
                            .onAppear() {
                                self.imageLoader.load()
                            }
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
                            .padding(a.size.width * 0.065)
                            .foregroundColor(Color.orange)
                    }
                    .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                    .sheet(isPresented: self.$showModal) {
                        GameModalView(game: self.game, imageLoader: ImageLoader(url: self.game.banner, cache: self.cache, whereIsThisFrom: "game modal view, game:" + String(self.game.id)))
                            .environmentObject(self.recentFollowDataStore)
                    }
                    
                    ZStack {
                        Image(systemName: "text.bubble.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.blue)
                        .padding(a.size.width * 0.065)
                        
                        .frame(width: a.size.width / 2, height: a.size.height * 0.25)
                        
                        NavigationLink(destination: LazyView { ForumView(forumDataStore: ForumDataStore(game: self.game), forumOtherDataStore: ForumOtherDataStore(gameId: self.game.id), gameIconLoader: self.imageLoader).onAppear(perform: {
                            Global.tabBar!.isHidden = true
                        })
                        }) {
                            EmptyView()
                        }
                        .frame(width: 0)
                        .opacity(0)
                    }
                    
                }
                .background(appWideAssets.colors["notQuiteBlack"]!)
            }
        }
    }
}
