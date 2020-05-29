//
//  ThreadRow.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct ThreadRow : View {
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @ObservedObject var threadDataStore: ThreadDataStore
    @ObservedObject var bottomBarStateDataStore: BottomBarStateDataStore
    
    var width: CGFloat
    var height: CGFloat
    
    let placeholder = Image(systemName: "photo")
    let formatter = RelativeDateTimeFormatter()
    
    let threadsFromBottomToGetReadyToLoadNextPage = 1
    let threadsPerNewPageCount = 10
    
    //    func onClickUser() {
    //        if self.gameDataStore.users[self.gameDataStore.threads[self.threadId]!.author]!.id == self.userDataStore.token!.userId {
    //            return
    //        }
    //
    //        self.gameDataStore.isAddEmojiModalActiveByForumId[self.gameDataStore.threads[self.threadId]!.forum] = false
    //        self.gameDataStore.isReportPopupActiveByForumId[self.gameId] = false
    //
    //        self.gameDataStore.lastClickedBlockUserByForumId[self.gameId] = self.gameDataStore.users[self.gameDataStore.threads[self.threadId]!.author]!.id
    //        self.gameDataStore.isBlockPopupActiveByForumId[self.gameId] = true
    //    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(spacing: 0) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.orange)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.threadDataStore.author.username)
                        .frame(height: self.height * 0.025, alignment: .leading)
                    //                        .onTapGesture {
                    //                            self.onClickUser()
                    //                    }
                    
                    Text(self.threadDataStore.relativeDateString!)
                        .font(.system(size: 14))
                        .frame(height: self.height * 0.02, alignment: .leading)
                        .foregroundColor(Color(.darkGray))
                }
                
                Spacer()
            }
            .frame(width: self.width, height: self.height * 0.045, alignment: .leading)
            .padding(.bottom, 10)
            //
            //            NavigationLink(destination: ThreadView(threadId: self.threadId, gameId: self.gameId)) {
            VStack(alignment: .leading) {
                HStack {
                    if self.threadDataStore.thread.title.count > 0 {
                        Text(self.threadDataStore.thread.title)
                            .fontWeight(.medium)
                        Spacer()
                    }
                }
                
                if self.threadDataStore.textStorage.length > 0 {
                    FancyPantsEditorView(existedTextStorage: self.$threadDataStore.textStorage, desiredHeight: self.$threadDataStore.desiredHeight,  newTextStorage: .constant(NSTextStorage(string: "")), isEditable: .constant(false), isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: true, threadId: self.threadDataStore.thread.id, isOmniBar: false)
                        .frame(width: self.width * 0.9, height: min(self.threadDataStore.desiredHeight, 200), alignment: .leading)
                }
            }
                //            }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 10)
            
            HStack(spacing: 10) {
                ForEach(self.threadDataStore.imageArr, id: \.self) { index in
                    Image(uiImage: self.threadDataStore.imageLoaders[index]!.downloadedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(5)
                        .frame(minWidth: self.width * 0.05, maxWidth: self.width * 0.25, minHeight: self.height * 0.1, maxHeight: self.height * 0.15, alignment: .center)
                }
            }
            .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 10) {
                    
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.right.fill")
                        Text(String(self.threadDataStore.thread.numSubtreeNodes))
                            .font(.system(size: 16))
                            .bold()
                        Text("Comments")
                            .bold()
                    }
                    .frame(height: self.height * 0.025, alignment: .leading)
                    
                    //                    HStack {
                    //                        if self.gameDataStore.isThreadHiddenByThreadId[self.threadId]! == true {
                    //                            Text("Unhide")
                    //                                .bold()
                    //                                .onTapGesture {
                    //                                    self.gameDataStore.unhideThread(access: self.userDataStore.token!.access, threadId: self.threadId)
                    //                            }
                    //                        } else {
                    //                            Text("Hide")
                    //                                .bold()
                    //                                .onTapGesture {
                    //                                    self.gameDataStore.hideThread(access: self.userDataStore.token!.access, threadId: self.threadId)
                    //                            }
                    //                        }
                    //                    }
                    //
                    //                    HStack {
                    //                        Text("Report")
                    //                            .bold()
                    //                            .onTapGesture {
                    //                                self.gameDataStore.isBlockPopupActiveByForumId[self.gameId] = false
                    //                                self.gameDataStore.isAddEmojiModalActiveByForumId[self.gameDataStore.threads[self.threadId]!.forum] = false
                    //                                self.gameDataStore.lastClickedReportThreadByForumId[self.gameId] = self.threadId
                    //                                self.gameDataStore.isReportPopupActiveByForumId[self.gameId] = true
                    //                        }
                    //                    }
                    
                    Spacer()
                }
                .foregroundColor(Color.gray)
                .frame(width: self.width * 0.9)
                
                EmojiBarThreadView(threadDataStore: self.threadDataStore, bottomBarStateDataStore: self.bottomBarStateDataStore)
            }
            .padding(.top, 10)
        }
        .padding(.all, 20)
        .frame(width: self.width)
        .background(Color.white)
    }
}


