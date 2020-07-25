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

struct CenterModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

struct ThreadView : View {
    @ObservedObject private var threadDataStore: ThreadDataStore
    
    private let formatter = RelativeDateTimeFormatter()
    private let outerPadding : CGFloat = 0
    
    @State private var isEditable = false
    @State private var isBottomPopupOn = false
    @State private var bottomBarState: BottomBarState = .fancyBar
    @State private var pickedThreadId: Int = -1
    @State private var pickedCommentId: CommentDataStore?
    
    @State private var pickedUser: User = User(id: -1, username: "placeholder", profileImageUrl: "", profileImageWidth: "", profileImageHeight: "")
    
    // reply bar
    @State private var replyContent = NSTextStorage(string: "")
    @State private var replyBarDesiredHeight: CGFloat = 20 // subject to font size changes
    @State private var keyboardHeight: CGFloat = 0
    @State private var replyFutureContainerWidth: CGFloat = 0
    
    @State private var isImageModalOn = false
    @State private var currentImageModalIndex: Int = -1
    @State private var imageModalSelectedThreadStore: ThreadDataStore? = nil
    
    @State private var isFirstResponder: Bool = false
    @State private var didBecomeFirstResponder: Bool = false
    
    
    private let leadPadding: CGFloat = 20
    private let avatarWidth = UIFont.preferredFont(forTextStyle: .body).pointSize * 2
    private let avatarPadding: CGFloat = 10
    
    
    init(threadDataStore: ThreadDataStore) {
        self.threadDataStore = threadDataStore
        //        print("thread view created", threadDataStore.thread.id)
        self.pickedThreadId = threadDataStore.thread.id
    }
    
    private func turnBottomPopup(state: Bool) {
        if self.isBottomPopupOn != state {
            self.isBottomPopupOn = state
        }
    }
    
    private func toggleBottomBarState(state: BottomBarState) {
        if self.bottomBarState == state {
            return
        }
        self.bottomBarState = state
    }
    
    private func togglePickedThreadId(threadId: Int, futureContainerWidth: CGFloat) {
        if self.pickedThreadId == threadId {
            return
        }
        self.pickedCommentId = nil
        self.bottomBarState = .inActive
        self.isBottomPopupOn = false
        
        self.replyFutureContainerWidth = futureContainerWidth
        self.pickedThreadId = threadId
    }
    
    private func togglePickedCommentId(commentId: CommentDataStore?, futureContainerWidth: CGFloat) {
        if commentId != nil && self.pickedCommentId != nil && self.pickedCommentId!.comment.id == commentId!.comment.id {
            return
        }
        
        self.pickedThreadId = -1
        self.bottomBarState = .inActive
        self.isBottomPopupOn = false
        
        self.replyFutureContainerWidth = futureContainerWidth
        self.pickedCommentId = commentId
    }
    
    private func toggleDidBecomeFirstResponder() {
        self.didBecomeFirstResponder = true
    }
    
    private func togglePickedUser(user: User) {
        if self.pickedUser == user {
            return
        }
        self.pickedUser = user
    }
    
    private func toggleReplyFutureContainerWidth(width: CGFloat) {
        if self.replyFutureContainerWidth == width {
            return
        }
        self.replyFutureContainerWidth = width
    }
    
    private func onClickUser() {
        if self.threadDataStore.author.id == keychainService.getUserId() {
            print("Cannot report self.")
            return
        }
        
        self.togglePickedUser(user: self.threadDataStore.author)
        self.toggleBottomBarState(state: .blockUser)
        self.turnBottomPopup(state: true)
    }
    //
    //    func scrollToOriginalThread() {
    //    }
    //
    //    func shareToSocialMedia() {
    //    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    private func fetchNextPage(containerWidth: CGFloat) {
        self.threadDataStore.fetchCommentTreeByThreadId(start: self.threadDataStore.childCommentList!.count, refresh: true, containerWidth: containerWidth, leadPadding: self.leadPadding)
    }
    
    private func toggleImageModal(threadDataStore: ThreadDataStore?, currentImageModalIndex: Int) {
        if threadDataStore != nil {
            self.imageModalSelectedThreadStore = threadDataStore
            self.currentImageModalIndex = currentImageModalIndex
            self.isImageModalOn = true
        } else {
            self.isImageModalOn = false
            self.currentImageModalIndex = -1
            self.imageModalSelectedThreadStore = nil
        }
    }
    
    private func submit(mainCommentContainerWidth: CGFloat) {
        //        print("submitted")
        
        if pickedCommentId != nil {
            self.pickedCommentId!.postChildComment(content: self.replyContent, containerWidth: self.replyFutureContainerWidth)
        } else {
            self.threadDataStore.postMainComment(content: self.replyContent, containerWidth: mainCommentContainerWidth)
        }
        
        self.togglePickedCommentId(commentId: nil, futureContainerWidth: CGFloat(0))
        self.replyContent.setAttributedString(NSAttributedString(string: ""))
        self.didBecomeFirstResponder = false
    }
    
    var body: some View {
        ZStack {
            appWideAssets.colors["darkButNotBlack"]!
                .edgesIgnoringSafeArea(.all)
            
            Color(UIColor(named: "pseudoTertiaryBackground")!)
                .edgesIgnoringSafeArea(.bottom)
            
            GeometryReader { a in
                ZStack(alignment: .bottom) {
                    VStack {
                        List {
                            VStack(spacing: 0) {
                                HStack(spacing: self.avatarPadding) {
                                    VStack(spacing: 0) {
                                        if self.threadDataStore.authorProfileImageLoader != nil {
                                            if self.threadDataStore.authorProfileImageLoader!.downloadedImage != nil {
                                                Image(uiImage: self.threadDataStore.authorProfileImageLoader!.downloadedImage!)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: self.avatarWidth, height: self.avatarWidth)
                                                    .clipShape(Circle())
                                            } else {
                                                Circle()
                                                    .fill(Color(.systemGray5))
                                                    .frame(width: self.avatarWidth, height: self.avatarWidth)
                                                    .onAppear() {
                                                        if self.threadDataStore.authorProfileImageLoader != nil {
                                                            self.threadDataStore.authorProfileImageLoader!.load()
                                                    }
                                                }
                                            }
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(Color.orange)
                                                .onAppear() {
                                                    if self.threadDataStore.authorProfileImageLoader != nil {
                                                        self.threadDataStore.authorProfileImageLoader!.load()
                                                    }
                                            }
                                        }
                                    }
                                    .animation(.easeIn)
                                    .frame(height: self.avatarWidth)
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(self.threadDataStore.author.username)
                                            .onTapGesture {
                                                self.onClickUser()
                                        }
                                        
                                        Text(self.threadDataStore.relativeDateString!)
                                            .font(.subheadline)
                                            .foregroundColor(Color(.secondaryLabel))
                                    }
                                    
                                    Spacer()
                                }
                                .frame(width: a.size.width * 0.9, height: self.avatarWidth)
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                                .modifier(CenterModifier())
                                
                                if self.threadDataStore.thread.title.count > 0 {
                                    Text(self.threadDataStore.thread.title)
                                        .fontWeight(.medium)
                                        .frame(width: a.size.width * 0.9, alignment: .leading)
                                        .modifier(CenterModifier())
                                }
                                
                                Button(action: {self.togglePickedThreadId(threadId: self.threadDataStore.thread.id, futureContainerWidth: 0)
                                    self.toggleDidBecomeFirstResponder()}) {
                                        FancyPantsEditorView(existedTextStorage: self.$threadDataStore.textStorage, desiredHeight: self.$threadDataStore.desiredHeight,  newTextStorage: .constant(NSTextStorage(string: "")), isEditable: .constant(false), isFirstResponder: .constant(false), didBecomeFirstResponder: .constant(false), showFancyPantsEditorBar: .constant(false), isNewContent: false, isThread: true, threadId: self.threadDataStore.thread.id, isOmniBar: false, width: a.size.width * 0.9, height: a.size.height)
                                            .frame(width: a.size.width * 0.9, height: self.threadDataStore.desiredHeight + (self.isEditable ? 20 : 0))
                                            
                                }
                                .modifier(CenterModifier())
                                .padding(.bottom, 20)
                                
                                if self.threadDataStore.imageArr.count != 0 {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(spacing: 10) {
                                            ForEach(self.threadDataStore.imageArr, id: \.self) { index in
                                                VStack {
                                                    if self.threadDataStore.imageLoaders[index]!.downloadedImage != nil {
                                                        Image(uiImage: self.threadDataStore.imageLoaders[index]!.downloadedImage!)
                                                            .resizable()
                                                            .frame(width: self.threadDataStore.imageDimensions[index].width, height: self.threadDataStore.imageDimensions[index].height)
                                                            .aspectRatio(contentMode: .fit)
                                                            .cornerRadius(5)
                                                            .onTapGesture {
                                                                self.toggleImageModal(threadDataStore: self.threadDataStore, currentImageModalIndex: index)
                                                        }
                                                    } else {
                                                        Rectangle()
                                                            .fill(Color(.systemGray3))
                                                            .frame(width: self.threadDataStore.imageDimensions[index].width, height: self.threadDataStore.imageDimensions[index].height)
                                                            .aspectRatio(contentMode: .fit)
                                                            .cornerRadius(5)
                                                            .onTapGesture {
                                                                self.toggleImageModal(threadDataStore: self.threadDataStore, currentImageModalIndex: index)
                                                        }
                                                    }
                                                }
                                                .animation(.easeIn(duration: 0.25))
                                            }
                                        }
                                        .frame(width: a.size.width * 0.81, height: self.threadDataStore.maxImageHeight, alignment: .leading)
                                    }
                                    .frame(width: a.size.width * 0.9, alignment: .leading)
                                    .modifier(CenterModifier())
                                    .padding(.bottom, 20)

                                }
                                
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
                                                    self.threadDataStore.unhideThread( threadId: self.threadDataStore.thread.id)
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
                                                self.togglePickedThreadId(threadId: self.threadDataStore.thread.id, futureContainerWidth: CGFloat(0))
                                                self.toggleBottomBarState(state: .reportThread)
                                                self.turnBottomPopup(state: true)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .frame(width: a.size.width * 0.9)
                                .padding(.bottom, 10)
                                .foregroundColor(Color(.systemGray2))
                                .modifier(CenterModifier())
                                
                                EmojiBarThreadView(threadDataStore: self.threadDataStore, turnBottomPopup: { state in self.turnBottomPopup(state: state) }, toggleBottomBarState: { state in self.toggleBottomBarState(state: state)}, togglePickedUser: { user in self.togglePickedUser(user: user)}, togglePickedThreadId: { (threadId, futureContainerWidth) in self.togglePickedThreadId(threadId: threadId, futureContainerWidth: futureContainerWidth) })
                                    .frame(width: a.size.width * 0.9)
                                    .modifier(CenterModifier())
                            }
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            
                            if self.threadDataStore.childCommentList != nil && self.threadDataStore.childCommentList!.count > 0 {
                                Divider()
                                ForEach(self.threadDataStore.childCommentList!, id: \.self) { commentId in
                                    CommentView(commentDataStore: self.threadDataStore.childComments[commentId]!, ancestorThreadId: self.threadDataStore.thread.id, width: a.size.width * 0.9, height: a.size.height, leadPadding: 0, level: 0, turnBottomPopup: { state in self.turnBottomPopup(state: state) }, toggleBottomBarState: { state in self.toggleBottomBarState(state: state) }, togglePickedUser: { user in self.togglePickedUser(user: user) }, togglePickedCommentId: { (commentId, futureContainerWidth) in self.togglePickedCommentId(commentId: commentId, futureContainerWidth: futureContainerWidth) }, toggleDidBecomeFirstResponder: self.toggleDidBecomeFirstResponder)
                                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                        .onAppear() {
                                            if commentId == self.threadDataStore.childCommentList!.last! {
                                                self.fetchNextPage(containerWidth: a.size.width * 0.9)
                                            }
                                    }
                                }
                                
                                if self.threadDataStore.hasNextPage == false {
                                    HStack {
                                        Spacer()
                                        Text("No more comments for now")
                                            .foregroundColor(Color(.secondaryLabel))
                                        Spacer()
                                    }
                                    .padding(.top, 30)
                                }
                                
                            } else {
                                Divider()
                                VStack {
                                    Image(systemName: "message.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: a.size.width * 0.3, height: a.size.width * 0.3)
                                        .padding()
                                        .foregroundColor(Color(.lightGray))
                                    Text("~Don't leave the poster hanging~")
                                        .bold()
                                        .foregroundColor(Color(.lightGray))
                                        .padding()
                                }
                                .frame(height: a.size.height / 2)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .modifier(CenterModifier())
                                .animation(nil)
                            }
                            
                            VStack {
                                if self.threadDataStore.childCommentList != nil && self.threadDataStore.childCommentList!.count < self.threadDataStore.thread.numChilds {
                                    if self.threadDataStore.isLoadingNextPage == true {
                                        ActivityIndicator()
                                            .frame(width: a.size.width * 0.1, height: a.size.height * 0.1)
                                            .foregroundColor(appWideAssets.colors["darkButNotBlack"]!)
                                            .modifier(CenterModifier())
                                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    }
                                }
                            }
                            .animation(nil)
                        }
                        .frame(width: a.size.width, height: a.size.height - (20 + 20 + 40))
                        .onAppear() {
                            if self.threadDataStore.childCommentList == nil {
                                self.threadDataStore.fetchCommentTreeByThreadId(refresh: true, containerWidth: a.size.width * 0.9, leadPadding: self.leadPadding)
                            }
                        }
                        Spacer()
                    }
                    .frame(width: a.size.width, height: a.size.height)
                    
                    FancyPantsEditorView(existedTextStorage: .constant(NSTextStorage(string: "")), desiredHeight: self.$replyBarDesiredHeight, newTextStorage: self.$replyContent, isEditable: .constant(true), isFirstResponder: self.$isFirstResponder, didBecomeFirstResponder: self.$didBecomeFirstResponder, showFancyPantsEditorBar: .constant(true), isNewContent: true, isThread: true, isOmniBar: true, submit: { mainCommentContainerWidth in self.submit(mainCommentContainerWidth: mainCommentContainerWidth)}, width: a.size.width, height: a.size.height, togglePickedCommentId: { (commentId, futureContainerWidth) in self.togglePickedCommentId(commentId: commentId, futureContainerWidth: futureContainerWidth)}, mainCommentContainerWidth: a.size.width - self.avatarWidth - self.avatarPadding)
                        .KeyboardAwarePadding()
                        .animation(.spring())
                        .transition(.slide)
                    
                    BottomBarViewThreadVer(threadDataStore: self.threadDataStore, isBottomPopupOn: self.$isBottomPopupOn, bottomBarState: self.$bottomBarState, pickedThreadId: self.$pickedThreadId,  pickedCommentId: self.$pickedCommentId, pickedUser: self.$pickedUser, width: a.size.width, height: a.size.height * 0.25, turnBottomPopup: { state in self.turnBottomPopup(state: state) }, toggleBottomBarState: { state in self.toggleBottomBarState(state: state)}, togglePickedUser: { user in self.togglePickedUser(user: user)}, togglePickedThreadId: { (threadId, futureContainerWidth) in self.togglePickedThreadId(threadId: threadId, futureContainerWidth: futureContainerWidth) }, togglePickedCommentId: { (commentId, futureContainerWidth) in self.togglePickedCommentId(commentId: commentId, futureContainerWidth: futureContainerWidth) })
                }
                
                DummyImageModalView(isImageModalOn: self.$isImageModalOn, threadDataStore: self.$imageModalSelectedThreadStore, currentImageModalIndex: self.$currentImageModalIndex)
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(Color(UIColor(named: "pseudoTertiaryBackground")!))
        }
    }
}
