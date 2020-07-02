//
//  TimelineGamesView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-12-16.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

struct TimelineGamesView: View {
    @EnvironmentObject var globalGamesDataStore: GlobalGamesDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    @Environment(\.imageCache) var cache: ImageCache
    
    @ObservedObject var timelineDataStore: TimelineDataStore
    
    private let gameIconWidthMultiplier: CGFloat = 0.35
    private let goldenRatioConst: CGFloat = 1.618
    private let widthToHeightRatio: CGFloat = 1.4
    
    private let imageSizeHeightRatio: CGFloat = 0.55
    
    init(timelineDataStore: TimelineDataStore) {
        self.timelineDataStore = timelineDataStore
        print("timeline view created")
        
        // List related
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
        // To remove only extra separators below the list:
        UITableView.appearance().tableFooterView = UIView()
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
        
        //        UITableView.appearance().separatorColor = .clear
    }
    
    func loadPrevPage() {
        if self.timelineDataStore.isLoadingPrev == true {
            return
        }
        self.timelineDataStore.fetchGamesByBeforeEpochTime(access: self.userDataStore.token!.access, globalGamesDataStore: self.globalGamesDataStore)
    }
    
    func loadNextPage() {
        if self.timelineDataStore.isLoadingAfter == true {
            return
        }
        self.timelineDataStore.fetchGamesByAfterEpochTime(access: self.userDataStore.token!.access, globalGamesDataStore: self.globalGamesDataStore)
    }
    
    // Lists recent games is past 2 months and upcoming games 1 year down the road
    var body: some View {
        ZStack {
            self.assetsDataStore.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader() { a in
                List {
                    if self.timelineDataStore.gamesArr.count > 0 && self.timelineDataStore.hasPrevPage == true {
                        DummyLoadView()
                            .onAppear() {
                                self.loadPrevPage()
                        }
                    }
                    
                    ForEach(self.timelineDataStore.gamesArr, id: \.self) { gameId in
                        Group {
                            if self.timelineDataStore.gamesCalendars[gameId]!.isShowingYear {
                                HStack {
                                    Text(String(self.timelineDataStore.gamesCalendars[gameId]!.year))
                                        .tracking(5)
                                        .font(.system(size: 50, weight: .regular, design: .rounded))
                                        .foregroundColor(Color.white)
                                        .shadow(radius: 5)
                                        .padding(.horizontal, 20)
                                    
                                    Spacer()
                                }
                            }
                            
                            if self.timelineDataStore.gamesCalendars[gameId]!.isShowingMonth {
                                HStack(spacing: 0) {
                                    Text(self.timelineDataStore.monthDict[self.timelineDataStore.gamesCalendars[gameId]!.month]!.substring(with: 0..<3).uppercased())
                                        .font(.system(size: 30, weight: .regular, design: .rounded))
                                        .tracking(1)
                                        .foregroundColor(Color.white)
                                        .shadow(radius: 5)
                                        .padding(.leading, 20)
                                        .padding(.bottom, 10)
                                    
                                    Text(self.timelineDataStore.monthDict[self.timelineDataStore.gamesCalendars[gameId]!.month]!.substring(with: 3..<self.timelineDataStore.monthDict[self.timelineDataStore.gamesCalendars[gameId]!.month]!.count).uppercased())
                                        .font(.system(size: 30, weight: .regular, design: .rounded))
                                        .tracking(1)
                                        .foregroundColor(Color.gray)
                                        .shadow(radius: 5)
                                        .padding(.bottom, 10)
                                        .padding(.trailing, 20)
                                    
                                    Spacer()
                                }
                            }
                            
                            HStack {
                                Spacer()
                                VStack(alignment: .center) {
                                    if self.timelineDataStore.gamesCalendars[gameId]!.isShowingDay {
                                        Text(String(self.timelineDataStore.gamesCalendars[gameId]!.day))
                                            .font(.system(size: 22, weight: .regular, design: .rounded))
                                            .tracking(1)
                                            .frame(width: a.size.width * 0.2)
                                            .foregroundColor(Color.white)
                                        
                                    }
                                }
                                .frame(width: 50)
                                
                                GeometryReader { b in
                                    ZStack {
                                        if self.timelineDataStore.gamesCalendars[gameId]!.isShowingMonth == false {
                                            ZStack {
                                                Path { path in
                                                    path.move(to: CGPoint(x: b.size.width * 0.5, y: b.size.height * 0))
                                                    path.addLine(to: CGPoint(x: b.size.width * 0.5, y: b.size.height * 0.5))
                                                }
                                                .stroke(Color.white, lineWidth: b.size.width * 0.1)
                                            }
                                        }
                                        
                                        if self.timelineDataStore.gamesCalendars[gameId]!.isLastDayInMonth == false {
                                            ZStack {
                                                Path { path in
                                                    path.move(to: CGPoint(x: b.size.width * 0.5, y: b.size.height * 0.5))
                                                    path.addLine(to: CGPoint(x: b.size.width * 0.5, y: b.size.height * 1))
                                                }
                                                .stroke(Color.white, lineWidth: b.size.width * 0.1)
                                            }
                                        }
                                        
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 15, height: 15)
                                                .position(x: b.size.width * 0.5, y: b.size.height * 0.5)
                                                .shadow(radius: 5)
                                            
                                            Circle()
                                                .fill(self.assetsDataStore.colors["darkButNotBlack"]!)
                                                .frame(width: 10, height: 10)
                                                .position(x: b.size.width * 0.5, y: b.size.height * 0.5)
                                                .shadow(radius: 5)
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: 50)
                                
                                
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(width: a.size.width * 0.1, height: 1)
                                .shadow(radius: 5)
                                
                                Spacer()
                                
                                GameFeedTimelineIcon(imageLoader: ImageLoader(url: self.globalGamesDataStore.games[gameId]!.icon, cache: self.cache, whereIsThisFrom: "timeline view, game:" + String(gameId)), game: self.globalGamesDataStore.games[gameId]!)
                                    .frame(width: a.size.width * self.gameIconWidthMultiplier, height: a.size.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio * 0.8)
                                    .padding(.vertical, 10)
                                .shadow(radius: 5)
                                
                                Spacer()
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.horizontal, 10)
                    }
                }
                
                if self.timelineDataStore.gamesArr.count > 0 && self.timelineDataStore.hasNextPage == true {
                    DummyLoadView()
                        .onAppear() {
                            self.loadNextPage()
                    }
                }
            }
        }
        .onAppear() {
            Global.tabBar!.isHidden = false
            if self.timelineDataStore.fetchFirstLoad == false {
                self.timelineDataStore.fetchFirstLoad = true
                self.timelineDataStore.fetchFirstLoadAtEpochTime(access: self.userDataStore.token!.access, globalGamesDataStore: self.globalGamesDataStore)
            }
        }
    }
}

struct DummyLoadView: View {
    var body: some View {
        EmptyView()
    }
}
