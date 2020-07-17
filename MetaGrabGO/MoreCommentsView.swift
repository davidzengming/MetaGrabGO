//
//  MoreCommentsView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-03-11.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct MoreCommentsView: View {
    @ObservedObject var commentDataStore: CommentDataStore
    
    var width: CGFloat
    var leadLineWidth: CGFloat
    var verticalPadding: CGFloat
    var level: Int
    
    private func getNumChildCommentsNotLoaded() -> Int {
        return self.commentDataStore.comment.numChilds - self.commentDataStore.childComments.count
    }
    
    private func getReplyPlurality() -> String {
        if self.commentDataStore.comment.numChilds - self.commentDataStore.childCommentList.count > 1 {
            return "replies"
        }
        return "reply"
    }
    
    private func fetchNextPage() {
        self.commentDataStore.fetchCommentTreeByCommentId(start: self.commentDataStore.childCommentList.count, refresh: true, containerWidth: self.width + 10, leadPadding: 20)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(appWideAssets.leadingLineColors[self.level % appWideAssets.leadingLineColors.count])
                    .frame(width: self.leadLineWidth, height: 20)
                    .padding(.trailing, 10)
                
                HStack(spacing: 0) {
                    Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    
                    Text("See \(self.getNumChildCommentsNotLoaded()) more \(self.getReplyPlurality())")
                        .padding(.leading, 10)
                }
                .frame(width: self.width, height: 20, alignment: .leading)
                .onTapGesture() {
                    self.fetchNextPage()
                }
                .padding(.vertical, self.verticalPadding)
            }
        }
    }
}
