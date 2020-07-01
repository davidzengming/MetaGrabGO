//
//  ForumLoadMoreView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-28.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI
import Combine

struct ForumLoadMoreView: View {
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    
    @ObservedObject var forumDataStore: ForumDataStore
    @ObservedObject var forumOtherDataStore: ForumOtherDataStore
    var containerWidth: CGFloat
    
    private func fetchNextPage() {
        if self.forumOtherDataStore.isLoadingNextPage == true {
            return
        }
        
        self.forumDataStore.fetchThreads(access: self.userDataStore.token!.access, start: self.forumOtherDataStore.forumNextPageStartIndex!, userId: self.userDataStore.token!.userId, containerWidth: self.containerWidth, forumOtherDataStore: self.forumOtherDataStore)
    }
    
    var body: some View {
        GeometryReader { a in
            ZStack(alignment: .top) {
                if self.forumOtherDataStore.isLoaded && self.forumOtherDataStore.forumNextPageStartIndex != nil && self.forumOtherDataStore.forumNextPageStartIndex != -1 {
                    VStack {
                        Rectangle()
                            .frame(height: a.size.height * 0.25)
                            .background(self.assetsDataStore.colors["darkButNotBlack"]!)

                        Spacer()

                        if !self.forumOtherDataStore.isLoadingNextPage {
                            HStack(alignment: .center) {
                                Spacer()
                                Image(systemName: "chevron.compact.down")
                                    .foregroundColor(Color.white)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                Spacer()
                                Image(systemName: "chevron.compact.down")
                                    .foregroundColor(Color.white)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                Spacer()
                                Image(systemName: "chevron.compact.down")
                                    .foregroundColor(Color.white)
                                    .padding(.top, 10)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                Spacer()
                            }
                            .onAppear() {
                                self.fetchNextPage()
                            }
                        } else {
                            ActivityIndicator()
                                .frame(width: a.size.height * 0.5, height: a.size.height * 0.5)
                                .foregroundColor(Color.white)
                        }

                        Spacer()
                    }
                    .frame(width: a.size.width, height: a.size.height)
                    .background(self.assetsDataStore.colors["darkButNotBlack"]!)
                    .cornerRadius(15, corners: [.bottomLeft, .bottomRight])

                }

                self.assetsDataStore.colors["darkButNotBlack"]!
                    .frame(width: a.size.width, height: a.size.height * 0.25)

                VStack {
                    Color.white
                        .frame(width: a.size.width, height: a.size.height * 0.25)
                        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    Spacer()
                }
            }
        }
    }
}
