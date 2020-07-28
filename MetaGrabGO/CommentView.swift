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
    @ObservedObject private var commentDataStore: CommentDataStore
    @State private var isEditable: Bool = false
    @State private var rotation = 0.0
    
    private var ancestorThreadId: Int
    private let formatter = RelativeDateTimeFormatter()
    private var width: CGFloat
    private var height: CGFloat
    private var leadPadding: CGFloat
    private let level: Int
    private let leadLineWidth: CGFloat = 4
    private let verticalPadding: CGFloat = 10
    private let outerPadding : CGFloat = 0
    
    private var turnBottomPopup: (Bool) -> Void
    private var toggleBottomBarState: (BottomBarState) -> Void
    private var togglePickedUser: (User) -> Void
    private var togglePickedCommentId: (CommentDataStore?, CGFloat) -> Void
    private var toggleDidBecomeFirstResponder: () -> Void
    
    private let avatarWidth = UIFont.preferredFont(forTextStyle: .body).pointSize * 2
    private let avatarPadding: CGFloat = 10
    
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
        //                print("comment view was created: ", self.commentDataStore.comment.id)
    }
    
    private func onClickUser() {
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
    private func onClickUpvoteButton() {
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
    
    private func onClickDownvoteButton() {
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
                                .frame(width: self.leadLineWidth, height: self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0)
                                    + self.height * 0.04 + 10
                                    + 20 + 10 + 5)
                                .padding(.trailing, 10)
                        }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .trailing, spacing: 0) {
                                VStack(alignment: .trailing, spacing: 0) {
                                    HStack(spacing: 0) {
                                        HStack(spacing: avatarPadding) {
                                            VStack(spacing: 0) {
                                                if self.commentDataStore.authorProfileImageLoader != nil {
                                                    if self.commentDataStore.authorProfileImageLoader!.downloadedImage != nil {
                                                        Image(uiImage: self.commentDataStore.authorProfileImageLoader!.downloadedImage!)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                            .frame(width: avatarWidth, height: avatarWidth)
                                                            .clipShape(Circle())
                                                    } else {
                                                        Circle()
                                                            .fill(Color(.systemGray5))
                                                            .frame(width: avatarWidth, height: avatarWidth)
                                                            .onAppear() {
                                                                if self.commentDataStore.authorProfileImageLoader != nil {
                                                                    self.commentDataStore.authorProfileImageLoader!.load()
                                                                }
                                                        }
                                                    }
                                                } else {
                                                    Image(systemName: "person.circle.fill")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .foregroundColor(Color.orange)
                                                        .onAppear() {
                                                            if self.commentDataStore.authorProfileImageLoader != nil {
                                                                self.commentDataStore.authorProfileImageLoader!.load()
                                                            }
                                                            
                                                    }
                                                }
                                            }
                                            .animation(.easeIn)
                                            .frame(height: self.avatarWidth)
                                            
                                            VStack(alignment: .leading, spacing: 0) {
                                                HStack {
                                                    Button(action: {
                                                        self.onClickUser()
                                                    }) {
                                                        Text(self.commentDataStore.author.username)
                                                        .fontWeight(.medium)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                    
                                                    Spacer()
                                                }
                                                
                                                Text(self.commentDataStore.relativeDateString!)
                                                    .font(.subheadline)
                                                    .foregroundColor(Color(.secondaryLabel))
                                            }
                                            
                                            Spacer()
                                            
                                            HStack {
                                                Button(action: {
                                                    self.onClickUpvoteButton()
                                                }) {
                                                    Image(":thumbs_up:")
                                                        .resizable()
                                                        .frame(width: self.width * 0.025, height: self.width * 0.025)
                                                        .padding(5)
                                                        .background(self.commentDataStore.vote != nil && self.commentDataStore.vote!.direction == 1 ? Color(UIColor(named: "emojiPressedBackgroundColor")!) : Color(UIColor(named: "emojiUnpressedBackgroundColor")!))
                                                        
                                                        .cornerRadius(5)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Text(String(self.commentDataStore.comment.upvotes - self.commentDataStore.comment.downvotes))
                                                    .font(.body)
                                                    .frame(width: 20)
                                                
                                                Button(action: {
                                                    self.onClickDownvoteButton()
                                                }) {
                                                    Image(":thumbs_down:")
                                                        .resizable()
                                                        .frame(width: self.width * 0.025, height: self.width * 0.025)
                                                        .padding(5)
                                                        
                                                        .background(self.commentDataStore.vote != nil && self.commentDataStore.vote!.direction == -1 ? Color(UIColor(named: "emojiPressedBackgroundColor")!) : Color(UIColor(named: "emojiUnpressedBackgroundColor")!))
                                                        .cornerRadius(5)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                            .frame(height: self.height * 0.04, alignment: .top)
                                        }
                                        .frame(width: self.width - self.leadPadding - (self.level > 0 ? self.leadLineWidth + 10: 0), height: self.height * 0.04)
                                        
                                    }
                                    .padding(.vertical, 5)
                                    
                                    Button(action: {self.togglePickedCommentId(self.commentDataStore, self.width - self.leadPadding - 10 - self.leadLineWidth - 20 - self.avatarWidth - self.avatarPadding)
                                        self.toggleDidBecomeFirstResponder()}) {
                                            FancyPantsEditorView(existedTextStorage: self.$commentDataStore.textStorage, desiredHeight: self.$commentDataStore.desiredHeight, newTextStorage: .constant(NSTextStorage(string: "")), isEditable: self.$isEditable, isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: false, isOmniBar: false, width: self.width, height: self.height)
                                                .frame(width: self.width - self.leadPadding - (self.level > 0 ? self.leadLineWidth + 10: 0) - self.avatarWidth - self.avatarPadding, height: self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0), alignment: .leading)
                                                .padding(.top, 10)
                                                .padding(.bottom, 5)
                                    }
                                    
                                    HStack {
                                        HStack {
                                            if self.commentDataStore.isHidden == true {
                                                Button(action: {
                                                    self.commentDataStore.unhideComment()
                                                }) {
                                                    Text("Unhide")
                                                        .bold()
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            } else {
                                                Button(action: {
                                                    self.commentDataStore.hideComment()
                                                }) {
                                                    Text("Hide")
                                                        .bold()
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                        
                                        HStack {
                                            Button(action: {
                                                self.togglePickedCommentId(self.commentDataStore, self.width - self.leadPadding - 10 - self.leadLineWidth - 20)
                                                self.toggleBottomBarState(.reportThread)
                                                self.turnBottomPopup(true)
                                            }) {
                                                Text("Report")
                                                    .bold()
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        
                                        if self.commentDataStore.comment.numChilds > 0 || self.commentDataStore.childCommentList.count > 0 {
                                            Button(action: {
                                                self.commentDataStore.toggleShowChildComments()
                                                if self.commentDataStore.showChildComments {
                                                    self.rotation = 0
                                                } else {
                                                    self.rotation = -90
                                                }
                                            }) {
                                                HStack {
                                                    Text(String(self.commentDataStore.childCommentList.count))
                                                        .bold()
                                                    
                                                    Image(systemName: "arrowtriangle.down.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(height: 12)
                                                        .rotationEffect(.degrees(rotation))
                                                    
                                                }
                                                .onAppear() {
                                                    if self.rotation == 0 && self.commentDataStore.showChildComments == false {
                                                        self.rotation = -90
                                                    }
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        
                                        Spacer()
                                    }
                                    .foregroundColor(Color(.systemGray2))
                                    .frame(width: self.width - self.leadPadding - (self.level > 0 ? self.leadLineWidth + 10: 0) - self.avatarWidth - self.avatarPadding, height: 20)
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
            
            if self.commentDataStore.showChildComments == true {
                if self.commentDataStore.childCommentList.count < self.commentDataStore.comment.numChilds {
                    if self.commentDataStore.isLoadingNextPage == true {
                        ActivityIndicator()
                            .frame(width: self.width * 0.1, height: self.height * 0.1)
                            .modifier(CenterModifier())
                            .foregroundColor(appWideAssets.colors["darkButNotBlack"]!)
                    } else {
                        HStack {
                            Spacer()
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
}
