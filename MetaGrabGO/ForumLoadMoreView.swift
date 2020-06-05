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
    var containerWidth: CGFloat
    
    private func fetchNextPage() {
        self.forumDataStore.fetchThreads(access: self.userDataStore.token!.access, start: self.forumDataStore.forumNextPageStartIndex!, userId: self.userDataStore.token!.userId, containerWidth: self.containerWidth)
    }
    
    var body: some View {
        GeometryReader { a in
            ZStack(alignment: .top) {
                if self.forumDataStore.isLoaded && self.forumDataStore.forumNextPageStartIndex != nil && self.forumDataStore.forumNextPageStartIndex != -1 {
                    VStack {
                        Rectangle()
                            .frame(height: a.size.height * 0.25)
                            .background(self.assetsDataStore.colors["darkButNotBlack"]!)
                        
                        Spacer()
                        
                        if !self.forumDataStore.isLoadingNextPage {
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
                    .onTapGesture {
                        self.fetchNextPage()
                    }
                }
                
                self.assetsDataStore.colors["darkButNotBlack"]!
                    .frame(width: a.size.width, height: a.size.height * 0.25)
                
                Color.white
                    .frame(width: a.size.width, height: a.size.height * 0.25)
                    .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
            }
        }
    }
}
