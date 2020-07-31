//
//  ForumView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

enum BottomBarState {
    case addEmoji, reportThread, blockUser, inActive, fancyBar
}

struct BottomBarView: View {
    @ObservedObject var forumDataStore: ForumDataStore
    @Binding var isBottomPopupOn: Bool
    @Binding var bottomBarState: BottomBarState
    @Binding var pickedThreadId: Int
    @Binding var pickedUser: User
    
    var width: CGFloat
    var height: CGFloat
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    
    var body: some View {
        // wrapping popup in a vstack instead of group works properly with animations
        VStack {
            if self.isBottomPopupOn == true {
                VStack {
                    if self.bottomBarState == .addEmoji {
                        EmojiPickerPopupView(forumDataStore: self.forumDataStore, pickedThreadId: self.$pickedThreadId, turnBottomPopup: { state in self.turnBottomPopup(state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state)}, togglePickedUser: { pickedUser in self.togglePickedUser(pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(pickedThreadId, futureContainerWidth)})
                    } else if self.bottomBarState == .reportThread {
                        ReportPopupView(forumDataStore: self.forumDataStore, pickedThreadId: self.$pickedThreadId, turnBottomPopup: { state in self.turnBottomPopup(state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state)}, togglePickedUser: { pickedUser in self.togglePickedUser(pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(pickedThreadId, futureContainerWidth)})
                    } else if self.bottomBarState == .blockUser {
                        BlockUserPopupView(blockHiddenDataStore: BlockHiddenDataStore(), pickedUser: self.$pickedUser, turnBottomPopup: { state in self.turnBottomPopup(state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state)}, togglePickedUser: { pickedUser in self.togglePickedUser(pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(pickedThreadId, futureContainerWidth)})
                    }
                }
                .frame(width: self.width, height: self.height)
                .background(appWideAssets.colors["darkButNotBlack"]!)
                .cornerRadius(5, corners: [.topLeft, .topRight])
                .KeyboardAwarePadding()
                .transition(.move(edge: .bottom))
                .animation(.default)
            }
        }
    }
}

struct BottomBarViewThreadVer: View {
    @ObservedObject var threadDataStore: ThreadDataStore
    @Binding var isBottomPopupOn: Bool
    @Binding var bottomBarState: BottomBarState
    @Binding var pickedThreadId: Int
    @Binding var pickedCommentId: CommentDataStore?
    @Binding var pickedUser: User
    
    var width: CGFloat
    var height: CGFloat
    
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    var togglePickedCommentId: (CommentDataStore?, CGFloat) -> Void
    
    var body: some View {
        VStack {
            if self.isBottomPopupOn == true {
                VStack {
                    if self.bottomBarState == .addEmoji {
                        EmojiPickerPopupViewThreadVer(threadDataStore: threadDataStore, pickedThreadId: self.$pickedThreadId, turnBottomPopup: { state in self.turnBottomPopup(state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state)}, togglePickedUser: { pickedUser in self.togglePickedUser(pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(pickedThreadId, futureContainerWidth)}, togglePickedCommentId: { (pickedCommentId, futureContainerWidth) in self.togglePickedCommentId(pickedCommentId, futureContainerWidth)} )
                    } else if self.bottomBarState == .reportThread {
                        ReportPopupViewThreadVer(threadDataStore: threadDataStore, pickedThreadId: self.$pickedThreadId, pickedCommentId: self.$pickedCommentId, turnBottomPopup: { state in self.turnBottomPopup(state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state)}, togglePickedUser: { pickedUser in self.togglePickedUser(pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(pickedThreadId, futureContainerWidth)}, togglePickedCommentId: { (pickedCommentId, futureContainerWidth) in self.togglePickedCommentId(pickedCommentId, futureContainerWidth)})
                    } else if self.bottomBarState == .blockUser {
                        BlockUserPopupView(blockHiddenDataStore: BlockHiddenDataStore(), pickedUser: self.$pickedUser, turnBottomPopup: { state in self.turnBottomPopup(state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state)}, togglePickedUser: { pickedUser in self.togglePickedUser(pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(pickedThreadId, futureContainerWidth)})
                    }
                }
                .frame(width: self.width, height: self.height)
                .background(appWideAssets.colors["darkButNotBlack"]!)
                .cornerRadius(5, corners: [.topLeft, .topRight])
                .KeyboardAwarePadding()
                .transition(.move(edge: .bottom))
                .animation(.default)
            }
            
        }
        
    }
}


struct FollowerStatsView: View {
    @ObservedObject var forumOtherDataStore: ForumOtherDataStore
    var gameName: String
    var width: CGFloat
    
    var followGame: () -> Void
    var unfollowGame: () -> Void
    
    var bannerHeight: CGFloat
    
    init(forumOtherDataStore: ForumOtherDataStore, gameName: String, width: CGFloat, followGame: @escaping () -> Void, unfollowGame: @escaping () -> Void, bannerHeight: CGFloat) {
        self.forumOtherDataStore = forumOtherDataStore
        self.gameName = gameName
        self.width = width
        self.followGame = followGame
        self.unfollowGame = unfollowGame
        self.bannerHeight = bannerHeight
    }
    
    var body: some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                Text(self.gameName)
                    .font(.system(size: self.width * 0.05))
                    .foregroundColor(Color.white)
                    .bold()
                
                if self.forumOtherDataStore.threadCount != nil {
                    HStack(spacing: 10) {
                        Text("Posts " + String(self.forumOtherDataStore.threadCount!))
                            .font(.subheadline)
                            .foregroundColor(Color.white)
                        Text("Followers " + String(self.forumOtherDataStore.followerCount!))
                            .foregroundColor(Color.white)
                            .font(.subheadline)
                    }
                    .font(.system(size: self.width * 0.04))
                }
                Spacer()
            }
            .frame(height: self.bannerHeight)
            .padding(.horizontal)
            
            Spacer()
            
            if self.forumOtherDataStore.isFollowed != nil {
                Button(action: {
                    if self.forumOtherDataStore.isFollowed! == true {
                        self.unfollowGame()
                    } else {
                        self.followGame()
                    }
                }) {
                    Text("SUB")
                        .font(.system(size: self.width * 0.04))
                        .padding(.horizontal, self.width * 0.05)
                        .padding(.vertical, self.width * 0.025)
                        .foregroundColor(self.forumOtherDataStore.isFollowed == true ? Color.white : Color.black)
                        .background(self.forumOtherDataStore.isFollowed == true ? Color.black : Color(UIColor(named: "subBackgroundColor")!))
                        .cornerRadius(self.width * 0.5)
                        .shadow(radius: self.width * 0.05)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct ForumView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var blockHiddenDataStore: BlockHiddenDataStore
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    
    @ObservedObject var forumDataStore: ForumDataStore
    @ObservedObject var forumOtherDataStore: ForumOtherDataStore
    @ObservedObject var gameIconLoader: ImageLoader
    
    @State private var isBottomPopupOn = false
    @State private var bottomBarState: BottomBarState = .addEmoji
    @State private var pickedThreadId: Int = -1
    @State private var pickedUser: User = User(id: -1, username: "placeholder", profileImageUrl: "", profileImageWidth: "", profileImageHeight: "")
    
    @State private var isImageModalOn = false
    @State private var currentImageModalIndex: Int = -1
    @State private var imageModalSelectedThreadStore: ThreadDataStore? = nil
    
    private let widthContentRatio: CGFloat = 0.95
    private let maxImageHeightRatio: CGFloat = 0.25
    
    init(forumDataStore: ForumDataStore, forumOtherDataStore: ForumOtherDataStore, gameIconLoader: ImageLoader) {
        self.forumDataStore = forumDataStore
        self.forumOtherDataStore = forumOtherDataStore
        self.gameIconLoader = gameIconLoader
        
        //        print("creating forum for game:", forumDataStore.game.id)
        // Navigation related
        // To remove all separators including the actual ones:
        //        UITableView.appearance().separatorStyle = .none
        // for navigation bar title color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        // For navigation bar background color
        UINavigationBar.appearance().barTintColor = appWideAssets.uiColors["darkButNotBlack"]!
        //        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default) //makes status bar translucent
        UINavigationBar.appearance().tintColor = .white
        //                UINavigationBar.appearance().backgroundColor = .clear
        
        // List related
        //        UITableView.appearance().backgroundColor = .clear
        //        UITableViewCell.appearance().backgroundColor = .clear
        
        // To remove only extra separators below the list:
        UITableView.appearance().tableFooterView = UIView()
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
        //        UITableView.appearance().separatorColor = .clear
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
        self.pickedThreadId = threadId
    }
    
    private func togglePickedUser(user: User) {
        if self.pickedUser == user {
            return
        }
        self.pickedUser = user
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
    
    private func followGame() {
        self.forumOtherDataStore.followGame(gameId: self.forumDataStore.game.id)
        self.recentFollowDataStore.followGames.insert(self.forumDataStore.game.id)
    }
    
    private func unfollowGame() {
        self.forumOtherDataStore.unfollowGame(gameId: self.forumDataStore.game.id)
        self.recentFollowDataStore.followGames.remove(self.forumDataStore.game.id)
    }
    
    var body: some View {
        ZStack {
            if colorScheme == .dark {
                appWideAssets.colors["veryDarkGray"]!
                .edgesIgnoringSafeArea(.all)
            } else {
                appWideAssets.colors["kindaDarkGray"]!
                .edgesIgnoringSafeArea(.all)
            }
            
            GeometryReader { a in
                ZStack(alignment: .bottom) {
                    List {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                if self.gameIconLoader.downloadedImage != nil {
                                    Image(uiImage: self.gameIconLoader.downloadedImage!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: a.size.width * 0.15 * 4 / 3, height: a.size.width * 0.15, alignment: .leading)
                                        .cornerRadius(5, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color(.tertiarySystemBackground), lineWidth: 2)
                                    )
                                }
                                
                                FollowerStatsView(forumOtherDataStore: self.forumOtherDataStore, gameName: self.forumDataStore.game.name, width: a.size.width, followGame: self.followGame, unfollowGame: self.unfollowGame, bannerHeight: a.size.width * 0.15)
                            }
                            .frame(width: a.size.width * self.widthContentRatio)
                        }
                        .frame(width: a.size.width, height: a.size.width * 0.3)
                        .padding(.top, 30)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
                        VStack(spacing: 0) {
                            Spacer()
                            Text("- No stickied posts at the moment -")
                                .bold()
                                .foregroundColor(Color.gray)
                                .italic()
                                .padding()
                                .padding(.top, 10)
                            Spacer()
                        }
                        .frame(width: a.size.width)
                        .background(Color(UIColor(named: "pseudoTertiaryBackground")!))
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        
                        if self.forumDataStore.threadsList == nil {
                            VStack {
                                ActivityIndicator()
                                    .frame(width: a.size.width * 0.3, height: a.size.width * 0.3)
                            }
                            .frame(width: a.size.width, height: a.size.height * 0.5)
                            .background(Color(UIColor(named: "pseudoTertiaryBackground")!))
                            .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        } else {
                            ForEach(self.forumDataStore.threadsList!, id: \.self) { threadId in
                                VStack(spacing: 0) {
                                    Divider()
                                    ThreadRow(threadDataStore: self.forumDataStore.threadDataStores[threadId]!, turnBottomPopup: { state in self.turnBottomPopup(state: state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state: state)}, togglePickedUser: { pickedUser in self.togglePickedUser(user: pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(threadId: pickedThreadId, futureContainerWidth: futureContainerWidth)}, width: a.size.width * self.widthContentRatio, height: a.size.height, toggleImageModal : { (threadDataStore, currentImageModalIndex) in self.toggleImageModal(threadDataStore: threadDataStore, currentImageModalIndex: currentImageModalIndex) })
                                }
                                .frame(width: a.size.width, alignment: .center)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowBackground(Color(UIColor(named: "pseudoTertiaryBackground")!))
                            }
                            
                            if self.forumOtherDataStore.forumNextPageStartIndex != nil && self.forumOtherDataStore.forumNextPageStartIndex! == -1 {
                                VStack(spacing: 0) {
                                    Divider()
                                    Spacer()
                                    Image(systemName: "message.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: a.size.width * 0.3, height: a.size.width * 0.3)
                                        .padding()
                                        .foregroundColor(Color(.secondaryLabel))
                                    Text("~Share your own thoughts~")
                                        .bold()
                                        .foregroundColor(Color(.secondaryLabel))
                                        .padding()
                                    Spacer()
                                }
                                .frame(width: a.size.width, height: a.size.height * 0.5)
                                .background(Color(UIColor(named: "pseudoTertiaryBackground")!))
                                .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            } else {
                                ForumLoadMoreView(forumDataStore: self.forumDataStore, forumOtherDataStore: self.forumOtherDataStore, containerWidth: a.size.width * self.widthContentRatio, maxImageHeight: a.size.height * self.maxImageHeightRatio)
                                    .frame(width: a.size.width, height: a.size.height * 0.1)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    // hacky bug fix for rounded corner creating a tiny black line between 2 views
                                    .padding(.top, -10)
                            }
                        }
                    }
                    .frame(width: a.size.width, height: a.size.height)
                    .navigationBarTitle(Text(self.forumDataStore.game.name), displayMode: .inline)
                    .onAppear() {
                        if self.forumDataStore.threadsList == nil {
                            self.forumDataStore.fetchThreads(containerWidth: a.size.width * self.widthContentRatio, forumOtherDataStore: self.forumOtherDataStore, maxImageHeight: a.size.height * self.maxImageHeightRatio)
                            self.forumDataStore.insertGameHistory()
                        }
                        
                        self.recentFollowDataStore.insertVisitGame(gameId: self.forumDataStore.game.id)
                    }
                    
                    NavigationLink(destination: NewThreadView(forumDataStore: self.forumDataStore, forumOtherDataStore: self.forumOtherDataStore, containerWidth: a.size.width * self.widthContentRatio, maxImageHeight: a.size.height * self.maxImageHeightRatio)
                    ) {
                        NewThreadButton()
                            .frame(width: min(a.size.width, a.size.height) * 0.12, height: min(a.size.width, a.size.height) * 0.12, alignment: .center)
                            .shadow(radius: 10)
                    }
                    .position(x: a.size.width * 0.88, y: a.size.height * 0.88)
                    
                    BottomBarView(forumDataStore: self.forumDataStore, isBottomPopupOn: self.$isBottomPopupOn, bottomBarState: self.$bottomBarState, pickedThreadId: self.$pickedThreadId, pickedUser: self.$pickedUser, width: a.size.width, height: a.size.height * 0.25, turnBottomPopup: { state in self.turnBottomPopup(state: state)}, toggleBottomBarState: {state in self.toggleBottomBarState(state: state)}, togglePickedUser: { pickedUser in self.togglePickedUser(user: pickedUser)}, togglePickedThreadId: { (pickedThreadId, futureContainerWidth) in self.togglePickedThreadId(threadId: pickedThreadId, futureContainerWidth: futureContainerWidth)})
                    
                    DummyImageModalView(isImageModalOn: self.$isImageModalOn, threadDataStore: self.$imageModalSelectedThreadStore, currentImageModalIndex: self.$currentImageModalIndex)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
#if DEBUG
//struct ForumView_Previews : PreviewProvider {
//    static var previews: some View {
//        ForumView()
//    }
//}
#endif

struct ActivityIndicator: View {
    @State private var isAnimating: Bool = false
    
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ForEach(0..<5) { index in
                Group {
                    Circle()
                        .fill(Color(.secondaryLabel))
                        .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
                        .offset(y: geometry.size.width / 10 - geometry.size.height / 2)
                }.frame(width: geometry.size.width, height: geometry.size.height)
                    .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(360))
                    .animation(Animation
                        .timingCurve(0.5, 0.15 + Double(index) / 5, 0.25, 1, duration: 1.5)
                        .repeatForever(autoreverses: false))
            }
        }.aspectRatio(1, contentMode: .fit)
            .onAppear {
                self.isAnimating = true
        }
    }
}
