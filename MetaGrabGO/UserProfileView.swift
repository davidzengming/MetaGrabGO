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
    
    @State var showImagePicker: Bool = false
    @State var image: Image = Image(systemName: "person.circle.fill")
    @State var data: Data?
    
    private func logout() {
        self.userDataStore.logout()
        self.recentFollowDataStore.shouldRefreshDataStore = true
    }
    
    func uploadProfileImage(data: Data) {
        self.userDataStore.uploadProfilePicture(data: data)
    }
    
    init(blockHiddenDataStore: BlockHiddenDataStore) {
        self.blockHiddenDataStore = blockHiddenDataStore
         // To remove only extra separators below the list:
           UITableView.appearance().tableFooterView = UIView()
           // To remove all separators including the actual ones:
           UITableView.appearance().separatorStyle = .none
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        // For navigation bar background color
        UINavigationBar.appearance().barTintColor = hexStringToUIColor(hex: "#2C2F33")
        //        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default) //makes status bar translucent
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        ZStack {
            appWideAssets.colors["notQuiteBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                Spacer()
                List {
                    HStack {
                        Spacer()
                        if self.userDataStore.profileImageLoader != nil && self.userDataStore.profileImageLoader!.downloadedImage != nil {
                            VStack(alignment: .center) {
                                ZStack {
                                    Image(uiImage: self.userDataStore.profileImageLoader!.downloadedImage!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: a.size.width * 0.2, height: a.size.width * 0.2)
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
                                .padding(.vertical)
                                
                                Text(keychainService.getUserName())
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(Color.white)

                            }
                        } else {
                            VStack(alignment: .center) {
                                ZStack {
                                    self.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: a.size.width * 0.2, height: a.size.width * 0.2)
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
                                .padding(.vertical)
                                
                                Text(keychainService.getUserName())
                                .font(.title)
                                .bold()
                                .foregroundColor(Color.white)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        NavigationLink(destination: LazyView {
                            PersonalInfoView()
                        }) {
                            Text("Account Profile")
                        }
                        
                    }
                    .padding()
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    HStack {
                        NavigationLink(destination: LazyView {
                            UnblockContentView(blockHiddenDataStore: self.blockHiddenDataStore)
                        }) {
                            Text("Unblock Content")
                        }
                        
                    }
                    .padding()
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    HStack {
                        NavigationLink(destination: LazyView {
                            AcknowledgementsView()
                        }) {
                            Text("Acknowledgements")
                        }
                    }
                    .padding()
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: self.logout) {
                            Text("Sign out")
                                .foregroundColor(Color.red)
                        }
                        Spacer()
                    }
                    .padding()
                    .shadow(radius: 5)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
            }
            .foregroundColor(Color.white)
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
