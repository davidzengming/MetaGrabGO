//
//  EmojiModalView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-03-30.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct EmojiPickerPopupView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    
    @ObservedObject var forumDataStore: ForumDataStore
    
    @Binding var pickedThreadId: Int
    
    var turnBottomPopup: () -> Void
//    var toggleBottomBarState: (_ state: BottomBarState) -> Void
//    var togglePickedThreadId: (_ threadId: Int) -> Void
//    var togglePickedUser: (_ user: User) -> Void
    
    func dismissView() {
//        self.togglePickedThreadId(-1)
//        self.toggleBottomBarState(.inActive)
        self.turnBottomPopup()
    }
    
    func addEmoji(emojiId: Int) {
        let taskGroup = DispatchGroup()
        
        switch emojiId {
        // Upvote
        case 0:
            if self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote != nil {
                switch self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote!.direction {
                case 1:
                    print("hello")
                    return
                case 0:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.upvoteByExistingVoteId(access: self.userDataStore.token!.access, user: self.userDataStore.user!, taskGroup: taskGroup)
                    break
                case -1:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.switchUpvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!, taskGroup: taskGroup)
                    break
                default:
                    print("Vote direction is invalid.")
                }
            } else {
                self.forumDataStore.threadDataStores[self.pickedThreadId]!.addNewUpvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!, taskGroup: taskGroup)
            }
            break
        case 1:
            if self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote != nil {
                switch self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote!.direction {
                case -1:
                    return
                case 0:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.downvoteByExistingVoteId(access: self.userDataStore.token!.access, user: self.userDataStore.user!, taskGroup: taskGroup)
                    break
                case 1:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.switchDownvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!, taskGroup: taskGroup)
                    break
                default:
                    print("Vote direction is invalid.")
                }
            } else {
                self.forumDataStore.threadDataStores[self.pickedThreadId]!.addNewDownvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!, taskGroup: taskGroup)
            }
            break
        default:
            // already reacted
            if self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.didReactToEmoji[emojiId] != nil && self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.didReactToEmoji[emojiId]! == true {
                return
            }
            
            let rowCount = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr.count
            let colCount = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[rowCount - 1].count
            
            if rowCount == 2 && colCount >= 3 && self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiCount[emojiId] == nil {
                let hasUpvote = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[0][0] == 0
                let hasDownvote = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[0][0] == 1 || self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[0][1] == 1
                
                if !hasUpvote && !hasDownvote && (emojiId != 0 && emojiId != 1) {
                    print("Too many emojis, don't have both upvote or downvotes need 2 spots for them.")
                    return
                } else if colCount ==  self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.maxEmojiCountPerRow && ((!hasUpvote && emojiId != 0) || (!hasDownvote  && emojiId != 1)) {
                    print("Too many emojis, don't have upvote or downvote and needs 1 spot for it.")
                    return
                }
            }
            
            self.forumDataStore.threadDataStores[self.pickedThreadId]!.addEmojiByThreadId(access: self.userDataStore.token!.access, emojiId: emojiId, user: self.userDataStore.user!, taskGroup: taskGroup)
        }
        
        taskGroup.notify(queue: .global()) {
            self.dismissView()
        }
    }
    
    var body: some View {
        GeometryReader { a in
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "multiply")
                        .resizable()
                        .frame(width: a.size.height * 0.1, height: a.size.height * 0.1)
                        .foregroundColor(.white)
                        .onTapGesture {
                            self.dismissView()
                    }
                    Spacer()
                }
                .frame(width: a.size.width * 0.9, height: a.size.height * 0.1, alignment: .leading)
                .padding(.horizontal, a.size.width * 0.05)
                .padding(.vertical, a.size.height * 0.1)
                
                VStack(spacing: 0){
                    ScrollView(.vertical) {
                        HStack(spacing: 0) {
                            ForEach(self.assetsDataStore.emojiArray, id: \.self) { emojiId in
                                Image(uiImage: self.assetsDataStore.emojis[emojiId]!)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding(.horizontal, 3)
                                    .onTapGesture {
                                        self.addEmoji(emojiId: emojiId)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}
