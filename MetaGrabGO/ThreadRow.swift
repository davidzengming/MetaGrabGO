//
//  ThreadRow.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct ThreadRow : View {
    @ObservedObject var threadDataStore: ThreadDataStore
    
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    var width: CGFloat
    var height: CGFloat
    var toggleImageModal: (ThreadDataStore?, Int?) -> Void
    
    let formatter = RelativeDateTimeFormatter()
    
    let threadsFromBottomToGetReadyToLoadNextPage = 1
    let threadsPerNewPageCount = 10
    
    init(threadDataStore: ThreadDataStore, turnBottomPopup: @escaping (Bool) -> Void, toggleBottomBarState: @escaping (BottomBarState) -> Void, togglePickedUser: @escaping (User) -> Void, togglePickedThreadId: @escaping (Int, CGFloat) -> Void, width: CGFloat, height: CGFloat, toggleImageModal: @escaping (ThreadDataStore?, Int?) -> Void) {
        self.threadDataStore = threadDataStore
        self.turnBottomPopup = turnBottomPopup
        self.toggleBottomBarState = toggleBottomBarState
        self.togglePickedUser = togglePickedUser
        self.togglePickedThreadId = togglePickedThreadId
        self.width = width
        self.height = height
        self.toggleImageModal = toggleImageModal
        print("remaking thread row: ", threadDataStore.thread.id)
    }
    
    func onClickUser() {
        if self.threadDataStore.author.id == keychainService.getUserId() {
            print("Cannot report self.")
            return
        }
        
        self.togglePickedUser(self.threadDataStore.author)
        self.toggleBottomBarState(.blockUser)
        self.turnBottomPopup(true)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(spacing: 0) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.orange)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.threadDataStore.author.username)
                        .fontWeight(.medium)
                        .onTapGesture {
                            self.onClickUser()
                    }
                    
                    Text("replied " + self.threadDataStore.relativeDateString!)
                        .font(.subheadline)
                        .foregroundColor(Color(.secondaryLabel))
                }
                Spacer()
            }
            .frame(width: self.width, height: self.height * 0.04, alignment: .leading)
            .padding(.bottom, 10)
            
            NavigationLink(destination: LazyView{ ThreadView(threadDataStore: self.threadDataStore) }) {
                VStack(alignment: .leading, spacing: 0) {
                    if self.threadDataStore.thread.title.count > 0 {
                        Text(self.threadDataStore.thread.title)
                            .fontWeight(.medium)
                    }
                    
                    FancyPantsEditorView(existedTextStorage: self.$threadDataStore.textStorage, desiredHeight: self.$threadDataStore.desiredHeight,  newTextStorage: .constant(NSTextStorage(string: "")), isEditable: .constant(false), isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: true, threadId: self.threadDataStore.thread.id, isOmniBar: false, width: self.width, height: self.height)
                        .frame(width: self.width * 0.9, height: min(self.threadDataStore.desiredHeight, 200), alignment: .leading)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 10)
            
            if self.threadDataStore.imageArr.count > 0 {
                HStack(spacing: 10) {
                    ForEach(self.threadDataStore.imageArr, id: \.self) { index in
                        VStack {
                            if self.threadDataStore.imageLoaders[index]!.downloadedImage != nil {
                                Image(uiImage: self.threadDataStore.imageLoaders[index]!.downloadedImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        self.toggleImageModal(self.threadDataStore, index)
                                }
                            } else {
                                Rectangle()
                                    .fill(Color(UIColor(named: "pseudoTertiaryBackground")!))
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        self.toggleImageModal(self.threadDataStore, index)
                                }
                            }
                        }
                        
                    }
                }
                .frame(minWidth: 0, maxWidth: self.width * 0.9, minHeight: self.height * 0.15, maxHeight: self.height * 0.15, alignment: .leading)
                .padding(.vertical, 10)
                .padding(.bottom, 10)
            }
            
            HStack(spacing: 10) {
                HStack(spacing: 5) {
                    Image(systemName: "bubble.right.fill")
                    Text(String(self.threadDataStore.thread.numSubtreeNodes))
                        .font(.body)
                        .bold()
                    Text("Comments")
                        .bold()
                }
                .frame(height: self.height * 0.025, alignment: .leading)
                
                HStack {
                    if self.threadDataStore.isHidden == true {
                        Text("Unhide")
                            .bold()
                            .onTapGesture {
                                self.threadDataStore.unhideThread(threadId: self.threadDataStore.thread.id)
                        }
                    } else {
                        Text("Hide")
                            .bold()
                            .onTapGesture {
                                self.threadDataStore.hideThread(threadId: self.threadDataStore.thread.id)
                        }
                    }
                }
                
                HStack {
                    Text("Report")
                        .bold()
                        .onTapGesture {
                            self.togglePickedThreadId(self.threadDataStore.thread.id, CGFloat(0))
                            self.toggleBottomBarState(.reportThread)
                            self.turnBottomPopup(true)
                    }
                }
                
                Spacer()
            }
            .foregroundColor(Color(.secondaryLabel))
            .frame(width: self.width * 0.9, height: self.height * 0.025)
            .padding(.bottom, 10)
            
            EmojiBarThreadView(threadDataStore: self.threadDataStore, turnBottomPopup: { state in self.turnBottomPopup(state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state)}, togglePickedUser: { pickedUser in self.togglePickedUser(pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(pickedThreadId, futureContainerWidth) })
        }
        .padding(.all, 20)
        .padding(.vertical, 10)
        .frame(width: self.width, height:
            ceil(self.height * 0.04 + 10
                + min(self.threadDataStore.desiredHeight, 200) + 10
                + (self.threadDataStore.imageLoaders.count > 0 ? (self.height * 0.15) : 0) + 30
                + self.height * 0.025
                + CGFloat(self.threadDataStore.emojis.emojiArr.count) * 40
                + 40
                + 20)
            //        .background(Color.white)
            , alignment: .center)
            .buttonStyle(PlainButtonStyle())
    }
}


