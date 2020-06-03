//
//  ReportPopupView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-05-12.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct ReportPopupView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @ObservedObject var forumDataStore: ForumDataStore
    
    @Binding var pickedThreadId: Int
    
//    var turnBottomPopup: (_ state: Bool) -> Void
//    var toggleBottomBarState: (_ state: BottomBarState) -> Void
//    var togglePickedThreadId: (_ threadId: Int) -> Void
//    var togglePickedUser: (_ user: User) -> Void
    
    @State var reportReason: String = ""
    @State var isSendingReport = false
    
    func dismissView() {
//        self.togglePickedThreadId(-1)
//        self.toggleBottomBarState(.inActive)
//        self.turnBottomPopup(false)
    }
    
    func submitReport() {
        self.isSendingReport = true
        let taskGroup = DispatchGroup()
        self.forumDataStore.threadDataStores[self.pickedThreadId]!.sendReportByThreadId(access: self.userDataStore.token!.access, reason: reportReason, taskGroup: taskGroup)
        
        taskGroup.notify(queue: .global()) {
            self.isSendingReport = false
            self.dismissView()
        }
    }
    
    var body: some View {
        GeometryReader { a in
            VStack {
                HStack {
                    ZStack {
                        HStack {
                            Image(systemName: "multiply")
                            .resizable()
                            .frame(width: a.size.height * 0.1, height: a.size.height * 0.1)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    self.dismissView()
                            }
                            .padding()
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text("Submit a report")
                                .foregroundColor(Color.white)
                            Spacer()
                        }
                    }


                }
                 
                TextField("Enter the reason", text: self.$reportReason)
                    .frame(width: a.size.width * 0.9)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                
                if !self.isSendingReport {
                    Button(action: self.submitReport) {
                        Text("Submit")
                            .padding(.all, 10)
                            .background(Color.red)
                            .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .padding()
                    }
                } else {
                    ActivityIndicator()
                        .frame(width: a.size.height * 0.2, height: a.size.height * 0.05)
                    .padding(.top, 10)
                }
                Spacer()
            }
        }
    }
}
