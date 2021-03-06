//
//  EmojiListView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-04-13.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct EmojiBarThreadView: View {
    @ObservedObject var threadDataStore: ThreadDataStore
    
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    
    private func onClickAddEmojiBubble() {
        self.togglePickedThreadId(self.threadDataStore.thread.id, CGFloat(0))
        self.toggleBottomBarState(.addEmoji)
        self.turnBottomPopup(true)
    }
    
    private func onClickEmoji(emojiId: Int) {
        switch emojiId {
        case 0:
            if self.threadDataStore.vote != nil {
                switch self.threadDataStore.vote!.direction {
                case 1:
                    self.threadDataStore.deleteVote()
                    break
                case 0:
                    self.threadDataStore.upvoteByExistingVoteId()
                    break
                case -1:
                    self.threadDataStore.switchUpvote()
                    break
                default:
                    print("Invalid vote direction.")
                }
            } else {
                self.threadDataStore.addNewUpvote()
            }
            break
        case 1:
            if self.threadDataStore.vote != nil {
                switch self.threadDataStore.vote!.direction {
                case -1:
                    self.threadDataStore.deleteVote()
                    break
                case 0:
                    self.threadDataStore.downvoteByExistingVoteId()
                    break
                case 1:
                    self.threadDataStore.switchDownvote()
                    break
                default:
                    print("Invalid vote direction.")
                }
            } else {
                self.threadDataStore.addNewDownvote()
            }
            break
        default:
            if self.threadDataStore.emojis.didReactToEmoji[emojiId] == true {
                self.threadDataStore.removeEmojiByThreadId(emojiId: emojiId)
            } else {
                self.threadDataStore.addEmojiByThreadId(emojiId: emojiId)
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(self.threadDataStore.emojis.emojiArr.indices, id: \.self) { row in
                    HStack {
                        ForEach(self.threadDataStore.emojis.emojiArr[row], id: \.self) { emojiId in
                            VStack(alignment: .leading, spacing: 0) {
                                if emojiId == 999 {
                                    Button(action: {
                                        self.onClickAddEmojiBubble()
                                    }) {
                                        HStack {
                                            Image(systemName: "plus.bubble.fill")
                                                .resizable()
                                                .foregroundColor(Color(.secondaryLabel))
                                                .frame(width: 20, height: 20)
                                                .buttonStyle(PlainButtonStyle())
                                                .cornerRadius(5)
                                        }
                                        .frame(alignment: .leading)
                                        .padding(2.5)
                                    }
                                .buttonStyle(PlainButtonStyle())
                                } else {
                                    Button(action: {
                                        self.onClickEmoji(emojiId: emojiId)
                                    }) {
                                        HStack {
                                            Image(uiImage: appWideAssets.emojis[emojiId]!!)
                                                .resizable()
                                                .frame(width: 15, height: 15)

                                            Text(String(self.threadDataStore.emojis.emojiCount[emojiId]!))
                                            .bold()
                                            .foregroundColor(self.threadDataStore.emojis.didReactToEmoji[emojiId]! == true ? Color(UIColor(named: "emojiCountPressedColor")!) : Color(UIColor(named: "emojiCountUnpressedColor")!))
                                        }
                                        .frame(width: 40, height: 15)
                                        .padding(5)
                                        .background(self.threadDataStore.emojis.didReactToEmoji[emojiId]! == true ? Color(UIColor(named: "emojiPressedBackgroundColor")!) : Color(UIColor(named: "emojiUnpressedBackgroundColor")!))
                                        .cornerRadius(5)
                                    }
                                .buttonStyle(PlainButtonStyle())

                                }
                            }
                        }
                    }
                }
            }
            
            if self.threadDataStore.emojis.emojiArr.count == 1 && self.threadDataStore.emojis.emojiArr[0][0] == 999 {
                Button(action: {
                    self.onClickAddEmojiBubble()
                }) {
                    Text("Add reactions")
                    .foregroundColor(Color.gray)
                    .bold()
                }
            }
            
            Spacer()
        }
    }
}
