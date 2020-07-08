//
//  PopularGamesView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-12-16.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct PopularGamesView: View {
    @EnvironmentObject var globalGamesDataStore: GlobalGamesDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    
    @ObservedObject var popularListDataStore: PopularListDataStore
    
    init(popularListDataStore: PopularListDataStore) {
        self.popularListDataStore = popularListDataStore
        print("popular games view created")
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
            self.assetsDataStore.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                List {
                    VStack {
                        Text("POPULAR TITLES")
                            .font(.system(size: 30, weight: .regular, design: .rounded))
                            .tracking(2)
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                    }
                    .frame(width: a.size.width * 0.95, alignment: .leading)
                    .padding(.bottom, 10)
                        .padding(.horizontal, 10)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    ForEach(self.popularListDataStore.genresIdArr, id: \.self) { genreId in
                        Group {
                            HStack {
                                Text(self.popularListDataStore.genres[genreId]!.name)
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                                    .tracking(2)
                                    .padding(.top, 10)
                                    .shadow(radius: 5)
                                
                                Text("(" + self.popularListDataStore.genres[genreId]!.longName + ")")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                                    .tracking(2)
                                    .padding(.top, 10)
                                    .shadow(radius: 5)
                            }

                            GenreRowView(access: self.userDataStore.token!.access, genre: self.popularListDataStore.genres[genreId]!, globalGamesDataStore: self.globalGamesDataStore, width: a.size.width - 10, userDataStore: self.userDataStore)
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.horizontal, 10)
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
