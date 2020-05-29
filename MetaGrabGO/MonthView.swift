//
//  MonthView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-02-28.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct MonthView: View {
    @EnvironmentObject var gameDataStore: GameDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @Environment(\.imageCache) var cache: ImageCache
    
    var year: Int
    var month: Int
    var width: CGFloat
    var height: CGFloat
    
    private let MONTH_ABBREV = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    private let gameIconWidthMultiplier: CGFloat = 0.35
    private let goldenRatioConst: CGFloat = 1.618
    private let widthToHeightRatio: CGFloat = 1.4
    
    private let imageSizeHeightRatio: CGFloat = 0.55
    
    private func checkHasGames(year: Int, month: Int) -> Bool {
        return self.gameDataStore.gamesByYear[year] != nil && self.gameDataStore.gamesByYear[year]![month] != nil
    }
    
    private func getLastIndex(arr: [Int]) -> Int {
        return arr.count - 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.checkHasGames(year: year, month: month) {
                Text(String(self.MONTH_ABBREV[month - 1]))
                    .font(.system(size: 50))
                    .foregroundColor(Color.white)
                    .shadow(radius: 5)
                    .padding(.bottom, 10)
                
                ForEach(0..<self.gameDataStore.sortedDaysListByMonthYear[year]![month]!.count, id: \.self) { dayArrIndex in
                    HStack(alignment: .top, spacing: 0) {
                        Spacer()
                        Text(String(self.gameDataStore.sortedDaysListByMonthYear[self.year]![self.month]![dayArrIndex]))
                            .font(.system(size: 30))
                            .frame(width: self.width * 0.2)
                            .foregroundColor(Color.white)
                        
                        VStack(alignment: .center, spacing: 0) {
                            ForEach(0..<self.gameDataStore.sortedGamesListByDayMonthYear[self.year]![self.month]![self.gameDataStore.sortedDaysListByMonthYear[self.year]![self.month]![dayArrIndex]]!.count, id: \.self) { gameArrIndex in
                                HStack {
                                    GeometryReader { a in
                                        ZStack {
                                            if dayArrIndex != 0 || gameArrIndex != 0 {
                                                ZStack {
                                                    Path { path in
                                                        path.move(to: CGPoint(x: a.size.width * 0.5, y: a.size.height * 0))
                                                        path.addLine(to: CGPoint(x: a.size.width * 0.5, y: a.size.height * 0.5))
                                                    }
                                                    .stroke(Color.white, lineWidth: a.size.width * 0.1)
                                                }
                                            }
                                            
                                            if dayArrIndex != self.getLastIndex(arr: self.gameDataStore.sortedDaysListByMonthYear[self.year]![self.month]!) || gameArrIndex != self.getLastIndex(arr: self.gameDataStore.sortedGamesListByDayMonthYear[self.year]![self.month]![self.gameDataStore.sortedDaysListByMonthYear[self.year]![self.month]![dayArrIndex]]!) {
                                                
                                                ZStack {
                                                    Path { path in
                                                        path.move(to: CGPoint(x: a.size.width * 0.5, y: a.size.height * 0.5))
                                                        path.addLine(to: CGPoint(x: a.size.width * 0.5, y: a.size.height * 1))
                                                    }
                                                    .stroke(Color.white, lineWidth: a.size.width * 0.1)
                                                }
                                            }
                                            
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 15, height: 15)
                                                    .position(x: a.size.width * 0.5, y: a.size.height * 0.5)
                                                    .shadow(radius: 5)
                                                    
                                                Circle()
                                                    .fill(self.assetsDataStore.colors["darkButNotBlack"]!)
                                                    .frame(width: 10, height: 10)
                                                    .position(x: a.size.width * 0.5, y: a.size.height * 0.5)
                                            }
                                            Spacer()
                                        }
                                    }
                                    .frame(width: 50)
                                    
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: self.width * 0.1, height: 1)
                                    
                                    Spacer()
                                    GameFeedIcon(imageLoader: ImageLoader(url: self.gameDataStore.games[self.gameDataStore.sortedGamesListByDayMonthYear[self.year]![self.month]![self.gameDataStore.sortedDaysListByMonthYear[self.year]![self.month]![dayArrIndex]]![gameArrIndex]]!.icon, cache: self.cache, whereIsThisFrom: "popular view, game:" + String(self.gameDataStore.games[self.gameDataStore.sortedGamesListByDayMonthYear[self.year]![self.month]![self.gameDataStore.sortedDaysListByMonthYear[self.year]![self.month]![dayArrIndex]]![gameArrIndex]]!.id)), game: self.gameDataStore.games[self.gameDataStore.sortedGamesListByDayMonthYear[self.year]![self.month]![self.gameDataStore.sortedDaysListByMonthYear[self.year]![self.month]![dayArrIndex]]![gameArrIndex]]!)
                                        .frame(width: self.width * self.gameIconWidthMultiplier, height: self.width * self.gameIconWidthMultiplier * 1 / self.widthToHeightRatio / self.imageSizeHeightRatio)
                                        .shadow(radius: 5)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
