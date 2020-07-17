//
//  UserProfileView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-05-11.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    @ObservedObject var blockHiddenDataStore: BlockHiddenDataStore
    @State private var loadedBlacklist = false
    @State private var loadedHiddenThreads = false
    @State private var loadedHiddenComments = false
    
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
    
    private func logout() {
        self.userDataStore.logout()
        self.recentFollowDataStore.shouldRefreshDataStore = true
        
    }
    
    var body: some View {
        ZStack {
            appWideAssets.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                VStack {
                    HStack(alignment: .top) {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.orange)
                        }
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            Text(keychainService.getUserName())
                        }
                    }
                    .foregroundColor(Color.white)
                    .padding()
                    
                    ScrollView {
                        VStack {
                            VStack {
                                Text("BLACKLISTED USERS")
                                    .tracking(1)
                                    .padding()
                                    .frame(width: a.size.width * 0.9, height: a.size.height * 0.05, alignment: .leading)
                                    .background(appWideAssets.colors["teal"]!)
                                
                                if self.loadedBlacklist == false {
                                    Button(action: self.fetchBlacklistedUsers) {
                                        Text("Show blacklisted users")
                                            .padding()
                                            .background(Color.red)
                                            .foregroundColor(Color.white)
                                            .cornerRadius(10)
                                    }
                                    .padding()
                                } else if self.loadedBlacklist == true && self.blockHiddenDataStore.blacklistedUserIdArr.isEmpty {
                                    Text("There are no blacklisted users.")
                                    .padding()
                                }
                                
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
                            .frame(width: a.size.width * 0.9)
                            .background(appWideAssets.colors["notQuiteBlack"])
                            .padding()
                            
                            VStack {
                                Text("HIDDEN THREADS")
                                    .tracking(1)
                                    .padding()
                                    .frame(width: a.size.width * 0.9, height: a.size.height * 0.05, alignment: .leading)
                                    .background(appWideAssets.colors["teal"]!)
                                
                                if self.loadedHiddenThreads == false {
                                    Button(action: self.fetchHiddenThreads) {
                                        Text("Show hidden threads")
                                            .padding()
                                            .background(Color.red)
                                            .foregroundColor(Color.white)
                                            .cornerRadius(10)
                                    }
                                    .padding()
                                    
                                } else if self.loadedHiddenThreads == true && self.blockHiddenDataStore.hiddenThreadIdArr.isEmpty {
                                    Text("There are no hidden threads.")
                                    .padding()
                                }
                                
                                ForEach(self.blockHiddenDataStore.hiddenThreadIdArr, id: \.self) { hiddenThreadId in
                                    HStack {
                                        Text(String(hiddenThreadId))
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
                            .frame(width: a.size.width * 0.9)
                            .background(appWideAssets.colors["notQuiteBlack"])
                            .padding()
                            
                            VStack {
                                Text("HIDDEN COMMENTS")
                                    .tracking(1)
                                    .padding()
                                    .frame(width: a.size.width * 0.9, height: a.size.height * 0.05, alignment: .leading)
                                    .background(appWideAssets.colors["teal"]!)
                                
                                if self.loadedHiddenComments == false {
                                    Button(action: self.fetchHiddenComments) {
                                        Text("Show hidden comments")
                                            .padding()
                                            .background(Color.red)
                                            .foregroundColor(Color.white)
                                            .cornerRadius(10)
                                    }
                                    .padding()
                                } else if self.loadedHiddenComments == true && self.blockHiddenDataStore.hiddenCommentIdArr.isEmpty {
                                    Text("There are no hidden comments.")
                                    .padding()
                                }
                                
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
                            .frame(width: a.size.width * 0.9)
                            .background(appWideAssets.colors["notQuiteBlack"])
                            .padding()
                            
                            VStack {
                                Button(action: self.logout) {
                                    Text("LOGOUT")
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(Color.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(50)
                        }
                        .frame(width: a.size.width, height: a.size.height)
                        .foregroundColor(Color.white)
                    }
                }
            }
        }
    }
}
