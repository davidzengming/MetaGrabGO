//
//  GameModalView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-30.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct GameModalView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Environment(\.imageCache) var cache: ImageCache
    @ObservedObject private var imageLoader: ImageLoader
    var game: Game
    let placeholder = Image(systemName: "rectangle.fill")
    
    init(game: Game, imageLoader: ImageLoader) {
        self.game = game
        self.imageLoader = imageLoader
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { a in
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Image(systemName: "multiply")
                            .resizable()
                            .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                            .foregroundColor(.white)
                            .onTapGesture {
                                self.presentationMode.wrappedValue.dismiss()
                        }
                        Spacer()
                    }
                    .frame(width: a.size.width * 0.9, height: a.size.height * 0.05, alignment: .leading)
                        
                    .padding(.horizontal, a.size.width * 0.05)
                    .padding(.vertical, a.size.height * 0.01)
                    
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
                                            .frame(width: a.size.width * 0.8, height: a.size.height * 0.2)
                                            .scaledToFill()
                                            .shadow(radius: 5)
                                    } else {
                                        self.placeholder
                                            .resizable()
                                            .frame(width: a.size.width * 0.8, height: a.size.height * 0.2)
                                            .scaledToFill()
                                            .shadow(radius: 5)
                                    }
                                }
                                .frame(width: a.size.width * 0.9, height: a.size.height * 0.15)
                                .background(self.assetsDataStore.colors["notQuiteBlack"]!)
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
                                .frame(width: a.size.width * 0.9, height: 1)
                                .foregroundColor(.clear)
                                .background(LinearGradient(gradient: Gradient(colors: [.blue, self.assetsDataStore.colors["notQuiteBlack"]!]), startPoint: .leading, endPoint: .trailing))
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
                                            .font(.system(size: 16))
                                            .tracking(1)
                                            .foregroundColor(Color.gray)
                                        
                                        Text(self.game.genre.name)
                                            .font(.system(size: 16))
                                            .tracking(1)
                                            .foregroundColor(Color(UIColor.systemTeal))
                                    }
                                    .padding(.vertical, 5)
                                    
                                    HStack {
                                        Text("DEVELOPER: ")
                                            .font(.system(size: 16))
                                            .tracking(1)
                                            .foregroundColor(Color.gray)
                                        
                                        Text(self.game.developer.name)
                                            .font(.system(size: 16))
                                            .tracking(1)
                                            .foregroundColor(Color(UIColor.systemTeal))
                                    }
                                    .padding(.vertical, 5)
                                    
                                    HStack {
                                        Text("PUBLISHER: ")
                                            .font(.system(size: 16))
                                            .tracking(1)
                                            .foregroundColor(Color.gray)
                                        
                                        Text(self.game.developer.name)
                                            .font(.system(size: 16))
                                            .tracking(1)
                                            .foregroundColor(Color(UIColor.systemTeal))
                                    }
                                    .padding(.vertical, 5)
                                    
                                    Spacer()
                                    HStack {
                                        NavigationLink(destination: LazyView { ForumView(forumDataStore: ForumDataStore(game: self.game), forumOtherDataStore: ForumOtherDataStore(gameId: self.game.id, userDataStore: self.userDataStore) , gameIconLoader: ImageLoader(url: self.game.icon, cache: self.cache, whereIsThisFrom: "modal to forum view, game:" + String(self.game.id)))
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
                                    .background(self.assetsDataStore.colors["darkButNotBlack"]!)
                                }
                                .padding()
                            }
                            .frame(width: a.size.width * 0.9, alignment: .leading)
                            .background(self.assetsDataStore.colors["notQuiteBlack"]!)
                            .padding()
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .background(self.assetsDataStore.colors["darkButNotBlack"]!)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
