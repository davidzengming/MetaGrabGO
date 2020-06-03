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
    
    @EnvironmentObject var gameDataStore: GameDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @Environment(\.imageCache) var cache: ImageCache
    
    @ObservedObject var imageLoader: ImageLoader
    @State private var showModal = false
    
    var game: Game
    let placeholder: Image = Image(systemName: "photo")
    
    var body: some View {
        GeometryReader { a in
            VStack(spacing: 0) {
                HStack {
                    if self.imageLoader.downloadedImage != nil {
                        Image(uiImage: self.imageLoader.downloadedImage!)
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.6)
                    } else {
                        self.placeholder
                            .resizable()
                            .frame(width: a.size.width, height: a.size.height * 0.6)
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
                            .frame(width: a.size.width / 2, height: a.size.height * 0.2)
                    }
                    .sheet(isPresented: self.$showModal) {
                        GameModalView(game: self.game, imageLoader: ImageLoader(url: self.game.banner, cache: self.cache, whereIsThisFrom: "game modal view, game:" + String(self.game.id)))
                            .environmentObject(self.gameDataStore)
                            .environmentObject(self.userDataStore)
                            .environmentObject(self.assetsDataStore)
                    }
                    
                    NavigationLink(destination: LazyView { ForumView(forumDataStore: ForumDataStore(game: self.game, isFollowed: self.gameDataStore.isFollowed[self.game.id]!), gameIconLoader: self.imageLoader).onAppear(perform: {
                        Global.tabBar!.isHidden = true
                    })
                        }) {
                            Image(uiImage: UIImage(systemName: "text.bubble.fill")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(a.size.width * 0.07)
                                .frame(width: a.size.width / 2, height: a.size.height * 0.2)
                    }
                }
                .background(self.assetsDataStore.colors["notQuiteBlack"]!)
            }
        }
    }
}
