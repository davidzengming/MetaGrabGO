//
//  EmojiListView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-13.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct EmojiBarThreadView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @ObservedObject var threadDataStore: ThreadDataStore
    
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    
    func onClickAddEmojiBubble() {
        self.toggleBottomBarState(.addEmoji)
        self.togglePickedThreadId(self.threadDataStore.thread.id, CGFloat(0))
        self.turnBottomPopup(true)
    }
    
    func onClickEmoji(emojiId: Int) {
        switch emojiId {
        case 0:
            if self.threadDataStore.vote != nil {
                switch self.threadDataStore.vote!.direction {
                case 1:
                    self.threadDataStore.deleteVote(access: self.userDataStore.token!.access, user: userDataStore.user!)
                    break
                case 0:
                    self.threadDataStore.upvoteByExistingVoteId(access: self.userDataStore.token!.access, user: userDataStore.user!)
                    break
                case -1:
                    self.threadDataStore.switchUpvote(access: self.userDataStore.token!.access, user: userDataStore.user!)
                    break
                default:
                    print("Invalid vote direction.")
                }
            } else {
                self.threadDataStore.addNewUpvote(access: self.userDataStore.token!.access, user: userDataStore.user!)
            }
            break
        case 1:
            if self.threadDataStore.vote != nil {
                switch self.threadDataStore.vote!.direction {
                case -1:
                    self.threadDataStore.deleteVote(access: self.userDataStore.token!.access, user: userDataStore.user!)
                    break
                case 0:
                    self.threadDataStore.downvoteByExistingVoteId(access: self.userDataStore.token!.access, user: userDataStore.user!)
                    break
                case 1:
                    self.threadDataStore.switchDownvote(access: self.userDataStore.token!.access, user: userDataStore.user!)
                    break
                default:
                    print("Invalid vote direction.")
                }
            } else {
                self.threadDataStore.addNewDownvote(access: self.userDataStore.token!.access, user: userDataStore.user!)
            }
            break
        default:
            if self.threadDataStore.emojis.didReactToEmoji[emojiId] == true {
                self.threadDataStore.removeEmojiByThreadId(access: self.userDataStore.token!.access, emojiId: emojiId, user: userDataStore.user!)
            } else {
                self.threadDataStore.addEmojiByThreadId(access: self.userDataStore.token!.access, emojiId: emojiId, user: userDataStore.user!)
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading) {
                ForEach(self.threadDataStore.emojis.emojiArr.indices, id: \.self) { row in
                    HStack {
                        ForEach(self.threadDataStore.emojis.emojiArr[row], id: \.self) { emojiId in
                            VStack(alignment: .leading) {
                                if emojiId == 999 {
                                    HStack {
                                        Image(systemName: "plus.bubble.fill")
                                            .resizable()
                                            .foregroundColor(Color(.darkGray))
                                            .frame(width: 20, height: 20)
                                            .buttonStyle(PlainButtonStyle())
                                            .cornerRadius(5)
                                            .onTapGesture {
                                                self.onClickAddEmojiBubble()
                                        }
                                    }
                                    .frame(alignment: .leading)
                                } else {
                                    HStack {
                                        Image(uiImage: self.assetsDataStore.emojis[emojiId]!)
                                            .resizable()
                                            .frame(width: 15, height: 15)

                                        Text(String(self.threadDataStore.emojis.emojiCount[emojiId]!))
                                        .bold()
                                            .foregroundColor(Color(.darkGray))
                                    }
                                    .frame(width: 40, height: 15)
                                    .padding(5)
                                    .background(self.threadDataStore.emojis.didReactToEmoji[emojiId]! == true ? Color.gray : Color(.lightGray))
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        self.onClickEmoji(emojiId: emojiId)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if self.threadDataStore.emojis.emojiArr.count == 1 && self.threadDataStore.emojis.emojiArr[0][0] == 999 {
                Text("Add reactions")
                .foregroundColor(Color.gray)
                .bold()
                .onTapGesture {
                        self.onClickAddEmojiBubble()
                }
            }
        }
    }
}
