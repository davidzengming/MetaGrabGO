//
//  MoreCommentsView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-03-11.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct MoreCommentsView: View {
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    @EnvironmentObject var userDataStore: UserDataStore
    @ObservedObject var commentDataStore: CommentDataStore
    
    var width: CGFloat
    var leadLineWidth: CGFloat
    var staticPadding: CGFloat
    var verticalPadding: CGFloat
    var level: Int
    
    func getNumChildCommentsNotLoaded() -> Int {
        return self.commentDataStore.comment.numChilds - self.commentDataStore.childComments.count
    }
    
    func getReplyPlurality() -> String {
        if self.commentDataStore.comment.numChilds - self.commentDataStore.childCommentList.count > 1 {
            return "replies"
        }
        return "reply"
    }
    
    func fetchNextPage() {
        self.commentDataStore.fetchCommentTreeByCommentId(start: self.commentDataStore.childCommentList.count, refresh: true, userId: self.userDataStore.token!.userId, containerWidth: self.width + self.staticPadding * 2 + 10, leadPadding: 20, userDataStore: self.userDataStore)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(red: 225 / 255, green: 225 / 255, blue: 225 / 255))
            .frame(width: self.width + self.staticPadding * 2 + 10 + self.leadLineWidth, height: 1, alignment: .leading)
            
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(self.assetsDataStore.leadingLineColors[self.level % self.assetsDataStore.leadingLineColors.count])
                    .frame(width: self.leadLineWidth, height: 20)
                    .padding(.trailing, 10)
                
                HStack(spacing: 0) {
                    Text("See \(self.getNumChildCommentsNotLoaded()) more \(self.getReplyPlurality())")
                        .padding(.leading, 10)
                    Spacer()
                    Image(systemName: "chevron.compact.down")
                }
                .frame(width: self.width, height: 20, alignment: .leading)
                .onTapGesture() {
                    self.fetchNextPage()
                }
                .padding(.horizontal, self.staticPadding)
                .padding(.vertical, self.verticalPadding)
            }
        }
    }
}
