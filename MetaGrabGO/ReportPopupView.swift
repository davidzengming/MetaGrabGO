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
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    
    @State var reportReason: String = ""
    @State var isSendingReport = false
    
    func dismissView() {
        self.togglePickedThreadId(-1, CGFloat(0))
        self.toggleBottomBarState(.inActive)
        self.turnBottomPopup(false)
    }
    
    func submitReport() {
        self.isSendingReport = true
        let taskGroup = DispatchGroup()
        self.forumDataStore.threadDataStores[self.pickedThreadId]!.sendReportByThreadId(reason: self.reportReason, taskGroup: taskGroup, userDataStore: self.userDataStore)
        
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

struct ReportPopupViewThreadVer: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @ObservedObject var threadDataStore: ThreadDataStore
    
    @Binding var pickedThreadId: Int
    @Binding var pickedCommentId: CommentDataStore?
    var turnBottomPopup: (Bool) -> Void
    var toggleBottomBarState: (BottomBarState) -> Void
    var togglePickedUser: (User) -> Void
    var togglePickedThreadId: (Int, CGFloat) -> Void
    var togglePickedCommentId: (CommentDataStore?, CGFloat) -> Void
    
    @State var reportReason: String = ""
    @State var isSendingReport = false
    
    func dismissView() {
        self.togglePickedThreadId(-1, CGFloat(0))
        self.togglePickedCommentId(nil, CGFloat(0))
        self.toggleBottomBarState(.inActive)
        self.turnBottomPopup(false)
    }
    
    func submitReport() {
        self.isSendingReport = true
        let taskGroup = DispatchGroup()
        
        if pickedCommentId == nil {
            self.threadDataStore.sendReportByThreadId(reason: reportReason, taskGroup: taskGroup, userDataStore: self.userDataStore)
        } else {
            self.threadDataStore.childComments[pickedCommentId!.comment.id]!.sendReportByCommentId(reason: reportReason, taskGroup: taskGroup, userDataStore: self.userDataStore)
        }
        
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
