//
//  NewThreadView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-09-03.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct IdentifiableImageContainer: Identifiable {
    var id = UUID()
    var image: Image?
    var arrayIndex: Int
}

struct NewThreadView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var userDataStore: UserDataStore
    @EnvironmentObject var assetsDataStore: AssetsDataStore
    
    @ObservedObject var forumDataStore: ForumDataStore
    
    var containerWidth: CGFloat
    
    @State var title: String = ""
    @State var flair = 0
    @State var content: NSTextStorage = NSTextStorage(string: "")
    
    @State var showImagePicker = false
    @State var imagesDict: [UUID: Image] = [:]
    @State var dataDict: [UUID: Data] = [:]
    @State var imagesArray: [UUID] = [UUID()]
    @State var clickedImageIndex : Int?
    @State var isFirstResponder = true
    @State var didBecomeFirstResponder = false
    
    let placeholder = Image(systemName: "photo")
    let maxNumImages = 3
    
    func submitThread() {
        if self.showImagePicker == true {
            self.showImagePicker = false
            self.forumDataStore.submitThread(forumDataStore: self.forumDataStore, access:self.userDataStore.token!.access, title: self.title, flair: self.flair, content: self.content, imageData: self.dataDict, imagesArray: self.imagesArray, userId: self.userDataStore.token!.userId, containerWidth: self.containerWidth)
            self.presentationMode.wrappedValue.dismiss()
        } else {
            self.forumDataStore.submitThread(forumDataStore: self.forumDataStore, access:self.userDataStore.token!.access, title: self.title, flair: self.flair, content: self.content, imageData: self.dataDict, imagesArray: self.imagesArray, userId: self.userDataStore.token!.userId, containerWidth: self.containerWidth)
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func removeImage() {
        let removedImageUUID = imagesArray[clickedImageIndex!]
        imagesArray.remove(at: clickedImageIndex!)
        imagesDict.removeValue(forKey: removedImageUUID)
        dataDict.removeValue(forKey: removedImageUUID)
        
        if imagesDict[imagesArray.last!] != nil {
            imagesArray.append(UUID())
        }
    }
    
    var body: some View {
        GeometryReader { a in
            VStack {
                TextField("Add a title! (Optional)", text: self.$title)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                HStack(spacing: 25) {
                    ForEach(self.imagesArray, id: \.self) { id in
                        ZStack {
                            if self.imagesDict[id] != nil {
                                self.imagesDict[id]!.resizable()
                                    .frame(width: 100, height: 100, alignment: .leading)
                            }
                            Button(action: {
                                self.clickedImageIndex = self.imagesArray.firstIndex(of: id)!
                                self.showImagePicker = true
                            }) {
                                UploadDashPlaceholderButton()
                                    .foregroundColor(Color.gray)
                                    .frame(width: 100, height: 100, alignment: .leading)
                                    .opacity(self.imagesDict[id] != nil ? 0.5 : 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if self.imagesDict[id] != nil {
                                Button(action: {
                                    self.clickedImageIndex = self.imagesArray.firstIndex(of: id)!
                                    self.removeImage()
                                }) {
                                    Image(uiImage: UIImage(systemName: "minus.circle.fill")!)
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                }
                                .foregroundColor(Color.red)
                                .offset(x: 50, y: -50)
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                
                FancyPantsEditorView(existedTextStorage: .constant(NSTextStorage(string: "")), desiredHeight: .constant(0), newTextStorage: self.$content, isEditable: .constant(true), isFirstResponder: self.$isFirstResponder, didBecomeFirstResponder: self.$didBecomeFirstResponder, showFancyPantsEditorBar: .constant(false), isNewContent: true, isThread: true, isOmniBar: false, width: a.size.width, height: a.size.height)
                    .frame(minWidth: 0, maxWidth: a.size.width, minHeight: 0, maxHeight: a.size.height * 0.5, alignment: .leading)
                    .cornerRadius(5, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight])
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                )
                .padding()
                .transition(.move(edge: .bottom))
                .animation(.default)
                Spacer()
            }
            .sheet(isPresented: self.$showImagePicker) {
                ImagePicker(isImagePickerShown: self.$showImagePicker, image: self.$imagesDict[self.imagesArray[self.clickedImageIndex!]], data: self.$dataDict[self.imagesArray[self.clickedImageIndex!]], currentImages: self.$imagesArray, imagesDict: self.$imagesDict, dataDict: self.$dataDict)
                        .frame(width: a.size.width)
                        .background(self.assetsDataStore.colors["darkButNotBlack"]!)
                        .cornerRadius(5, corners: [.topLeft, .topRight])
                        .transition(.move(edge: .bottom))
                        .animation(.default)
            }
            .KeyboardAwarePadding()
            .navigationBarTitle(Text("Post to \(self.forumDataStore.game.name)"))
            .navigationBarItems(trailing: Button(action: self.submitThread) {
                Text("Submit")
            })
        }
    }
}
