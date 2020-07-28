//
//  GameModalView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-30.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct GameModalView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @Environment(\.imageCache) private var cache: ImageCache
    @ObservedObject private var imageLoader: ImageLoader
    private var game: Game
    
    init(game: Game, imageLoader: ImageLoader) {
        self.game = game
        self.imageLoader = imageLoader
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { a in
                VStack(alignment: .center) {
                    HStack {
                        Image(systemName: "multiply")
                            .resizable()
                            .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                            .foregroundColor(.white)
                            .onTapGesture {
                                self.presentationMode.wrappedValue.dismiss()
                        }
                        Spacer()
                    }
                    .frame(width: a.size.width * 0.95, height: a.size.height * 0.05, alignment: .leading)
                    .padding(.top, a.size.height * 0.01)
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(self.game.name.uppercased())
                                .tracking(2)
                                .foregroundColor(Color.white)
                                .padding(.horizontal)
                                .font(.system(size: 30))
                            
                            HStack {
                                Spacer()
                                VStack {
                                    if self.imageLoader.downloadedImage != nil {
                                        Image(uiImage: self.imageLoader.downloadedImage!)
                                            .resizable()
                                            .frame(width: a.size.width * 0.7, height: a.size.width * 0.7 * 9 / 16)
                                            .shadow(radius: 5)
                                    } else {
                                        Rectangle()
                                            .fill(appWideAssets.colors["darkButNotBlack"]!)
                                            .frame(width: a.size.width * 0.7, height: a.size.width * 0.7 * 9 / 16)
                                            .shadow(radius: 5)
                                    }
                                }
                                .frame(width: a.size.width * 0.95, height: a.size.width * 0.7 * 0.5)
                                .background(appWideAssets.colors["notQuiteBlack"]!)
                                Spacer()
                            }
                            .padding(.vertical, 20)
                            .onAppear() {
                                self.imageLoader.load()
                            }
                            
                            Text("ABOUT THIS GAME")
                                .tracking(1)
                                .foregroundColor(Color.white)
                                .padding(.top)
                                .padding(.horizontal)
                            
                            Rectangle()
                                .frame(width: a.size.width * 0.95, height: 1)
                                .foregroundColor(.clear)
                                .background(LinearGradient(gradient: Gradient(colors: [.blue, appWideAssets.colors["notQuiteBlack"]!]), startPoint: .leading, endPoint: .trailing))
                                .padding(.horizontal)
                            
                            VStack {
                                Text(self.game.gameSummary)
                                    .foregroundColor(Color.white)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("GENRE: ")
                                            .font(.headline)
                                            .foregroundColor(Color.gray)
                                        
                                        Text(self.game.genre.name)
                                            .font(.headline)
                                            .foregroundColor(Color(UIColor.systemTeal))
                                    }
                                    .padding(.vertical, 5)
                                    
                                    HStack {
                                        Text("DEVELOPER: ")
                                            .font(.headline)
                                            .foregroundColor(Color.gray)
                                        
                                        Text(self.game.developer.name)
                                            .font(.headline)
                                            .foregroundColor(Color(UIColor.systemTeal))
                                    }
                                    .padding(.vertical, 5)
                                    
//                                    HStack {
//                                        Text("PUBLISHER: ")
//                                            .font(.headline)
//                                            .foregroundColor(Color.gray)
//                                        
//                                        Text(self.game.developer.name)
//                                            .font(.headline)
//                                            .foregroundColor(Color(UIColor.systemTeal))
//                                    }
//                                    .padding(.vertical, 5)
//                                    
                                    Spacer()
                                    HStack {
                                        NavigationLink(destination: LazyView { ForumView(forumDataStore: ForumDataStore(game: self.game), forumOtherDataStore: ForumOtherDataStore(gameId: self.game.id) , gameIconLoader: ImageLoader(url: self.game.icon, cache: self.cache, whereIsThisFrom: "modal to forum view, game:" + String(self.game.id)))
                                            .onAppear(perform: {
                                                Global.tabBar!.isHidden = true
                                            })
                                            }
                                        ) {
                                            HStack {
                                                Text("Visit discussion")
                                                    .tracking(1)
                                            }
                                            .foregroundColor(Color.white)
                                            .padding(.horizontal)
                                            .padding(.vertical, 10)
                                            .shadow(radius: 5)
                                        }
                                        Spacer()
                                    }
                                    .background(appWideAssets.colors["darkButNotBlack"]!)
                                }
                                .padding()
                            }
                            .frame(width: a.size.width * 0.95, alignment: .leading)
                            .background(appWideAssets.colors["notQuiteBlack"]!)
                            .padding()
                            
                            Spacer()
                        }
                    }
                    .frame(width: a.size.width * 0.95)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .background(appWideAssets.colors["darkButNotBlack"]!)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
