//
//  PopularGamesView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-12-16.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct PopularGamesView: View {
    @EnvironmentObject private var globalGamesDataStore: GlobalGamesDataStore
    @ObservedObject private var popularListDataStore: PopularListDataStore
    
    init(popularListDataStore: PopularListDataStore) {
        self.popularListDataStore = popularListDataStore
//        print("popular games view created")
        // List related
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        
        // To remove only extra separators below the list:
        UITableView.appearance().tableFooterView = UIView()
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
    }
    
    var body: some View {
        ZStack {
            appWideAssets.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                List {
                    HStack {
                        Spacer()
                        VStack {
                            Text("POPULAR TITLES")
                                .font(.system(size: a.size.width * 0.05, weight: .regular, design: .rounded))
                                .tracking(2)
                                .foregroundColor(Color.white)
                                .shadow(radius: 5)
                        }
                        .frame(width: a.size.width * 0.95, alignment: .leading)
                        .padding(.bottom, 10)
                        Spacer()
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    ForEach(self.popularListDataStore.genresIdArr, id: \.self) { genreId in
                        Group {
                            HStack {
                                Spacer()
                                Text(self.popularListDataStore.genres[genreId]!.name)
                                    .foregroundColor(Color.white)
                                    .font(.system(size: a.size.width * 0.04, weight: .regular, design: .rounded))
                                    .tracking(2)
                                    .padding(.top, 10)
                                    .shadow(radius: 5)
                                .frame(width: a.size.width * 0.95, alignment: .leading)
                                
//                                Text("(" + self.popularListDataStore.genres[genreId]!.longName + ")")
//                                    .foregroundColor(Color.white)
//                                    .font(.system(size: a.size.width * 0.04, weight: .regular, design: .rounded))
//                                    .tracking(2)
//                                    .padding(.top, 10)
//                                    .shadow(radius: 5)
                                Spacer()
                            }
                            
                            
                            .onAppear() {
                                if self.popularListDataStore.genresIdArr.last! == genreId {
                                    self.popularListDataStore.fetchGenresByPage(start: self.popularListDataStore.nextPageStartIndex, globalGamesDataStore: self.globalGamesDataStore)
                                }
                            }
                            
                            HStack {
                                Spacer()
                                GenreRowView(genre: self.popularListDataStore.genres[genreId]!, genreDataStore: self.popularListDataStore.genresDataStore[genreId]!, globalGamesDataStore: self.globalGamesDataStore, width: a.size.width - 10)
                                .frame(width: a.size.width * 0.95, alignment: .leading)
                                Spacer()
                            }
                            
                            
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
                .padding(.vertical, a.size.height * 0.01)
                
            }
        }
        .onAppear() {
            Global.tabBar!.isHidden = false
        }
    }
}
