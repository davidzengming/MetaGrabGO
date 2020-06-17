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
    
    @State var isEditable: Bool = false
    
    var ancestorThreadId: Int
    let formatter = RelativeDateTimeFormatter()
    var width: CGFloat
    var height: CGFloat
    var leadPadding: CGFloat
    let staticPadding: CGFloat = 5
    let level: Int
    let leadLineWidth: CGFloat = 3
    let verticalPadding: CGFloat = 15
    let outerPadding : CGFloat = 20
    
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
        print("comment view was created: ", self.commentDataStore.comment.id)
    }

    func onClickUser() {
        if self.commentDataStore.author.id == self.userDataStore.token!.userId {
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
                self.commentDataStore.deleteVote(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
            } else if self.commentDataStore.vote!.direction == 0 {
                self.commentDataStore.upvoteByExistingVoteId(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
            } else {
                self.commentDataStore.switchUpvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
            }
        } else {
            self.commentDataStore.addNewUpvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
        }
    }
    
    func onClickDownvoteButton() {
        if self.commentDataStore.vote != nil {
            if self.commentDataStore.vote!.direction == -1 {
                self.commentDataStore.deleteVote(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
            } else if self.commentDataStore.vote!.direction == 0 {
                self.commentDataStore.downvoteByExistingVoteId(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
            } else {
                self.commentDataStore.switchDownvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
            }
        } else {
            self.commentDataStore.addNewDownvote(access: self.userDataStore.token!.access, user: self.userDataStore.user!)
        }
    }
    
    var body: some View {
        Group {
            HStack {
                Spacer()
                VStack(spacing: 0) {
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
                                                        self.onClickUser()
                                                }
                                                Text(String(self.commentDataStore.comment.id))
                                                    .onAppear() {
                                                        print("hi comment", self.commentDataStore.comment.id)
                                                }
                                                .foregroundColor(.black)
                                                
                                                Spacer()
                                                
                                                HStack {
                                                    Image(":thumbs_up:")
                                                        .resizable()
                                                        .frame(width: 11, height: 11)
                                                        .padding(5)
                                                        .background(self.commentDataStore.vote != nil && self.commentDataStore.vote!.direction == 1 ? Color.black : Color(.lightGray))
                                                        .cornerRadius(5)
                                                        .onTapGesture {
                                                            self.onClickUpvoteButton()
                                                    }
                                                    
                                                    Text(String(self.commentDataStore.comment.upvotes - self.commentDataStore.comment.downvotes))
                                                        .frame(width: 20, height: 16)
                                                    
                                                    Image(":thumbs_down:")
                                                        .resizable()
                                                        .frame(width: 11, height: 11)
                                                        .padding(5)
                                                        
                                                        .background(self.commentDataStore.vote != nil && self.commentDataStore.vote!.direction == -1 ? Color.black : Color(.lightGray))
                                                        .cornerRadius(5)
                                                        .onTapGesture {
                                                            self.onClickDownvoteButton()
                                                    }
                                                }
                                            }
                                            
                                            Text(self.commentDataStore.relativeDateString!)
                                                .foregroundColor(Color(.darkGray))
                                                .font(.system(size: 14))
                                                .padding(.bottom, 5)
                                        }
                                    }
                                    .padding(.vertical, 5)
                                    
                                    FancyPantsEditorView(existedTextStorage: self.$commentDataStore.textStorage, desiredHeight: self.$commentDataStore.desiredHeight, newTextStorage: .constant(NSTextStorage(string: "")), isEditable: self.$isEditable, isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: false, isOmniBar: false, width: self.width, height: self.height)
                                        
                                        .frame(height: self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0), alignment: .leading)
                                        .onTapGesture {
                                            self.togglePickedCommentId(self.commentDataStore, self.width - self.leadPadding - self.staticPadding * 2 - 10 - self.leadLineWidth - 20)
                                            self.toggleDidBecomeFirstResponder()
                                    }
                                    
                                    HStack {
                                        HStack {
                                            if self.commentDataStore.isHidden == true {
                                                Text("Unhide")
                                                    .bold()
                                                    .onTapGesture {
                                                        self.commentDataStore.unhideComment(access: self.userDataStore.token!.access)
                                                }
                                            } else {
                                                Text("Hide")
                                                    .bold()
                                                    .onTapGesture {
                                                        self.commentDataStore.hideComment(access: self.userDataStore.token!.access)
                                                }
                                            }
                                        }
                                        
                                        
                                        HStack {
                                            Text("Report")
                                                .bold()
                                                .onTapGesture {
                                                    self.togglePickedCommentId(self.commentDataStore, self.width - self.leadPadding - self.staticPadding * 2 - 10 - self.leadLineWidth - 20)
                                                    self.toggleBottomBarState(.reportThread)
                                                    self.turnBottomPopup(true)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .foregroundColor(.gray)
                                    .frame(height: 20)
                                    .padding(.top, 10)
                                }
                            }
                            .frame(width: self.width - self.leadPadding - staticPadding * 2 - (self.level > 0 ? self.leadLineWidth + 10: 0), height: 30 + self.commentDataStore.desiredHeight + (self.isEditable ? 20 : 0) + 30, alignment: .leading)
                        }
                        .padding(.vertical, self.verticalPadding)
                    }
                }
            }
            .frame(width: self.width)
            
            if self.commentDataStore.childCommentList.count < self.commentDataStore.comment.numChilds {
                if self.commentDataStore.isLoadingNextPage == true {
                    ActivityIndicator()
                        .frame(width: self.width - self.leadPadding - staticPadding * 2 - 10 - self.leadLineWidth - 20, height: self.height * 0.20)
                        .foregroundColor(self.assetsDataStore.colors["darkButNotBlack"]!)
                } else {
                    HStack {
                        Spacer()
                        MoreCommentsView(commentDataStore: self.commentDataStore, width: self.width - self.leadPadding - staticPadding * 2 - 10 - self.leadLineWidth - 20, leadLineWidth: self.leadLineWidth, staticPadding: self.staticPadding, verticalPadding: self.verticalPadding, level: self.level + 1)
                    }
                    .frame(width: self.width)
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
