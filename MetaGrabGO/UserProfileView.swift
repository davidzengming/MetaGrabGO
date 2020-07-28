//
//  UserProfileView.swift
//  MetaGrab
//
//  Created by David Zeng on 2020-05-11.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var recentFollowDataStore: RecentFollowDataStore
    @ObservedObject var blockHiddenDataStore: BlockHiddenDataStore
    
    @State private var loadedBlacklist = false
    @State private var loadedHiddenThreads = false
    @State private var loadedHiddenComments = false
    @State var showImagePicker: Bool = false
    @State var image: Image = Image(systemName: "person.circle.fill")
    @State var data: Data?
    
    private func unblockUser(unblockUser: User) {
        self.blockHiddenDataStore.unblockUser(targetUnblockUser: unblockUser)
    }
    
    private func unhideThread(threadId: Int) {
        self.blockHiddenDataStore.unhideThread(threadId: threadId)
    }
    
    private func unhideComment(commentId: Int) {
        self.blockHiddenDataStore.unhideComment(commentId: commentId)
    }
    
    private func fetchBlacklistedUsers() {
        self.blockHiddenDataStore.fetchBlacklistedUsers()
        self.loadedBlacklist = true
    }
    
    private func fetchHiddenThreads() {
        self.blockHiddenDataStore.fetchHiddenThreads()
        self.loadedHiddenThreads = true
    }
    
    private func fetchHiddenComments() {
        self.blockHiddenDataStore.fetchHiddenComments()
        self.loadedHiddenComments = true
    }
    
    private func logout() {
        self.userDataStore.logout()
        self.recentFollowDataStore.shouldRefreshDataStore = true
        
    }
    
    func uploadProfileImage(data: Data) {
        self.userDataStore.uploadProfilePicture(data: data)
    }
    
    var body: some View {
        ZStack {
            appWideAssets.colors["darkButNotBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                VStack {
                    HStack(alignment: .center) {
                        if self.userDataStore.profileImageLoader != nil && self.userDataStore.profileImageLoader!.downloadedImage != nil {
                            HStack(alignment: .center) {
                                
                                ZStack {
                                    Image(uiImage: self.userDataStore.profileImageLoader!.downloadedImage!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: a.size.width * 0.1, height: a.size.width * 0.1)
                                        .shadow(radius: 10)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                                        .foregroundColor(Color.orange)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            self.showImagePicker = true
                                    }
                                    
                                    if self.userDataStore.isLoadingPicture == true {
                                        ActivityIndicator()
                                        .frame(width: a.size.width * 0.1, height: a.size.width * 0.1)
                                    }
                                }
                                
                                
                                Text(keychainService.getUserName())
                                .bold()
                                .foregroundColor(Color.white)
                                Spacer()
                            }
                        } else {
                            HStack {
                                ZStack {
                                    self.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: a.size.width * 0.1, height: a.size.width * 0.1)
                                        .shadow(radius: 10)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                                        .foregroundColor(Color.orange)
                                        .clipShape(Circle())
                                        .onTapGesture {
                                            self.showImagePicker = true
                                    }
                                    .onAppear() {
                                        if self.userDataStore.profileImageLoader != nil {
                                            self.userDataStore.profileImageLoader!.load()
                                        }
                                    }
                                    
                                    if self.userDataStore.isLoadingPicture == true {
                                        ActivityIndicator()
                                        .frame(width: a.size.width * 0.1, height: a.size.width * 0.1)
                                    }
                                }
                                
                                HStack(alignment: .top) {
                                    Text(keychainService.getUserName())
                                }
                                .foregroundColor(Color.white)
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        Button(action: self.logout) {
                            Text("Logout")
                                .bold()
                                .foregroundColor(Color.white)
                        }
                    }
                    .frame(width: a.size.width * 0.95)
                    
                    Spacer()
                    VStack {
                        ScrollView {
                                VStack {
                                    VStack {
                                        Text("BLACKLISTED USERS")
                                            .tracking(1)
                                            .padding()
                                            .frame(width: a.size.width * 0.95, height: a.size.height * 0.05, alignment: .leading)
                                            .background(appWideAssets.colors["teal"]!)
                                        
                                        if self.loadedBlacklist == false {
                                            Button(action: self.fetchBlacklistedUsers) {
                                                Text("Show blacklisted users")
                                                    .padding()
                                                    .background(Color.red)
                                                    .foregroundColor(Color.white)
                                                    .cornerRadius(10)
                                            }
                                            .padding()
                                        } else if self.loadedBlacklist == true && self.blockHiddenDataStore.blacklistedUserIdArr.isEmpty {
                                            Text("There are no blacklisted users.")
                                                .padding()
                                        }
                                        
                                        ForEach(self.blockHiddenDataStore.blacklistedUserIdArr, id: \.self) { blacklistedUserId in
                                            HStack {
                                                Text(String(self.blockHiddenDataStore.blacklistedUsersById[blacklistedUserId]!.username))
                                                HStack(alignment: .center) {
                                                    Image(systemName: "multiply")
                                                        .resizable()
                                                        .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                                                        .foregroundColor(.red)
                                                        .onTapGesture {
                                                            self.unblockUser(unblockUser: self.blockHiddenDataStore.blacklistedUsersById[blacklistedUserId]!)
                                                    }
                                                }
                                                
                                            }
                                            .padding()
                                        }
                                    }
                                    .frame(width: a.size.width * 0.95)
                                    .background(appWideAssets.colors["notQuiteBlack"])
                                    .padding()
                                    
                                    VStack {
                                        Text("HIDDEN THREADS")
                                            .tracking(1)
                                            .padding()
                                            .frame(width: a.size.width * 0.95, height: a.size.height * 0.05, alignment: .leading)
                                            .background(appWideAssets.colors["teal"]!)
                                        
                                        if self.loadedHiddenThreads == false {
                                            Button(action: self.fetchHiddenThreads) {
                                                Text("Show hidden threads")
                                                    .padding()
                                                    .background(Color.red)
                                                    .foregroundColor(Color.white)
                                                    .cornerRadius(10)
                                            }
                                            .padding()
                                            
                                        } else if self.loadedHiddenThreads == true && self.blockHiddenDataStore.hiddenThreadIdArr.isEmpty {
                                            Text("There are no hidden threads.")
                                                .padding()
                                        }
                                        
                                        ForEach(self.blockHiddenDataStore.hiddenThreadIdArr, id: \.self) { hiddenThreadId in
                                            HStack {
                                                Text(String(hiddenThreadId))
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                                                    .foregroundColor(.red)
                                                    .onTapGesture {
                                                        self.unhideThread(threadId: hiddenThreadId)
                                                }
                                            }.padding()
                                        }
                                    }
                                    .frame(width: a.size.width * 0.95)
                                    .background(appWideAssets.colors["notQuiteBlack"])
                                    .padding()
                                    
                                    VStack {
                                        Text("HIDDEN COMMENTS")
                                            .tracking(1)
                                            .padding()
                                            .frame(width: a.size.width * 0.95, height: a.size.height * 0.05, alignment: .leading)
                                            .background(appWideAssets.colors["teal"]!)
                                        
                                        if self.loadedHiddenComments == false {
                                            Button(action: self.fetchHiddenComments) {
                                                Text("Show hidden comments")
                                                    .padding()
                                                    .background(Color.red)
                                                    .foregroundColor(Color.white)
                                                    .cornerRadius(10)
                                            }
                                            .padding()
                                        } else if self.loadedHiddenComments == true && self.blockHiddenDataStore.hiddenCommentIdArr.isEmpty {
                                            Text("There are no hidden comments.")
                                                .padding()
                                        }
                                        
                                        ForEach(self.blockHiddenDataStore.hiddenCommentIdArr, id: \.self) { hiddenCommentId in
                                            HStack {
                                                Text(self.blockHiddenDataStore.hiddenCommentsById[hiddenCommentId]!.contentString)
                                                Image(systemName: "multiply")
                                                    .resizable()
                                                    .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                                                    .foregroundColor(.red)
                                                    .onTapGesture {
                                                        self.unhideComment(commentId: hiddenCommentId)
                                                }
                                            }.padding()
                                        }
                                    }
                                    .frame(width: a.size.width * 0.95)
                                    .background(appWideAssets.colors["notQuiteBlack"])
                                    .padding()
                                }
                                .frame(width: a.size.width, height: a.size.height * 0.7)
                                .foregroundColor(Color.white)
                        }
                        .frame(width: a.size.width, height: a.size.height * 0.8)
                    }
                }
                .sheet(isPresented: self.$showImagePicker) {
                    ProfileImagePicker(isImagePickerShown: self.$showImagePicker, image: self.$image, data: self.$data, uploadProfileImage: { data in
                        self.uploadProfileImage(data: data)
                    })
                        .background(appWideAssets.colors["darkButNotBlack"]!)
                        .cornerRadius(5, corners: [.topLeft, .topRight])
                        .transition(.move(edge: .bottom))
                        .animation(.default)
                }
            }
        }
    }
}

struct ProfileImagePicker: UIViewControllerRepresentable {
    @Binding var isImagePickerShown: Bool
    @Binding var image: Image
    @Binding var data: Data?
    
    var uploadProfileImage: (Data) -> Void
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ProfileImagePicker
        
        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            self.parent.image = Image(uiImage: uiImage!)
            self.parent.data = uiImage!.pngData()
            
            self.parent.uploadProfileImage(self.parent.data!)
            self.parent.isImagePickerShown = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.isImagePickerShown = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ProfileImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ProfileImagePicker>) {
    }
}
