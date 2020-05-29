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
    case addEmoji, reportThread, blockUser, inActive
}

class BottomBarStateDataStore: ObservableObject {
    @Published var isBottomPopupOn = false
    @Published var bottomBarState: BottomBarState = .inActive
    @Published var pickedThreadId: Int = -1
    @Published var pickedUser: User = User(id: -1, username: "placeholder")
    
    
    func turnBottomPopup(state: Bool) {
        if self.isBottomPopupOn == state {
            return
        }
        self.isBottomPopupOn = state
    }
    
    func toggleBottomBarState(state: BottomBarState) {
        if self.bottomBarState == state {
            return
        }
        self.bottomBarState = state
    }
    
    func togglePickedThreadId(threadId: Int) {
        if self.pickedThreadId == threadId {
            return
        }
        
        self.pickedThreadId = threadId
    }
    
    func togglePickedUser(user: User) {
        if self.pickedUser == user {
            return
        }
        
        self.pickedUser = user
    }
}

struct ForumView : View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    
    @ObservedObject var forumDataStore: ForumDataStore
    @ObservedObject var gameIconLoader: ImageLoader
    
    @ObservedObject var bottomBarStateDataStore: BottomBarStateDataStore


    init(forumDataStore: ForumDataStore, gameIconLoader: ImageLoader, bottomBarStateDataStore: BottomBarStateDataStore) {
        // To remove only extra separators below the list:
        // UITableView.appearance().tableFooterView = UIView()
        self.forumDataStore = forumDataStore
        self.gameIconLoader = gameIconLoader
        self.bottomBarStateDataStore = bottomBarStateDataStore
        
        // To remove all separators including the actual ones:
        UITableView.appearance().separatorStyle = .none
        // for navigation bar title color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        // For navigation bar background color
        UINavigationBar.appearance().barTintColor = hexStringToUIColor(hex: "#2C2F33")
        //        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default) //makes status bar translucent
        UINavigationBar.appearance().tintColor = .white
        //        UINavigationBar.appearance().backgroundColor = .clear
    }
    
    private func followGame() {
        self.forumDataStore.followGame(access: userDataStore.token!.access, gameId: self.forumDataStore.game.id)
    }
    
    private func unfollowGame() {
        self.forumDataStore.unfollowGame(access: userDataStore.token!.access, gameId: self.forumDataStore.game.id)
    }
    
    var body: some View {
        ZStack {
            Image("background").resizable(resizingMode: .tile)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        ScrollView(.vertical) {
                            VStack(spacing: 0) {
                                VStack {
                                    HStack {
                                        if self.gameIconLoader.downloadedImage != nil {
                                            Image(uiImage: self.gameIconLoader.downloadedImage!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: a.size.width * 0.15, height: a.size.width * 0.15, alignment: .leading)
                                                .cornerRadius(5, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .stroke(Color.white, lineWidth: 2)
                                            )
                                        }
                                        VStack(alignment: .leading) {
                                            Text(self.forumDataStore.game.name)
                                                .font(.system(size: a.size.width * 0.06))
                                                .foregroundColor(Color.white)
                                                .bold()
                                            
                                            HStack {
                                                Text("Posts " + String(self.forumDataStore.game.threadCount))
                                                    .foregroundColor(Color.white)
                                                Text("Follows " + String(self.forumDataStore.game.followerCount))
                                                    .foregroundColor(Color.white)
                                            }
                                            .font(.system(size: a.size.width * 0.04))
                                        }
                                        .padding()
                                        Spacer()
                                        
                                        Text("Follow")
                                            .font(.system(size: a.size.width * 0.04))
                                            .padding(.horizontal, a.size.width * 0.05)
                                            .padding(.vertical, a.size.width * 0.025)
                                            .foregroundColor(self.forumDataStore.isFollowed == true ? Color.white : Color.black)
                                            .background(self.forumDataStore.isFollowed == true ? Color.black : Color.white)
                                            
                                            .cornerRadius(a.size.width * 0.5)
                                            .shadow(radius: a.size.width * 0.05)
                                            .onTapGesture {
                                                if self.forumDataStore.isFollowed == true {
                                                    self.unfollowGame()
                                                } else {
                                                    self.followGame()
                                                }
                                        }
                                    }
                                    .frame(width: a.size.width * 0.9)
                                }
                                .frame(width: a.size.width, height: a.size.width * 0.15)
                                .padding(.vertical, 30)
                                
                                VStack {
                                    Text("No stickied posts at the moment~")
                                        .bold()
                                        .foregroundColor(Color.gray)
                                        .italic()
                                        .padding()
                                        .padding(.top, 10)
                                }
                                .frame(width: a.size.width)
                                .background(Color.white)
                                .cornerRadius(15, corners: [.topLeft, .topRight])
                                
                                VStack {
                                    if self.forumDataStore.isLoaded == false {
                                        Color.white
                                            .frame(width: a.size.width, height: a.size.height * 0.3)
                                    } else {
                                        if self.forumDataStore.threadsList.count > 0 {
                                            ForEach(self.forumDataStore.threadsList, id: \.self) { threadId in
                                                VStack {
                                                    Divider()
                                                    
                                                    if self.forumDataStore.threadDataStores[threadId]!.didLoadImages {
                                                        ThreadRow(threadDataStore: self.forumDataStore.threadDataStores[threadId]!, bottomBarStateDataStore: self.bottomBarStateDataStore, width: a.size.width * 0.9, height: a.size.height)
                                                            .background(Color.white)
                                                            .frame(width: a.size.width, height: a.size.height * 0.045 + 10 + 10 + (self.forumDataStore.threadDataStores[threadId]!.thread.title.isEmpty == false ? 16 : 0) + min(self.forumDataStore.threadDataStores[threadId]!.desiredHeight, 200)
                                                                + 10
                                                                + max(a.size.height * 0.1, min(a.size.height * 0.15, self.forumDataStore.threadDataStores[threadId]!.threadImagesHeight) + 20)
                                                                + a.size.height * 0.025 + CGFloat(self.forumDataStore.threadDataStores[threadId]!.emojis.emojiArr.count) * 30
                                                                + 40 + 20 + 20
                                                        )
                                                    }
                                                }
                                            }
                                        } else {
                                            VStack {
                                                Image(systemName: "pencil.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: a.size.width * 0.3, height: a.size.width * 0.3)
                                                    .padding()
                                                    .foregroundColor(Color(.lightGray))
                                                Text("Create the very first post.")
                                                    .bold()
                                                    .foregroundColor(Color(.lightGray))
                                                    .padding()
                                            }
                                            .frame(width: a.size.width, height: a.size.height * 0.3)
                                        }
                                    }
                                }
                                .background(Color.white)
                                .frame(width: a.size.width)
                                .background(self.assetsDataStore.colors["darkButNotBlack"])
                                
                                ForumLoadMoreView(forumDataStore: self.forumDataStore)
                                    .frame(width: a.size.width, height: a.size.height * 0.1)
                            }
                        }
                        .frame(width: a.size.width, height: a.size.height)
                        //                        .frame(width: a.size.width, height: self.gameDataStore.forumsNextPageStartIndex[self.gameId] != nil && self.gameDataStore.forumsNextPageStartIndex[self.gameId]! != -1 ? a.size.height * 0.95 : a.size.height)
                    }
                    .navigationBarTitle(Text(self.forumDataStore.game.name), displayMode: .inline)
                    .onAppear() {
                        //                        if self.gameDataStore.isBackToGamesView {
                        self.forumDataStore.fetchThreads(access: self.userDataStore.token!.access, userId: self.userDataStore.token!.userId)
                        //                            self.gameDataStore.isBackToGamesView = false
                        ////                        }
                        //
                        self.forumDataStore.insertGameHistory(access: self.userDataStore.token!.access, gameId: self.forumDataStore.game.id)
                    }
                    
                    NavigationLink(destination: NewThreadView(forumDataStore: self.forumDataStore)) {
                        NewThreadButton()
                            .frame(width: min(a.size.width, a.size.height) * 0.12, height: min(a.size.width, a.size.height) * 0.12, alignment: .center)
                            .shadow(radius: 10)
                    }
                    .position(x: a.size.width * 0.88, y: a.size.height * 0.88)
                    
                    if self.bottomBarStateDataStore.isBottomPopupOn == true {
                        VStack {
                            if self.bottomBarStateDataStore.bottomBarState == .addEmoji {
                                EmojiPickerPopupView(forumDataStore: self.forumDataStore, bottomBarStateDataStore: self.bottomBarStateDataStore)
                            }
                        }
                        .frame(width: a.size.width, height: a.size.height * 0.2)
                        .background(self.assetsDataStore.colors["darkButNotBlack"]!)
                        .cornerRadius(5, corners: [.topLeft, .topRight])
                        .KeyboardAwarePadding()
                        .transition(.move(edge: .bottom))
                        .animation(.default)
                    }

                    //                    if self.gameDataStore.isReportPopupActiveByForumId[self.gameId] == true {
                    //                        ReportPopupView(forumId: self.gameId)
                    //                            .background(self.gameDataStore.colors["darkButNotBlack"]!)
                    //                            .cornerRadius(5, corners: [.topLeft, .topRight])
                    //                            .KeyboardAwarePadding()
                    //                            .transition(.move(edge: .bottom))
                    //                            .animation(.default)
                    //                    }
                    //
                    //                    if self.gameDataStore.isBlockPopupActiveByForumId[self.gameId] == true {
                    //                        BlockUserPopupView(forumId: self.gameId)
                    //                            .background(self.gameDataStore.colors["darkButNotBlack"]!)
                    //                            .cornerRadius(5, corners: [.topLeft, .topRight])
                    //                            .transition(.move(edge: .bottom))
                    //                            .animation(.default)
                    //                    }
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
                        .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
                        .scaleEffect(!self.isAnimating ? 1 - CGFloat(index) / 5 : 0.2 + CGFloat(index) / 5)
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