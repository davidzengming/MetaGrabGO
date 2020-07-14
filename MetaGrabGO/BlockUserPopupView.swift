//
//  BlockUserPopupView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-05-13.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct BlockUserPopupView: View {
    @ObservedObject var blockHiddenDataStore: BlockHiddenDataStore
    @Binding var pickedUser: User
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void

    func dismissView() {
        self.toggleBottomBarState(.inActive)
        self.turnBottomPopup(false)
    }

    func blockUser() {
        let taskGroup = DispatchGroup()
        self.blockHiddenDataStore.blockUser(targetBlockUser: self.pickedUser, taskGroup: taskGroup)
        
        taskGroup.notify(queue: .global()) {
            self.dismissView()
        }
    }

    var body: some View {
        GeometryReader { a in
            VStack {
                HStack(alignment: .center) {
                    Image(systemName: "multiply")
                    .resizable()
                    .frame(width: a.size.height * 0.1, height: a.size.height * 0.1)
                        .foregroundColor(.white)
                        .onTapGesture {
                            self.dismissView()
                    }
                    Spacer()
                }
                .frame(width: a.size.width * 0.9, height: a.size.height * 0.1, alignment: .leading)
                .padding(.horizontal, a.size.width * 0.05)
                .padding(.vertical, a.size.height * 0.1)

                Button(action: self.blockUser) {
                    Text("Block " + self.pickedUser.username)
                    .padding(7)
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                }
                .padding(.top, 10)
                Spacer()
            }
        }
    }
}
