//
//  UnblockContentView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-07-30.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct UnblockContentView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @ObservedObject var blockHiddenDataStore: BlockHiddenDataStore
    
    @State private var loadedBlacklist = false
    @State private var loadedHiddenThreads = false
    @State private var loadedHiddenComments = false

    init(blockHiddenDataStore: BlockHiddenDataStore) {
        self.blockHiddenDataStore = blockHiddenDataStore
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
//
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        
        // For navigation bar background color
        UINavigationBar.appearance().barTintColor = appWideAssets.uiColors["darkButNotBlack"]!
        //        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default) //makes status bar translucent
        UINavigationBar.appearance().tintColor = .white
    }
    
    private func unblockUser(unblockUser: User) {
        self.blockHiddenDataStore.unblockUser(targetUnblockUser: unblockUser)
    }
    
    private func unhideThread(threadId: Int) {
        self.blockHiddenDataStore.unhideThread(threadId: threadId)
    }
    
    private func unhideComment(commentId: Int) {
        self.blockHiddenDataStore.unhideComment(commentId: commentId)
    }
    
    private func fetchBlacklistedUsers() {
        self.blockHiddenDataStore.fetchBlacklistedUsers()
        self.loadedBlacklist = true
    }
    
    private func fetchHiddenThreads() {
        self.blockHiddenDataStore.fetchHiddenThreads()
        self.loadedHiddenThreads = true
    }
    
    private func fetchHiddenComments() {
        self.blockHiddenDataStore.fetchHiddenComments()
        self.loadedHiddenComments = true
    }
    
    
    var body: some View {
        ZStack {
            appWideAssets.colors["notQuiteBlack"]!.edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                List {
                    Spacer()
                    VStack {
                        Text("BLACKLISTED USERS")
                            .tracking(1)
                            .padding()
                            .frame(width: a.size.width, height: a.size.height * 0.05, alignment: .leading)
                            .background(appWideAssets.colors["teal"]!)
                        
                        if self.blockHiddenDataStore.isLoadingBlockUsers {
                            HStack {
                                Spacer()
                                ActivityIndicator()
                                    .frame(width: a.size.width * 0.2)
                                Spacer()
                            }
                            
                        } else {
                            if self.loadedBlacklist == false {
                                Button(action: self.fetchBlacklistedUsers) {
                                    Text("Show blacklisted users")
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding()
                            } else if self.loadedBlacklist == true && self.blockHiddenDataStore.blacklistedUserIdArr.isEmpty {
                                Text("There are no blacklisted users.")
                                    .padding()
                            } else {
                                ForEach(self.blockHiddenDataStore.blacklistedUserIdArr, id: \.self) { blacklistedUserId in
                                    HStack {
                                        Text(String(self.blockHiddenDataStore.blacklistedUsersById[blacklistedUserId]!.username))
                                        HStack(alignment: .center) {
                                            Image(systemName: "multiply")
                                                .resizable()
                                                .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                                                .foregroundColor(.red)
                                                .onTapGesture {
                                                    self.unblockUser(unblockUser: self.blockHiddenDataStore.blacklistedUsersById[blacklistedUserId]!)
                                            }
                                        }
                                        
                                    }
                                    .padding()
                                }
                            }
                        }
                    }
                    .frame(width: a.size.width)
                    .padding(.vertical)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(appWideAssets.colors["notQuiteBlack"]!)

                    
                    VStack {
                        Text("HIDDEN THREADS")
                            .tracking(1)
                            .padding()
                            .frame(width: a.size.width, height: a.size.height * 0.05, alignment: .leading)
                            .background(appWideAssets.colors["teal"]!)
                        
                        if self.blockHiddenDataStore.isLoadingThreads {
                            HStack {
                                Spacer()
                                ActivityIndicator()
                                    .frame(width: a.size.width * 0.2)
                                Spacer()
                            }
                        } else {
                            if self.loadedHiddenThreads == false {
                                Button(action: self.fetchHiddenThreads) {
                                    Text("Show hidden threads")
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
                                }
                                    .buttonStyle(PlainButtonStyle())
                                .padding()
                                
                            } else if self.loadedHiddenThreads == true && self.blockHiddenDataStore.hiddenThreadIdArr.isEmpty {
                                Text("There are no hidden threads.")
                                    .padding()
                            } else {
                                ForEach(self.blockHiddenDataStore.hiddenThreadIdArr, id: \.self) { hiddenThreadId in
                                    HStack {
                                        Text(self.blockHiddenDataStore.hiddenThreadsById[hiddenThreadId]!.contentString)
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                                            .foregroundColor(.red)
                                            .onTapGesture {
                                                self.unhideThread(threadId: hiddenThreadId)
                                        }
                                    }.padding()
                                }
                            }
                        }
                    }
                    .frame(width: a.size.width)
                    .padding(.vertical)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(appWideAssets.colors["notQuiteBlack"]!)
                    
                    VStack {
                        Text("HIDDEN COMMENTS")
                            .tracking(1)
                            .padding()
                            .frame(width: a.size.width, height: a.size.height * 0.05, alignment: .leading)
                            .background(appWideAssets.colors["teal"]!)
                        
                        if self.blockHiddenDataStore.isLoadingComments == true {
                            HStack {
                                Spacer()
                                ActivityIndicator()
                                    .frame(width: a.size.width * 0.2)
                                Spacer()
                            }
                        } else {
                            if self.loadedHiddenComments == false {
                                Button(action: self.fetchHiddenComments) {
                                    Text("Show hidden comments")
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(Color.white)
                                        .cornerRadius(10)
                                }
                                    .buttonStyle(PlainButtonStyle())
                                .padding()
                            } else if self.loadedHiddenComments == true && self.blockHiddenDataStore.hiddenCommentIdArr.isEmpty {
                                Text("There are no hidden comments.")
                                    .padding()
                            } else {
                                ForEach(self.blockHiddenDataStore.hiddenCommentIdArr, id: \.self) { hiddenCommentId in
                                    HStack {
                                        Text(self.blockHiddenDataStore.hiddenCommentsById[hiddenCommentId]!.contentString)
                                        Image(systemName: "multiply")
                                            .resizable()
                                            .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                                            .foregroundColor(.red)
                                            .onTapGesture {
                                                self.unhideComment(commentId: hiddenCommentId)
                                        }
                                    }.padding()
                                }
                            }
                        }
                        
                        
                    }
                    .frame(width: a.size.width)
                    .padding(.vertical)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(appWideAssets.colors["notQuiteBlack"]!)
                }
                .foregroundColor(Color.white)
            }
        }
        .navigationBarTitle(Text("Unblock Content"))
        .navigationBarHidden(false)
    }
}
