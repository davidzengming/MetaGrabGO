//
//  MainHubView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-29.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct FrontHubView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @Environment(\.imageCache) var cache: ImageCache
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    @EnvironmentObject var globalGamesDataStore: GlobalGamesDataStore
    
    @ObservedObject var frontGamesDataStore: FrontGamesDataStore
    @ObservedObject var followGamesDataStore: FollowGamesDataStore
    @ObservedObject var visitedGamesDataStore: VisitedGamesDataStore
    
    private let gameIconWidthMultiplier: CGFloat = 0.35
    private let goldenRatioConst: CGFloat = 1.618
    private let widthToHeightRatio: CGFloat = 1.4
    
    private let imageSizeHeightRatio: CGFloat = 0.55
    
    init(frontGamesDataStore: FrontGamesDataStore, followGamesDataStore: FollowGamesDataStore, visitedGamesDataStore: VisitedGamesDataStore) {
        self.frontGamesDataStore = frontGamesDataStore
        self.followGamesDataStore = followGamesDataStore
        self.visitedGamesDataStore = visitedGamesDataStore
        print("front hub view created")
    }
    
    var body: some View {
        ZStack {
            self.assetsDataStore.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                VStack(alignment: .leading) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading) {
                            Text("FRONT PAGE")
                                .font(.title)
                                .tracking(2)
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                                .frame(width: a.size.width * 0.95, alignment: .leading)
                                .padding(.bottom, 20)
                            
                            Text("RECENTLY VISITED")
                                .foregroundColor(Color.white)
                                .tracking(1)
                            
                            if self.frontGamesDataStore.isLoaded == true {
                                HStack {
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack(spacing: 20) {
                                            if self.visitedGamesDataStore.visitedGamesId.count == 0 {
                                                Text("No recent visited games.")
                                            } else {
                                                ForEach(self.visitedGamesDataStore.visitedGamesId, id: \.self) { gameId in
                                                    VStack {
                                                        GameFeedIcon(imageLoader: ImageLoader(url: self.globalGamesDataStore.games[gameId]!.icon, cache: self.cache, whereIsThisFrom: "front view, game:" + String(gameId)), game: self.globalGamesDataStore.games[gameId]!)
                                                            .frame(width: a.size.width * self.gameIconWidthMultiplier, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio)
                                                            .shadow(radius: 5)
                                                        
                                                        Text(self.globalGamesDataStore.games[gameId]!.isFollowed != nil ? "followed" : "not - followed")
                                                    }
                                                }
                                            }
                                        }
                                        .frame(height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio + 50)
                                    }
                                    .padding(.horizontal, 5)
                                }
                                .padding(.bottom, 10)
                            }
                            
                            
                            Text("FOLLOWED GAMES")
                                .foregroundColor(Color.white)
                                .tracking(1)
                            
                            if self.frontGamesDataStore.isLoaded == true {
                                HStack {
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack(spacing: 20) {
                                            if self.followGamesDataStore.followedGamesId.count == 0 {
                                                Text("No followed games.")
                                            }else {
                                                ForEach(self.followGamesDataStore.followedGamesId, id: \.self) { gameId in
                                                    VStack {
                                                        GameFeedIcon(imageLoader: ImageLoader(url: self.globalGamesDataStore.games[gameId]!.icon, cache: self.cache, whereIsThisFrom: "front view, game:" + String(gameId)), game: self.globalGamesDataStore.games[gameId]!)
                                                            .frame(width: a.size.width * self.gameIconWidthMultiplier, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio)
                                                            .shadow(radius: 5)
                                                        Text(self.globalGamesDataStore.games[gameId]!.isFollowed != nil ? "followed" : "not - followed")
                                                            .onTapGesture {
                                                                self.globalGamesDataStore.games[gameId]!.isFollowed = nil
                                                        }
                                                    }
                                                }
                                            }
                                            
                                        }
                                        .frame(height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio + 50)
                                    }
                                    .padding(.horizontal, 5)
                                }
                            }
                            
                        }
                    }
                }
                .padding(.vertical, a.size.height * 0.05)
                .padding(.horizontal, 10)
                .onAppear() {
                    Global.tabBar!.isHidden = false
                    
                    if self.frontGamesDataStore.isLoaded == false {
                        print("Fetching follow and visited games history...")
                        
                        let taskGroup = DispatchGroup()
                        self.frontGamesDataStore.fetchFollowGames(globalGamesDataStore: self.globalGamesDataStore, followGamesDataStore: self.followGamesDataStore, access: self.userDataStore.token!.access, userDataStore: self.userDataStore, recentFollowDataStore: self.recentFollowDataStore, taskGroup: taskGroup)
                        self.frontGamesDataStore.getGameHistory(globalGamesDataStore: self.globalGamesDataStore, visitedGamesDataStore: self.visitedGamesDataStore, access: self.userDataStore.token!.access, recentFollowDataStore: self.recentFollowDataStore, taskGroup: taskGroup)
                        
                        taskGroup.notify(queue: .main) {
                            self.frontGamesDataStore.isLoaded = true
                        }
                        
                    } else {
                        self.frontGamesDataStore.updateFollowGames(followGamesDataStore: self.followGamesDataStore, recentFollowDataStore: self.recentFollowDataStore)
                        
                        self.frontGamesDataStore.updateGameHistory(visitedGamesDataStore: self.visitedGamesDataStore, recentFollowDataStore: self.recentFollowDataStore)
                    }
                    
                }
            }
        }
    }
}
