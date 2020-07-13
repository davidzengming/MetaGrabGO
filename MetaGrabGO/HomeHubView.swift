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
    
    @ObservedObject var homeGamesDataStore: HomeGamesDataStore
    @ObservedObject var followGamesDataStore: FollowGamesDataStore
    @ObservedObject var visitedGamesDataStore: VisitedGamesDataStore
    @Binding var selectedTab: Int
    
    private let gameIconWidthMultiplier: CGFloat = 0.35
    private let goldenRatioConst: CGFloat = 1.618
    private let widthToHeightRatio: CGFloat = 1.4
    
    private let imageSizeHeightRatio: CGFloat = 0.55
    
    init(homeGamesDataStore: HomeGamesDataStore, followGamesDataStore: FollowGamesDataStore, visitedGamesDataStore: VisitedGamesDataStore, selectedTab: Binding<Int>) {
        self.homeGamesDataStore = homeGamesDataStore
        self.followGamesDataStore = followGamesDataStore
        self.visitedGamesDataStore = visitedGamesDataStore
        self._selectedTab = selectedTab
//        print("front hub view created")
    }
    
    var body: some View {
        ZStack {
            self.assetsDataStore.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                VStack(alignment: .leading) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading) {
                            Text("HOME PAGE")
                                .font(.system(size: a.size.width * 0.05, weight: .regular, design: .rounded))
                                .tracking(2)
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                                .padding(.bottom, 20)
                            
                            Text("RECENTLY VISITED")
                                .foregroundColor(Color.white)
                                .font(.system(size: a.size.width * 0.04, weight: .regular, design: .rounded))
                                .tracking(1)
                            
                            if self.homeGamesDataStore.isLoaded == true && self.visitedGamesDataStore.visitedGamesId.count > 0 {
                                HStack {
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack(spacing: 20) {
                                            ForEach(self.visitedGamesDataStore.visitedGamesId, id: \.self) { gameId in
                                                VStack {
                                                    GameFeedIcon(imageLoader: ImageLoader(url: self.globalGamesDataStore.games[gameId]!.icon, cache: self.cache, whereIsThisFrom: "front view, game:" + String(gameId)), game: self.globalGamesDataStore.games[gameId]!)
                                                        .frame(width: a.size.width * self.gameIconWidthMultiplier, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio * 0.8)
                                                        .shadow(radius: 5)
                                                }
                                            }
                                        }
                                        .frame(height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio)
                                    }
                                }
                                .padding(.bottom, 50)
                            } else {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 10) {
                                        Text("Start exploring by visiting")
                                            .foregroundColor(Color(.lightText))
                                        
                                        HStack(spacing: 10) {
                                            Button(action: { self.selectedTab = 1 }) {
                                                Text("Popular")
                                                    .padding(10)
                                                    .background(Color.red)
                                                    .cornerRadius(5)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            Text("or")
                                            .foregroundColor(Color(.lightText))
                                            
                                            Button(action: { self.selectedTab = 2 }) {
                                                Text("Upcoming")
                                                    .padding(10)
                                                    .background(Color.orange)
                                                    .cornerRadius(5)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .foregroundColor(Color.white)
                                    }
                                    .frame(width: a.size.width * 0.9, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio * 0.8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(
                                                style: StrokeStyle(
                                                    lineWidth: 1,
                                                    dash: [10]
                                                )
                                        )
                                            .foregroundColor(Color(.lightText))
                                    )
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                                .padding(.bottom, 50)
                            }
                            
                            Text("FOLLOWING GAMES")
                                .foregroundColor(Color.white)
                                .font(.system(size: a.size.width * 0.04, weight: .regular, design: .rounded))
                                .tracking(1)
                            
                            if self.homeGamesDataStore.isLoaded == true && self.followGamesDataStore.followedGamesId.count > 0 {
                                Group {
                                    ScrollView(.horizontal, showsIndicators: true) {
                                        HStack(spacing: 20) {
                                            ForEach(self.followGamesDataStore.followedGamesId, id: \.self) { gameId in
                                                VStack {
                                                    GameFeedIcon(imageLoader: ImageLoader(url: self.globalGamesDataStore.games[gameId]!.icon, cache: self.cache, whereIsThisFrom: "front view, game:" + String(gameId)), game: self.globalGamesDataStore.games[gameId]!)
                                                        .frame(width: a.size.width * self.gameIconWidthMultiplier, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio * 0.8)
                                                        .shadow(radius: 5)
                                                }
                                            }
                                        }
                                        .frame(height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio)
                                    }
                                }
                            } else {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 10) {
                                        Text("Add favorite games to your collection")
                                            .foregroundColor(Color(.lightText))
                                        
                                        
                                        HStack(spacing: 10) {
                                            Text("by clicking")
                                                .foregroundColor(Color(.lightText))
                                            
                                            Text("SUB")
                                                .padding(10)
                                                .foregroundColor(Color.white)
                                                .background(Color.black)
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                            
                                            Text("in")
                                                .foregroundColor(Color(.lightText))
                                            
                                            Image(systemName: "text.bubble.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: a.size.width * 0.05)
                                                .foregroundColor(Color.blue)
                                        }
                                        .foregroundColor(Color.white)
                                    }
                                    .frame(width: a.size.width * 0.9, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio * 0.8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(
                                                style: StrokeStyle(
                                                    lineWidth: 1,
                                                    dash: [10]
                                                )
                                        )
                                            .foregroundColor(Color(.lightText))
                                    )
                                    Spacer()
                                }
                                .padding(.vertical, 20)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
                .padding(.vertical, a.size.height * 0.01)
                    
                .onAppear() {
                    Global.tabBar!.isHidden = false
                    
                    if self.recentFollowDataStore.shouldRefreshDataStore == true || self.homeGamesDataStore.isLoaded == false {
//                        print("Fetching follow and visited games history...")
//                        
                        let taskGroup = DispatchGroup()
                        self.homeGamesDataStore.fetchFollowGames(globalGamesDataStore: self.globalGamesDataStore, followGamesDataStore: self.followGamesDataStore, userDataStore: self.userDataStore, recentFollowDataStore: self.recentFollowDataStore, taskGroup: taskGroup)
                        self.homeGamesDataStore.getGameHistory(globalGamesDataStore: self.globalGamesDataStore, visitedGamesDataStore: self.visitedGamesDataStore, recentFollowDataStore: self.recentFollowDataStore, taskGroup: taskGroup, userDataStore: self.userDataStore)
                        
                        taskGroup.notify(queue: .main) {
                            self.homeGamesDataStore.isLoaded = true
                            self.recentFollowDataStore.shouldRefreshDataStore = false
                        }
                        
                    } else {
                        self.homeGamesDataStore.updateFollowGames(followGamesDataStore: self.followGamesDataStore, recentFollowDataStore: self.recentFollowDataStore)
                        
                        self.homeGamesDataStore.updateGameHistory(visitedGamesDataStore: self.visitedGamesDataStore, recentFollowDataStore: self.recentFollowDataStore)
                    }
                    
                }
            }
        }
    }
}
