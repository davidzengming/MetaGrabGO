//
//  ThreadView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-22.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ThreadView : View {
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @ObservedObject var threadDataStore: ThreadDataStore
    
    let formatter = RelativeDateTimeFormatter()
    let outerPadding : CGFloat = 20
    let placeholder = Image(systemName: "rectangle.fill")
    
    @State var isEditable = false
    @State var isBottomPopupOn = false
    @State var bottomBarState: BottomBarState = .fancyBar
    @State var pickedThreadId: Int = -1
    @State var pickedCommentId: CommentDataStore?
    
    @State var pickedUser: User = User(id: -1, username: "placeholder")
    
    // reply bar
    @State var replyContent = NSTextStorage(string: "")
    @State var replyBarDesiredHeight: CGFloat = 20 // subject to font size changes
    @State var keyboardHeight: CGFloat = 0
    @State var replyFutureContainerWidth: CGFloat = 0
    
    @State var isImageModalOn = false
    @State var currentImageModalIndex: Int? = nil
    @State var imageModalSelectedThreadStore: ThreadDataStore? = nil
    
    @State var isFirstResponder: Bool = false
    @State var didBecomeFirstResponder: Bool = false

    
    init(threadDataStore: ThreadDataStore) {
        self.threadDataStore = threadDataStore
        print("thread view created", threadDataStore.thread.id)
        self.pickedThreadId = threadDataStore.thread.id
    }
    
    func turnBottomPopup(state: Bool) {
        if self.isBottomPopupOn != state {
            self.isBottomPopupOn = state
        }
    }
    
    func toggleBottomBarState(state: BottomBarState) {
        if self.bottomBarState == state {
            return
        }
        self.bottomBarState = state
    }
    
    func togglePickedThreadId(threadId: Int, futureContainerWidth: CGFloat) {
        if self.pickedThreadId == threadId {
            return
        }
        self.pickedCommentId = nil
        self.bottomBarState = .inActive
        self.isBottomPopupOn = false
        
        self.replyFutureContainerWidth = futureContainerWidth
        self.pickedThreadId = threadId
    }
    
    func togglePickedCommentId(commentId: CommentDataStore?, futureContainerWidth: CGFloat) {
        if commentId != nil && self.pickedCommentId != nil && self.pickedCommentId!.comment.id == commentId!.comment.id {
            return
        }
        
        self.pickedThreadId = -1
        self.bottomBarState = .inActive
        self.isBottomPopupOn = false
        
        self.replyFutureContainerWidth = futureContainerWidth
        self.pickedCommentId = commentId
    }
    
    func toggleDidBecomeFirstResponder() {
        self.didBecomeFirstResponder = true
    }
    
    func togglePickedUser(user: User) {
        if self.pickedUser == user {
            return
        }
        self.pickedUser = user
    }
    
    func toggleReplyFutureContainerWidth(width: CGFloat) {
        if self.replyFutureContainerWidth == width {
            return
        }
        self.replyFutureContainerWidth = width
    }
    
    func onClickUser() {
        if self.threadDataStore.author.id == self.userDataStore.token!.userId {
            print("Cannot report self.")
            return
        }
        
        self.togglePickedUser(user: self.threadDataStore.author)
        self.toggleBottomBarState(state: .blockUser)
        self.turnBottomPopup(state: true)
    }
    
    func scrollToOriginalThread() {
    }
    
    func shareToSocialMedia() {
    }
    
    func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    func fetchNextPage(containerWidth: CGFloat) {
        self.threadDataStore.fetchCommentTreeByThreadId(start: self.threadDataStore.childCommentList.count, refresh: true, userId: self.userDataStore.token!.userId, containerWidth: containerWidth, leadPadding: 20, userDataStore: self.userDataStore)
    }
    
    func toggleImageModal(threadDataStore: ThreadDataStore?, currentImageModalIndex: Int?) {
        if threadDataStore != nil {
            self.imageModalSelectedThreadStore = threadDataStore
            self.currentImageModalIndex = currentImageModalIndex
            self.isImageModalOn = true
        } else {
            self.isImageModalOn = false
            self.currentImageModalIndex = nil
            self.imageModalSelectedThreadStore = nil
        }
    }
    
    func submit(mainCommentContainerWidth: CGFloat) {
        print("submitted")

        if pickedCommentId != nil {
            self.pickedCommentId!.postChildComment(content: self.replyContent, containerWidth: self.replyFutureContainerWidth, userDataStore: self.userDataStore)
        } else {
            self.threadDataStore.postMainComment(content: self.replyContent, containerWidth: mainCommentContainerWidth, userDataStore: self.userDataStore)
        }
        
        self.togglePickedCommentId(commentId: nil, futureContainerWidth: CGFloat(0))
        self.replyContent.setAttributedString(NSAttributedString(string: ""))
        self.didBecomeFirstResponder = false
        self.endEditing()
    }
    
    var body: some View {
        ZStack {
            self.assetsDataStore.colors["darkButNotBlack"]!
                .edgesIgnoringSafeArea(.all)
            
            Color.white
                .edgesIgnoringSafeArea(.bottom)
            
            GeometryReader { a in
                ZStack(alignment: .bottom) {
                    VStack {
                        List {
                            VStack(alignment: .leading) {
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
                                            Text(self.threadDataStore.thread.users[0].username)
                                                .font(.system(size: 16))
                                            Spacer()
                                        }
                                        .onTapGesture {
                                            self.onClickUser()
                                        }
                                        
                                        Text(self.threadDataStore.relativeDateString!)
                                            .foregroundColor(Color(.darkGray))
                                            .font(.system(size: 14))
                                            .padding(.bottom, 5)
                                    }
                                }
                                .padding(.top, 20)
                                
                                Button(action: {self.togglePickedThreadId(threadId: self.threadDataStore.thread.id, futureContainerWidth: 0)
                                    self.toggleDidBecomeFirstResponder()}) {
                                        FancyPantsEditorView(existedTextStorage: self.$threadDataStore.textStorage, desiredHeight: self.$threadDataStore.desiredHeight,  newTextStorage: .constant(NSTextStorage(string: "")), isEditable: .constant(false), isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: true, threadId: self.threadDataStore.thread.id, isOmniBar: false, width: a.size.width, height: a.size.height)
                                        .frame(width: a.size.width - self.outerPadding * 2, height: self.threadDataStore.desiredHeight + (self.isEditable ? 20 : 0))
                                        .padding(.bottom, 10)
                                }
                                
                                HStack(spacing: 10) {
                                    ForEach(self.threadDataStore.imageArr, id: \.self) { index in
                                        Group {
                                            if self.threadDataStore.imageLoaders[index]!.downloadedImage != nil {
                                                Image(uiImage: self.threadDataStore.imageLoaders[index]!.downloadedImage!)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .cornerRadius(5)
                                                    .frame(minWidth: a.size.width * 0.05, maxWidth: a.size.width * 0.25, minHeight: a.size.height * 0.1, maxHeight: a.size.height * 0.15, alignment: .center)
                                                .onTapGesture {
                                                    self.toggleImageModal(threadDataStore: self.threadDataStore, currentImageModalIndex: index)
                                                }
                                            } else {
                                                self.placeholder
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .cornerRadius(5)
                                                    .frame(minWidth: a.size.width * 0.05, maxWidth: a.size.width * 0.25, minHeight: a.size.height * 0.1, maxHeight: a.size.height * 0.15, alignment: .center)
                                                .onTapGesture {
                                                    self.toggleImageModal(threadDataStore: self.threadDataStore, currentImageModalIndex: index)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                                
                                HStack(spacing: 10) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "bubble.right.fill")
                                        Text(String(self.threadDataStore.thread.numSubtreeNodes))
                                            .font(.system(size: 16))
                                            .bold()
                                        Text("Comments")
                                            .bold()
                                    }
                                    
                                    HStack {
                                        if self.threadDataStore.isHidden == true {
                                            Text("Unhide")
                                                .bold()
                                                .onTapGesture {
                                                    self.threadDataStore.unhideThread( threadId: self.threadDataStore.thread.id, userDataStore: self.userDataStore)
                                            }
                                        } else {
                                            Text("Hide")
                                                .bold()
                                                .onTapGesture {
                                                    self.threadDataStore.hideThread(threadId: self.threadDataStore.thread.id, userDataStore: self.userDataStore)
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Report")
                                            .bold()
                                            .onTapGesture {
                                                self.togglePickedThreadId(threadId: self.threadDataStore.thread.id, futureContainerWidth: CGFloat(0))
                                                self.toggleBottomBarState(state: .reportThread)
                                                self.turnBottomPopup(state: true)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .frame(width: a.size.width - self.outerPadding * 2, height: 20)
                                .foregroundColor(.gray)
                                
                                EmojiBarThreadView(threadDataStore: self.threadDataStore, turnBottomPopup: { state in self.turnBottomPopup(state: state) }, toggleBottomBarState: { state in self.toggleBottomBarState(state: state)}, togglePickedUser: { user in self.togglePickedUser(user: user)}, togglePickedThreadId: { (threadId, futureContainerWidth) in self.togglePickedThreadId(threadId: threadId, futureContainerWidth: futureContainerWidth) })
                            }
                            
                            if self.threadDataStore.areCommentsLoaded {
                                if !self.threadDataStore.childCommentList.isEmpty {
                                    Divider()
                                    ForEach(self.threadDataStore.childCommentList, id: \.self) { commentId in
                                        CommentView(commentDataStore: self.threadDataStore.childComments[commentId]!, ancestorThreadId: self.threadDataStore.thread.id, width: a.size.width - self.outerPadding * 2, height: a.size.height, leadPadding: 0, level: 0, turnBottomPopup: { state in self.turnBottomPopup(state: state) }, toggleBottomBarState: { state in self.toggleBottomBarState(state: state) }, togglePickedUser: { user in self.togglePickedUser(user: user) }, togglePickedCommentId: { (commentId, futureContainerWidth) in self.togglePickedCommentId(commentId: commentId, futureContainerWidth: futureContainerWidth) }, toggleDidBecomeFirstResponder: self.toggleDidBecomeFirstResponder)
                                    }
                                } else {
                                    Divider()
                                    VStack {
                                        Image(systemName: "pencil.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: a.size.width * 0.3, height: a.size.width * 0.3)
                                            .padding()
                                            .foregroundColor(Color(.lightGray))
                                        Text("Don't leave the poster hanging.")
                                            .bold()
                                            .foregroundColor(Color(.lightGray))
                                            .padding()
                                    }
                                    .frame(width: a.size.width - self.outerPadding * 2, height: a.size.height / 2)
                                }
                            } else {
                                VStack {
                                    ActivityIndicator()
                                    .frame(width: a.size.width, height: a.size.height * 0.20)
                                    .foregroundColor(self.assetsDataStore.colors["darkButNotBlack"]!)
                                }
                                .frame(width: a.size.width - self.outerPadding * 2, height: a.size.height / 2)
                                
                            }
                            
                            if self.threadDataStore.childCommentList.count < self.threadDataStore.thread.numChilds {
                                if self.threadDataStore.isLoadingNextPage == true {
                                    ActivityIndicator()
                                        .frame(width: a.size.width, height: a.size.height * 0.20)
                                        .foregroundColor(self.assetsDataStore.colors["darkButNotBlack"]!)
                                } else {
                                    HStack {
                                        Spacer()
                                        Text("Load more comments (\(self.threadDataStore.thread.numChilds - self.threadDataStore.childCommentList.count) replies)")
                                            .frame(width: a.size.width - self.outerPadding * 2 - 5, height: a.size.height * 0.05, alignment: .leading)
                                            .onTapGesture {
                                                self.fetchNextPage(containerWidth: a.size.width - self.outerPadding * 2)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: a.size.width, height: a.size.height - (20 + 20 + 40))
                        .onAppear() {
                            if self.threadDataStore.areCommentsLoaded == false {
                                self.threadDataStore.fetchCommentTreeByThreadId(refresh: true, userId: self.userDataStore.token!.userId, containerWidth: a.size.width - self.outerPadding * 2, leadPadding: 20, userDataStore: self.userDataStore)
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(width: a.size.width, height: a.size.height)

                    FancyPantsEditorView(existedTextStorage: .constant(NSTextStorage(string: "")), desiredHeight: self.$replyBarDesiredHeight, newTextStorage: self.$replyContent, isEditable: .constant(true), isFirstResponder: self.$isFirstResponder, didBecomeFirstResponder: self.$didBecomeFirstResponder, showFancyPantsEditorBar: .constant(true), isNewContent: true, isThread: true, isOmniBar: true, submit: { mainCommentContainerWidth in self.submit(mainCommentContainerWidth: mainCommentContainerWidth)}, width: a.size.width, height: a.size.height, togglePickedCommentId: { (commentId, futureContainerWidth) in self.togglePickedCommentId(commentId: commentId, futureContainerWidth: futureContainerWidth)}, mainCommentContainerWidth: a.size.width - self.outerPadding * 2)
                    .KeyboardAwarePadding()
                    .animation(.spring())
                    .transition(.slide)
                    
                    BottomBarViewThreadVer(threadDataStore: self.threadDataStore, isBottomPopupOn: self.$isBottomPopupOn, bottomBarState: self.$bottomBarState, pickedThreadId: self.$pickedThreadId,  pickedCommentId: self.$pickedCommentId, pickedUser: self.$pickedUser, width: a.size.width, height: a.size.height * 0.25, turnBottomPopup: { state in self.turnBottomPopup(state: state) }, toggleBottomBarState: { state in self.toggleBottomBarState(state: state)}, togglePickedUser: { user in self.togglePickedUser(user: user)}, togglePickedThreadId: { (threadId, futureContainerWidth) in self.togglePickedThreadId(threadId: threadId, futureContainerWidth: futureContainerWidth) }, togglePickedCommentId: { (commentId, futureContainerWidth) in self.togglePickedCommentId(commentId: commentId, futureContainerWidth: futureContainerWidth) })
                }
                
                DummyImageModalView(isImageModalOn: self.$isImageModalOn, threadDataStore: self.$imageModalSelectedThreadStore, currentImageModalIndex: self.$currentImageModalIndex)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
