//
//  CommentView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-22.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI


struct CommentView : View {
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    
    @ObservedObject var commentDataStore: CommentDataStore
    
    var ancestorThreadId: Int
    let formatter = RelativeDateTimeFormatter()
    var width: CGFloat
    var height: CGFloat
    var leadPadding: CGFloat
    let staticPadding: CGFloat = 5
    let level: Int
    let leadLineWidth: CGFloat = 3
    let verticalPadding: CGFloat = 15
    
    @State var isEditable: Bool = false
    
    func setReplyTargetToCommentId() {
//        self.gameDataStore.isReplyBarReplyingToThreadByThreadId[ancestorThreadId] = false
//        self.gameDataStore.replyTargetCommentIdByThreadId[ancestorThreadId] = commentId
    }
    
    func transformVotesString(points: Int) -> String {
        let isNegative = false
        let numPoints = points
        
        var concatVotesStr = ""
        if numPoints > 1000000 {
            concatVotesStr = String((Double(numPoints) / 1000000 * 10).rounded() / 10)
            concatVotesStr += " M"
        } else if numPoints > 1000 {
            concatVotesStr = String((Double(numPoints) / 1000 * 10).rounded() / 10)
            concatVotesStr += " K"
        } else {
            concatVotesStr += String(numPoints)
        }
        
        return ((isNegative ? "-" : "" ) + concatVotesStr)
    }
    
    func onClickUpvoteButton() {
//        if self.gameDataStore.voteCommentMapping[commentId] != nil {
//            if self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!.direction == 1 {
//                self.gameDataStore.deleteCommentVote(access: self.userDataStore.token!.access, vote: self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!, userId: self.userDataStore.token!.userId)
//            }  else if self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!.direction == 0 {
//                self.gameDataStore.upvoteByExistingVoteIdComment(access: self.userDataStore.token!.access, voteId: self.gameDataStore.voteCommentMapping[commentId]!, comment: self.gameDataStore.comments[commentId]!, userId: self.userDataStore.token!.userId)
//            } else {
//                self.gameDataStore.switchUpvoteComment(access: self.userDataStore.token!.access, comment: self.gameDataStore.comments[commentId]!, userId: self.userDataStore.token!.userId)
//            }
//        } else {
//            self.gameDataStore.addNewUpvoteComment(access: self.userDataStore.token!.access, comment: self.gameDataStore.comments[commentId]!, userId: self.userDataStore.token!.userId)
//        }
    }
    
    func onClickDownvoteButton() {
//        if self.gameDataStore.voteCommentMapping[commentId] != nil {
//            if self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!.direction == -1 {
//                self.gameDataStore.deleteCommentVote(access: self.userDataStore.token!.access, vote: self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!, userId: self.userDataStore.token!.userId)
//            } else if self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!.direction == 0 {
//                self.gameDataStore.downvoteByExistingVoteIdComment(access: self.userDataStore.token!.access, voteId: self.gameDataStore.voteCommentMapping[commentId]!, comment: self.gameDataStore.comments[commentId]!, userId: self.userDataStore.token!.userId)
//            } else {
//                self.gameDataStore.switchDownvoteComment(access:  self.userDataStore.token!.access, comment: self.gameDataStore.comments[commentId]!, userId: self.userDataStore.token!.userId)
//            }
//        } else {
//            self.gameDataStore.addNewDownvoteComment(access: self.userDataStore.token!.access, comment: self.gameDataStore.comments[commentId]!, userId: self.userDataStore.token!.userId)
//        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(red: 225 / 255, green: 225 / 255, blue: 225 / 255))
                    .frame(width: self.width - self.leadPadding, height: 1, alignment: .leading)
                
                HStack(spacing: 0) {
                    if self.level > 0 {
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(self.assetsDataStore.leadingLineColors[self.level % self.assetsDataStore.leadingLineColors.count])
                            .frame(width: self.leadLineWidth, height: 30 + self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0) + 30)
                            .padding(.trailing, 10)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .trailing, spacing: 0) {
                            VStack(alignment: .trailing, spacing: 0) {
                                HStack(spacing: 0) {
                                    VStack(spacing: 0) {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(Color.orange)
                                    }
                                    .frame(width: 30, height: 30)
                                    .padding(.trailing, 10)
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 0) {
                                            Text(self.commentDataStore.author.username)
                                                .font(.system(size: 16))
                                                .onTapGesture {
//                                                    if self.gameDataStore.users[self.gameDataStore.comments[self.commentId]!.author]!.id == self.userDataStore.token!.userId {
//                                                        return
//                                                    }
//
//                                                    self.gameDataStore.isAddEmojiModalActiveByThreadViewId[self.ancestorThreadId] = false
//                                                    self.gameDataStore.isReportPopupActiveByThreadId[self.ancestorThreadId] = false
//                                                    self.gameDataStore.lastClickedBlockUserByThreadId[self.ancestorThreadId] = self.gameDataStore.users[self.gameDataStore.comments[self.commentId]!.author]!.id
//                                                    self.gameDataStore.isBlockPopupActiveByThreadId[self.ancestorThreadId] = true
                                            }
                                            
                                            Spacer()
//                                            Image(":thumbs_up:")
//                                                .resizable()
//                                                .frame(width: 11, height: 11)
//                                                .padding(5)
//
//                                                .background(self.gameDataStore.voteCommentMapping[commentId] == nil || self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!.direction == 1 ? Color.black : Color(.lightGray))
//                                                .cornerRadius(5)
//                                                .onTapGesture {
//                                                    self.onClickUpvoteButton()
//                                            }
//
//                                            Text(self.gameDataStore.voteCountStringByCommentId[commentId]!)
//                                                .frame(width: 25, height: 16)
//
//                                            Image(":thumbs_down:")
//                                                .resizable()
//                                                .frame(width: 11, height: 11)
//                                                .padding(5)
//
//                                                .background(self.gameDataStore.voteCommentMapping[commentId] != nil && self.gameDataStore.votes[self.gameDataStore.voteCommentMapping[commentId]!]!.direction == -1 ? Color.black : Color(.lightGray))
//                                                .cornerRadius(5)
//                                                .onTapGesture {
//                                                    self.onClickDownvoteButton()
//                                            }
                                        }
                                        
//                                        Text(self.gameDataStore.relativeDateStringByCommentId[self.commentId]!)
//                                            .foregroundColor(Color(.darkGray))
//                                            .font(.system(size: 14))
//                                            .padding(.bottom, 5)
                                    }
                                }
                                
                                FancyPantsEditorView(existedTextStorage: self.$commentDataStore.textStorage, desiredHeight: self.$commentDataStore.desiredHeight, newTextStorage: .constant(NSTextStorage(string: "")), isEditable: self.$isEditable, isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: false, isOmniBar: false)
                                
//                                    .frame(width: self.width - self.leadPadding - staticPadding * 2 - 30 - 10 - (self.level > 0 ? 10 + self.leadLineWidth: 0), height: self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0), alignment: .leading)
//
//                                    .onTapGesture {
////                                        self.setReplyTargetToCommentId()
////                                        self.omniBarDidBecomeFirstResponder = true
//                                }
                                
                                HStack {
                                    HStack {
                                        if self.commentDataStore.isHidden == true {
                                            Text("Unhide")
                                            .bold()
                                                .onTapGesture {
//                                                    self.commentDataStore.unhideComment(access: self.userDataStore.token!.access, commentId: self.commentId)
                                            }
                                        } else {
                                            Text("Hide")
                                            .bold()
                                                .onTapGesture {
//                                                    self.commentDataStore.hideComment(access: self.userDataStore.token!.access, commentId: self.commentId)
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Report")
                                        .bold()
                                            .onTapGesture {
//                                                self.gameDataStore.isBlockPopupActiveByThreadId[self.ancestorThreadId] = false
//                                                self.gameDataStore.isAddEmojiModalActiveByThreadViewId[self.ancestorThreadId] = false
//                                                self.gameDataStore.lastClickedReportCommentByThreadId[self.ancestorThreadId] = self.commentId
//
//                                                self.gameDataStore.isLastClickedReportThreadInThreadViewByThreadId[self.ancestorThreadId] = false
//                                                self.gameDataStore.isReportPopupActiveByThreadId[self.ancestorThreadId] = true
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .foregroundColor(.gray)
                                .frame(width: self.width - self.leadPadding - staticPadding * 2 - 30 - 10 - (self.level > 0 ? 10 + self.leadLineWidth: 0), height:
                                20)
                                    .padding(.top, 10)
                            }
                        }
                        .frame(width: self.width - self.leadPadding - staticPadding * 2 - (self.level > 0 ? 10 + self.leadLineWidth: 0), height: 30 + self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0) + 30, alignment: .leading)
                    }
                    .padding(.horizontal, self.staticPadding)
                    .padding(.vertical, self.verticalPadding)
                }
//                .background(self.gameDataStore.replyTargetCommentIdByThreadId[ancestorThreadId] != nil && self.gameDataStore.replyTargetCommentIdByThreadId[ancestorThreadId]! == commentId ? Color.gray : Color(red: 248 / 255, green: 248 / 255, blue: 248 / 255))
            }
            
            if self.commentDataStore.childCommentList.count < self.commentDataStore.comment.numChilds {
                MoreCommentsView(commentDataStore: self.commentDataStore, width: self.width - self.leadPadding - staticPadding * 2 - 10 - self.leadLineWidth - 20, leadLineWidth: self.leadLineWidth, staticPadding: self.staticPadding, verticalPadding: self.verticalPadding, level: self.level + 1)
            }
            
            if self.commentDataStore.childCommentList.count > 0 {
                ForEach(self.commentDataStore.childCommentList, id: \.self) { commentId in
                    CommentView(commentDataStore: self.commentDataStore.childComments[commentId]!, ancestorThreadId: self.ancestorThreadId, width: self.width, height: self.height, leadPadding: self.leadPadding + 20, level: self.level + 1)
                }
            }
        }
    }
}
