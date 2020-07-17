//
//  GenreRowView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-24.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct GenreRowView: View {
    @EnvironmentObject private var globalGamesDataStore: GlobalGamesDataStore
    @ObservedObject private var genreDataStore: GenreDataStore
    @Environment(\.imageCache) private var cache: ImageCache
    
    private let gameIconWidthMultiplier: CGFloat = 0.35
    private let goldenRatioConst: CGFloat = 1.618
    private let widthToHeightRatio: CGFloat = 1.4
    private let imageSizeHeightRatio: CGFloat = 0.55
    
    private var width: CGFloat
    
    init(genre: Genre, genreDataStore: GenreDataStore, globalGamesDataStore: GlobalGamesDataStore, width: CGFloat) {
        self.genreDataStore = genreDataStore
        self.width = width
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach(self.genreDataStore.gamesArr, id: \.self) { gameId in
                    GameFeedIcon(imageLoader: ImageLoader(url: self.globalGamesDataStore.games[gameId]!.icon, cache: self.cache, whereIsThisFrom: "popular view, game:" + String(gameId)), game: self.globalGamesDataStore.games[gameId]!)
                        .frame(width: self.width * self.gameIconWidthMultiplier, height: self.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio * 0.8)
                    .shadow(radius: 5)
                }
                if self.genreDataStore.nextPageStartIndex != -1 {
                    Button(action: {
                        self.genreDataStore.fetchGamesByGenrePage(start: self.genreDataStore.nextPageStartIndex, count: 5, refresh: false, globalGamesDataStore: self.globalGamesDataStore)
                    }) {
                        LoadMoreGamesIcon(isLoadingGames: self.$genreDataStore.isLoadingGames)
                        .frame(width: self.width * self.gameIconWidthMultiplier, height: self.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio * 0.8)
                        .shadow(radius: 5)
                    }
                }
            }
            .frame(height: self.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio)
        }
    }
}

struct LoadMoreGamesIcon: View {
    @Binding var isLoadingGames: Bool
    
    var body: some View {
        GeometryReader { a in
            VStack(spacing: 0) {
                if self.isLoadingGames == false {
                    ZStack {
                        Color.black
                        VStack(alignment: .center) {
                            Spacer()
                            Text("Load")
                            .bold()
                            .foregroundColor(Color.white)
                            Text("more")
                            .bold()
                            .foregroundColor(Color.white)
                            Text("games")
                            .bold()
                            .foregroundColor(Color.white)
                            Spacer()
                        }
                        
                    }
                } else {
                    ActivityIndicator()
                }
            }
            .frame(width: a.size.width, height: a.size.height * 0.8)
            .cornerRadius(5)
        }
    }
}
