//
//  TimelineGamesView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-12-16.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct TimelineGamesView: View {
    @EnvironmentObject var gameDataStore: GameDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    
    private let date = Date()
    private let calendar = Calendar.current
    
    private let months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    
    private func calcRangeStartMonth() -> Int {
        return (calendar.component(.month, from: date) - 2)
    }
    
    private func getCurrentYear() -> Int {
        return (calendar.component(.year, from: date))
    }
    
    private func getCurrentMonth() -> Int {
        return (calendar.component(.month, from: date))
    }
    
    private func mod(_ a: Int, _ n: Int) -> Int {
        precondition(n > 0, "modulus must be positive")
        let r = a % n
        return r >= 0 ? r : r + n
    }
    
    private func checkHasGames(year: Int, month: Int) -> Bool {
        return self.gameDataStore.gamesByYear[year] != nil && self.gameDataStore.gamesByYear[year]![month] != nil
    }
    
    private func checkPrevMonthsHasGamesRelease() -> Bool {
        for month in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].suffix(mod(calcRangeStartMonth(), 12)) {
            if checkHasGames(year: self.getCurrentYear() - 1, month: month) {
                return true
            }
        }
        return false
    }
    
    // Lists recent games is past 2 months and upcoming games 1 year down the road
    var body: some View {
        ZStack {
            self.assetsDataStore.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                VStack {
                    VStack {
                        Text("RELEASE TIMELINE")
                            .font(.title)
                            .tracking(2)
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                    }
                    .frame(width: a.size.width * 0.95, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        HStack {
                            VStack(alignment: .leading, spacing: 0) {
                                // Previous year
                                if self.checkPrevMonthsHasGamesRelease() == true {
                                    Text(String(self.getCurrentYear() - 1))
                                    ForEach(self.months.suffix(self.mod(self.calcRangeStartMonth(), 12)), id: \.self) { month in
                                        MonthView(year: self.getCurrentYear() - 1, month: month, width: a.size.width, height: a.size.height)
                                    }
                                }
                                
                                Text(String(self.getCurrentYear()))
                                    .font(.system(size: 120))
                                    .foregroundColor(Color.white)
                                    .shadow(radius: 5)
                                // Current year
                                ForEach(self.months, id: \.self) { month in
                                    MonthView(year: self.getCurrentYear(), month: month, width: a.size.width, height: a.size.height)
                                }
                                
                                // Next year
                                if self.gameDataStore.hasGameByYear[self.getCurrentYear() + 1] != nil && self.calcRangeStartMonth() > 1 {
                                    Text(String(self.getCurrentYear() + 1))
                                        .font(.system(size: 120))
                                        .foregroundColor(Color.white)
                                        .shadow(radius: 5)
                                    ForEach(self.months.prefix(self.getCurrentMonth()), id: \.self) { month in
                                        MonthView(year: self.getCurrentYear() + 1, month: month, width: a.size.width, height: a.size.height)
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
