//
//  EmojiModalView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-03-30.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct EmojiPickerPopupView: View {
    @ObservedObject var forumDataStore: ForumDataStore
    
    @Binding var pickedThreadId: Int
    
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    
    private func dismissView() {
        self.togglePickedThreadId(-1, CGFloat(0))
        self.toggleBottomBarState(.inActive)
        self.turnBottomPopup(false)
    }
    
    private func addEmoji(emojiId: Int) {
        switch emojiId {
        // Upvote
        case 0:
            if self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote != nil {
                switch self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote!.direction {
                case 1:
                    break
                case 0:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.upvoteByExistingVoteId()
                    break
                case -1:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.switchUpvote()
                    break
                default:
                    print("Vote direction is invalid.")
                }
            } else {
                self.forumDataStore.threadDataStores[self.pickedThreadId]!.addNewUpvote()
            }
            
            break
        case 1:
            if self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote != nil {
                switch self.forumDataStore.threadDataStores[self.pickedThreadId]!.vote!.direction {
                case -1:
                    return
                case 0:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.downvoteByExistingVoteId()
                    break
                case 1:
                    self.forumDataStore.threadDataStores[self.pickedThreadId]!.switchDownvote()
                    break
                default:
                    print("Vote direction is invalid.")
                }
            } else {
                self.forumDataStore.threadDataStores[self.pickedThreadId]!.addNewDownvote()
            }
            break
        default:
            // already reacted
            if self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.didReactToEmoji[emojiId] != nil && self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.didReactToEmoji[emojiId]! == true {
                break
            }
            
            let rowCount = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr.count
            let colCount = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[rowCount - 1].count
            
            if rowCount == 2 && colCount >= 3 && self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiCount[emojiId] == nil {
                let hasUpvote = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[0][0] == 0
                let hasDownvote = self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[0][0] == 1 || self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.emojiArr[0][1] == 1
                
                if !hasUpvote && !hasDownvote && (emojiId != 0 && emojiId != 1) {
//                    print("Too many emojis, don't have both upvote or downvotes need 2 spots for them.")
                    return
                } else if colCount ==  self.forumDataStore.threadDataStores[self.pickedThreadId]!.emojis.maxEmojiCountPerRow && ((!hasUpvote && emojiId != 0) || (!hasDownvote  && emojiId != 1)) {
//                    print("Too many emojis, don't have upvote or downvote and needs 1 spot for it.")
                    return
                }
            }
            
            self.forumDataStore.threadDataStores[self.pickedThreadId]!.addEmojiByThreadId(emojiId: emojiId)
        }
        
        self.dismissView()
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
                .frame(width: a.size.width * 0.95, height: a.size.height * 0.1, alignment: .leading)
                .padding(.horizontal, a.size.width * 0.05)
                .padding(.vertical, a.size.height * 0.1)
                
                VStack(spacing: 0){
                    ScrollView(.vertical) {
                        HStack(spacing: 0) {
                            ForEach(appWideAssets.emojiArray, id: \.self) { emojiId in
                                Image(uiImage: appWideAssets.emojis[emojiId]!!)
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

struct EmojiPickerPopupViewThreadVer: View {
    @ObservedObject var threadDataStore: ThreadDataStore
    
    @Binding var pickedThreadId: Int
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    var togglePickedCommentId: (CommentDataStore?, CGFloat) -> Void
    
    func dismissView() {
        self.togglePickedThreadId(-1, CGFloat(0))
        self.togglePickedCommentId(nil, CGFloat(0))
        self.toggleBottomBarState(.inActive)
        self.turnBottomPopup(false)
    }
    
    func addEmoji(emojiId: Int) {
        let taskGroup = DispatchGroup()
        
        switch emojiId {
        // Upvote
        case 0:
            if self.threadDataStore.vote != nil {
                switch self.threadDataStore.vote!.direction {
                case 1:
                    break
                case 0:
                    self.threadDataStore.upvoteByExistingVoteId()
                    break
                case -1:
                    self.threadDataStore.switchUpvote()
                    break
                default:
                    print("Vote direction is invalid.")
                }
            } else {
                self.threadDataStore.addNewUpvote()
            }
            
            break
        case 1:
            if self.threadDataStore.vote != nil {
                switch self.threadDataStore.vote!.direction {
                case -1:
                    return
                case 0:
                    self.threadDataStore.downvoteByExistingVoteId()
                    break
                case 1:
                    self.threadDataStore.switchDownvote()
                    break
                default:
                    print("Vote direction is invalid.")
                }
            } else {
                self.threadDataStore.addNewDownvote()
            }
            break
        default:
            // already reacted
            if self.threadDataStore.emojis.didReactToEmoji[emojiId] != nil && self.threadDataStore.emojis.didReactToEmoji[emojiId]! == true {
                break
            }
            
            let rowCount = self.threadDataStore.emojis.emojiArr.count
            let colCount = self.threadDataStore.emojis.emojiArr[rowCount - 1].count
            
            if rowCount == 2 && colCount >= 3 && self.threadDataStore.emojis.emojiCount[emojiId] == nil {
                let hasUpvote = self.threadDataStore.emojis.emojiArr[0][0] == 0
                let hasDownvote = self.threadDataStore.emojis.emojiArr[0][0] == 1 || self.threadDataStore.emojis.emojiArr[0][1] == 1
                
                if !hasUpvote && !hasDownvote && (emojiId != 0 && emojiId != 1) {
//                    print("Too many emojis, don't have both upvote or downvotes need 2 spots for them.")
                    return
                } else if colCount ==  self.threadDataStore.emojis.maxEmojiCountPerRow && ((!hasUpvote && emojiId != 0) || (!hasDownvote  && emojiId != 1)) {
//                    print("Too many emojis, don't have upvote or downvote and needs 1 spot for it.")
                    return
                }
            }
            
            self.threadDataStore.addEmojiByThreadId(emojiId: emojiId)
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
                .frame(width: a.size.width * 0.95, height: a.size.height * 0.1, alignment: .leading)
                .padding(.horizontal, a.size.width * 0.05)
                .padding(.vertical, a.size.height * 0.1)
                
                VStack(spacing: 0){
                    ScrollView(.vertical) {
                        HStack(spacing: 0) {
                            ForEach(appWideAssets.emojiArray, id: \.self) { emojiId in
                                Image(uiImage: appWideAssets.emojis[emojiId]!!)
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
