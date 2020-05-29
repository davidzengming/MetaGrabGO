//
//  PopularGamesView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-12-16.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct PopularGamesView: View {
    @EnvironmentObject var gameDataStore: GameDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @Environment(\.imageCache) var cache: ImageCache
    
    private let gameIconWidthMultiplier: CGFloat = 0.35
    private let goldenRatioConst: CGFloat = 1.618
    private let widthToHeightRatio: CGFloat = 1.4
    
    private let imageSizeHeightRatio: CGFloat = 0.55
    
    var body: some View {
        ZStack {
            self.assetsDataStore.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                VStack(alignment: .leading) {
                    VStack {
                        Text("POPULAR")
                            .font(.title)
                            .tracking(2)
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                    }
                    .frame(width: a.size.width * 0.95, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    // There's a bug with scrollview - list, using forEach for now
                    // Bug 2 - If there is only my VStack inside ScrollView, it does not appear until I have clicked/dragged near the area then it appears. Works fine with the HStack inside here for some reason.
                    ScrollView(.vertical, showsIndicators: true) {
                        if self.gameDataStore.genreGameArray.count != 0 {
                            VStack {
                                ForEach(self.gameDataStore.genreGameArray.keys.sorted(), id: \.self) { key in
                                    VStack(alignment: .leading, spacing: 0) {
                                        if self.gameDataStore.genreGameArray[key]!.count > 0 {
                                            Text(self.gameDataStore.genres[key]!.name)
                                                .foregroundColor(Color.white)
                                                .tracking(1)
                                                .padding(.top, 10)
                                                .shadow(radius: 5)
                                            
                                            HStack {
                                                Image(systemName: "chevron.left")
                                                    .foregroundColor(Color.white)
                                                    .padding(5)
                                                    .background(LinearGradient(gradient: Gradient(colors: [.blue, self.assetsDataStore.colors["darkButNotBlack"]!]), startPoint: .trailing, endPoint: .leading))
                                                
                                                ScrollView(.horizontal, showsIndicators: true) {
                                                    HStack(spacing: 20) {
                                                        ForEach(self.gameDataStore.genreGameArray[key]!, id: \.self) { gameId in
                                                            GameFeedIcon(imageLoader: ImageLoader(url: self.gameDataStore.games[gameId]!.icon, cache: self.cache, whereIsThisFrom: "popular view, game:" + String(gameId)), game: self.gameDataStore.games[gameId]!)
                                                                .frame(width: a.size.width * self.gameIconWidthMultiplier, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio)
                                                                .shadow(radius: 5)
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 5)
                                                
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(Color.white)
                                                    .padding(5)
                                                    .background(LinearGradient(gradient: Gradient(colors: [.blue, self.assetsDataStore.colors["darkButNotBlack"]!]), startPoint: .leading, endPoint: .trailing))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, a.size.height * 0.05)
                .padding(.horizontal, 10)
            }
        }
        .onAppear() {
            Global.tabBar!.isHidden = false
        }
    }
}
