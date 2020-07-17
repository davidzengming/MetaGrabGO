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
    @ObservedObject var forumDataStore: ForumDataStore
    @ObservedObject var forumOtherDataStore: ForumOtherDataStore
    var containerWidth: CGFloat
    var maxImageHeight: CGFloat
    
    private func fetchNextPage() {
        if self.forumOtherDataStore.isLoadingNextPage == true {
            return
        }
        
        self.forumDataStore.fetchThreads(start: self.forumOtherDataStore.forumNextPageStartIndex!, containerWidth: self.containerWidth, forumOtherDataStore: self.forumOtherDataStore, maxImageHeight: maxImageHeight)
    }
    
    var body: some View {
        GeometryReader { a in
            ZStack(alignment: .top) {
                if self.forumDataStore.threadsList != nil && self.forumOtherDataStore.forumNextPageStartIndex != nil && self.forumOtherDataStore.forumNextPageStartIndex != -1 {
                    VStack {
                        Rectangle()
                        .fill(appWideAssets.colors["darkButNotBlack"]!)
                            .frame(height: a.size.height * 0.25)
                        .onAppear() {
                            self.fetchNextPage()
                        }
//                        {
//                            HStack(alignment: .center) {
//                                Spacer()
//                                Image(systemName: "chevron.compact.down")
//                                    .foregroundColor(Color.white)
//                                    .padding(.top, 10)
//                                    .padding(.horizontal, 20)
//                                    .padding(.bottom, 10)
//                                Spacer()
//                                Image(systemName: "chevron.compact.down")
//                                    .foregroundColor(Color.white)
//                                    .padding(.top, 10)
//                                    .padding(.horizontal, 20)
//                                    .padding(.bottom, 10)
//                                Spacer()
//                                Image(systemName: "chevron.compact.down")
//                                    .foregroundColor(Color.white)
//                                    .padding(.top, 10)
//                                    .padding(.horizontal, 20)
//                                    .padding(.bottom, 10)
//                                Spacer()
//                            }
//
//                        } else {
                        Spacer()
                        if self.forumOtherDataStore.isLoadingNextPage {
                            ActivityIndicator()
                                .frame(width: a.size.height * 0.5, height: a.size.height * 0.5)
                                .foregroundColor(Color.white)
                        }
                        Spacer()
                    }
                    .frame(width: a.size.width, height: a.size.height)
                    .background(appWideAssets.colors["darkButNotBlack"]!)
                    .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                }

                Color(.clear)
                    .frame(width: a.size.width, height: a.size.height * 0.25)

                VStack {
                    Color(.tertiarySystemBackground)
                        .frame(width: a.size.width, height: a.size.height * 0.25)
                        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    Spacer()
                }
            }
        }
    }
}
