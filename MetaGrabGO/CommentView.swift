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
    @ObservedObject var commentDataStore: CommentDataStore
    
    @State var isEditable: Bool = false
    
    var ancestorThreadId: Int
    let formatter = RelativeDateTimeFormatter()
    var width: CGFloat
    var height: CGFloat
    var leadPadding: CGFloat
    let level: Int
    let leadLineWidth: CGFloat = 3
    let verticalPadding: CGFloat = 10
    let outerPadding : CGFloat = 0
    
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedCommentId: (CommentDataStore?, CGFloat) -> Void
    var toggleDidBecomeFirstResponder: () -> Void
    
    init(commentDataStore: CommentDataStore, ancestorThreadId: Int, width: CGFloat, height: CGFloat, leadPadding: CGFloat, level: Int, turnBottomPopup: @escaping (Bool) -> Void, toggleBottomBarState: @escaping (BottomBarState) -> Void, togglePickedUser: @escaping (User) -> Void, togglePickedCommentId: @escaping (CommentDataStore?, CGFloat) -> Void, toggleDidBecomeFirstResponder: @escaping () -> Void) {
        self.commentDataStore = commentDataStore
        self.ancestorThreadId = ancestorThreadId
        self.width = width
        self.height = height
        self.leadPadding = leadPadding
        self.level = level
        
        self.turnBottomPopup = turnBottomPopup
        self.toggleBottomBarState = toggleBottomBarState
        self.togglePickedUser = togglePickedUser
        self.togglePickedCommentId = togglePickedCommentId
        self.toggleDidBecomeFirstResponder = toggleDidBecomeFirstResponder
        //        print("comment view was created: ", self.commentDataStore.comment.id)
    }
    
    func onClickUser() {
        if self.commentDataStore.author.id == keychainService.getUserId() {
            print("Cannot report self.")
            return
        }
        
        self.togglePickedUser(self.commentDataStore.author)
        self.toggleBottomBarState(.blockUser)
        self.turnBottomPopup(true)
    }
    
    //    func transformVotesString(points: Int) -> String {
    //        let isNegative = false
    //        let numPoints = points
    //
    //        var concatVotesStr = ""
    //        if numPoints > 1000000 {
    //            concatVotesStr = String((Double(numPoints) / 1000000 * 10).rounded() / 10)
    //            concatVotesStr += " M"
    //        } else if numPoints > 1000 {
    //            concatVotesStr = String((Double(numPoints) / 1000 * 10).rounded() / 10)
    //            concatVotesStr += " K"
    //        } else {
    //            concatVotesStr += String(numPoints)
    //        }
    //
    //        return ((isNegative ? "-" : "" ) + concatVotesStr)
    //    }
    //
    func onClickUpvoteButton() {
        if self.commentDataStore.vote != nil {
            if self.commentDataStore.vote!.direction == 1 {
                self.commentDataStore.deleteVote()
            } else if self.commentDataStore.vote!.direction == 0 {
                self.commentDataStore.upvoteByExistingVoteId()
            } else {
                self.commentDataStore.switchUpvote()
            }
        } else {
            self.commentDataStore.addNewUpvote()
        }
    }
    
    func onClickDownvoteButton() {
        if self.commentDataStore.vote != nil {
            if self.commentDataStore.vote!.direction == -1 {
                self.commentDataStore.deleteVote()
            } else if self.commentDataStore.vote!.direction == 0 {
                self.commentDataStore.downvoteByExistingVoteId()
            } else {
                self.commentDataStore.switchDownvote()
            }
        } else {
            self.commentDataStore.addNewDownvote()
        }
    }
    
    var body: some View {
        Group {
            HStack(spacing: 0) {
                if level != 0 {
                    Spacer()
                }
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        if self.level > 0 {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(appWideAssets.leadingLineColors[self.level % appWideAssets.leadingLineColors.count])
                                .frame(width: self.leadLineWidth, height: self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0) + self.height * 0.04 + 10 + 20 + 10 + 5)
                                .padding(.trailing, 10)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .trailing, spacing: 0) {
                                VStack(alignment: .trailing, spacing: 0) {
                                    HStack(spacing: 0) {
                                        HStack {
                                            VStack(spacing: 0) {
                                                Image(systemName: "person.circle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .foregroundColor(Color.orange)
                                            }
                                            .frame(height: self.height * 0.04)
                                            
                                            VStack(alignment: .leading, spacing: 0) {
                                                HStack {
                                                    Text(self.commentDataStore.author.username)
                                                        .onTapGesture {
                                                            self.onClickUser()
                                                    }
                                                    
                                                    Spacer()
                                                }
                                                
                                                Text(self.commentDataStore.relativeDateString!)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(.secondaryLabel))
                                            }
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Image(":thumbs_up:")
                                                    .resizable()
                                                    .frame(width: self.width * 0.025, height: self.width * 0.025)
                                                    .padding(5)
                                                    .background(self.commentDataStore.vote != nil && self.commentDataStore.vote!.direction == 1 ? Color(.darkGray) : Color(UIColor(named: "emojiBackgroundColor")!))
                                                    
                                                    .cornerRadius(5)
                                                    .onTapGesture {
                                                        self.onClickUpvoteButton()
                                                }
                                                
                                                Text(String(self.commentDataStore.comment.upvotes - self.commentDataStore.comment.downvotes))
                                                    .font(.body)
                                                    .frame(width: 20)
                                                
                                                Image(":thumbs_down:")
                                                    .resizable()
                                                    .frame(width: self.width * 0.025, height: self.width * 0.025)
                                                    .padding(5)
                                                    
                                                    .background(self.commentDataStore.vote != nil && self.commentDataStore.vote!.direction == -1 ? Color(.darkGray) : Color(UIColor(named: "emojiBackgroundColor")!))
                                                    .cornerRadius(5)
                                                    .onTapGesture {
                                                        self.onClickDownvoteButton()
                                                }
                                            }
                                            .frame(height: self.height * 0.04, alignment: .top)
                                        }
                                        .frame(width: self.width - self.leadPadding - (self.level > 0 ? self.leadLineWidth + 10: 0), height: self.height * 0.04)
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                    Button(action: {self.togglePickedCommentId(self.commentDataStore, self.width - self.leadPadding - 10 - self.leadLineWidth - 20)
                                        self.toggleDidBecomeFirstResponder()}) {
                                            FancyPantsEditorView(existedTextStorage: self.$commentDataStore.textStorage, desiredHeight: self.$commentDataStore.desiredHeight, newTextStorage: .constant(NSTextStorage(string: "")), isEditable: self.$isEditable, isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: false, isOmniBar: false, width: self.width, height: self.height)
                                                
                                                .frame(height: self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0), alignment: .leading)
                                                .padding(.top, 10)
                                                .padding(.bottom, 5)
                                    }
                                    
                                    
                                    HStack {
                                        HStack {
                                            if self.commentDataStore.isHidden == true {
                                                Text("Unhide")
                                                    .bold()
                                                    .onTapGesture {
                                                        self.commentDataStore.unhideComment()
                                                }
                                            } else {
                                                Text("Hide")
                                                    .bold()
                                                    .onTapGesture {
                                                        self.commentDataStore.hideComment()
                                                }
                                            }
                                        }
                                        
                                        HStack {
                                            Text("Report")
                                                .bold()
                                                .onTapGesture {
                                                    self.togglePickedCommentId(self.commentDataStore, self.width - self.leadPadding - 10 - self.leadLineWidth - 20)
                                                    self.toggleBottomBarState(.reportThread)
                                                    self.turnBottomPopup(true)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .foregroundColor(.gray)
                                    .frame(height: 20)
                                }
                            }
                            .frame(width: self.width - self.leadPadding - (self.level > 0 ? self.leadLineWidth + 10: 0), height: self.height * 0.04 + self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0) + 10 + 20 + 10 + 5, alignment: .leading)
                        }
                        .padding(.vertical, self.verticalPadding)
                    }
                }
            }
            .frame(width: self.width)
            .modifier(CenterModifier())
            
            if self.commentDataStore.childCommentList.count < self.commentDataStore.comment.numChilds {
                if self.commentDataStore.isLoadingNextPage == true {
                    ActivityIndicator()
                        .frame(width: self.width - self.leadPadding - 10 - self.leadLineWidth - 20, height: self.height * 0.20)
                        .modifier(CenterModifier())
                        .foregroundColor(appWideAssets.colors["darkButNotBlack"]!)
                } else {
                    HStack {
                        MoreCommentsView(commentDataStore: self.commentDataStore, width: self.width - self.leadPadding - 10 - self.leadLineWidth - 20, leadLineWidth: self.leadLineWidth, verticalPadding: self.verticalPadding, level: self.level + 1)
                    }
                    .frame(width: self.width)
                    .modifier(CenterModifier())
                }
            }
            
            if self.commentDataStore.childCommentList.count > 0 {
                ForEach(self.commentDataStore.childCommentList, id: \.self) { commentId in
                    CommentView(commentDataStore: self.commentDataStore.childComments[commentId]!, ancestorThreadId: self.ancestorThreadId, width: self.width, height: self.height, leadPadding: self.leadPadding + 20, level: self.level + 1, turnBottomPopup: { state in self.turnBottomPopup(state) }, toggleBottomBarState: { state in self.toggleBottomBarState(state) }, togglePickedUser: { user in self.togglePickedUser(user) }, togglePickedCommentId: { (commentId, futureContainerWidth) in self.togglePickedCommentId(commentId, futureContainerWidth) }, toggleDidBecomeFirstResponder: self.toggleDidBecomeFirstResponder)
                }
            }
        }
    }
}
