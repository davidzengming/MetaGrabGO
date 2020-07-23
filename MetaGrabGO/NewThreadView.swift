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
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var forumDataStore: ForumDataStore
    @ObservedObject var forumOtherDataStore: ForumOtherDataStore
    
    var containerWidth: CGFloat
    var maxImageHeight: CGFloat
    
    @State private var title: String = ""
    @State private var flair = 0
    @State private var content: NSTextStorage = NSTextStorage(string: "")
    
    @State private var showImagePicker = false
    @State private var imagesDict: [UUID: Image] = [:]
    @State private var dataDict: [UUID: Data] = [:]
    @State private var imagesArray: [UUID] = [UUID()]
    @State private var clickedImageIndex : Int?
    @State private var isFirstResponder = true
    @State private var didBecomeFirstResponder = false
    
    private let maxNumImages = 3
    
    init(forumDataStore: ForumDataStore, forumOtherDataStore: ForumOtherDataStore, containerWidth: CGFloat, maxImageHeight: CGFloat) {
        self.forumDataStore = forumDataStore
        self.forumOtherDataStore = forumOtherDataStore
        self.containerWidth = containerWidth
        self.maxImageHeight = maxImageHeight
    }
    
    func submitThread() {
        if self.showImagePicker == true {
            self.showImagePicker = false
            self.forumDataStore.submitThread(forumDataStore: self.forumDataStore, title: self.title, flair: self.flair, content: self.content, imageData: self.dataDict, imagesArray: self.imagesArray, userId: keychainService.getUserId(), containerWidth: self.containerWidth, forumOtherDataStore: self.forumOtherDataStore, maxImageHeight: maxImageHeight)
            self.presentationMode.wrappedValue.dismiss()
        } else {
            self.forumDataStore.submitThread(forumDataStore: self.forumDataStore, title: self.title, flair: self.flair, content: self.content, imageData: self.dataDict, imagesArray: self.imagesArray, userId: keychainService.getUserId(), containerWidth: self.containerWidth, forumOtherDataStore: self.forumOtherDataStore, maxImageHeight: maxImageHeight)
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
    
    var submitButton: some View {
        return Button(action: { self.submitThread() }) {
            Text("Submit")
                // MARK: Inconsistent color unless specified
                .foregroundColor(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var body: some View {
        GeometryReader { a in
            VStack {
                TextField("Add a title! (Optional)", text: self.$title)
                    .frame(width: a.size.width * 0.9, alignment: .leading)
                    .autocapitalization(.none)
                    .cornerRadius(5, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight])
                    .padding(.top, 20)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    ForEach(self.imagesArray, id: \.self) { id in
                        ZStack {
                            if self.imagesDict[id] != nil {
                                ZStack(alignment: .topTrailing) {
                                    Button(action: {
                                        self.clickedImageIndex = self.imagesArray.firstIndex(of: id)!
                                        self.showImagePicker = true
                                    }) {
                                        self.imagesDict[id]!
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(5)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button(action: {
                                        self.clickedImageIndex = self.imagesArray.firstIndex(of: id)!
                                        self.removeImage()
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .resizable()
                                            .frame(width: a.size.height * 0.035, height: a.size.height * 0.035)
                                            .offset(x: a.size.height * 0.035 * 0.5, y: -a.size.height * 0.035 * 0.5)
                                    }
                                    .foregroundColor(Color.red)
                                }
                                
                            } else {
                                Button(action: {
                                    self.clickedImageIndex = self.imagesArray.firstIndex(of: id)!
                                    self.showImagePicker = true
                                }) {
                                    UploadDashPlaceholderButton()
                                        .foregroundColor(Color.gray)
                                        .frame(width: a.size.height * 0.15, height: a.size.height * 0.15 , alignment: .leading)
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(5)
                                        .background(Color(.tertiarySystemBackground))
                                        .opacity(self.imagesDict[id] != nil ? 0.1 : 1)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .frame(width: a.size.width * 0.9, height: a.size.height * 0.15, alignment: .leading)
                .padding()
                
                FancyPantsEditorView(existedTextStorage: .constant(NSTextStorage(string: "")), desiredHeight: .constant(0), newTextStorage: self.$content, isEditable: .constant(true), isFirstResponder: self.$isFirstResponder, didBecomeFirstResponder: self.$didBecomeFirstResponder, showFancyPantsEditorBar: .constant(false), isNewContent: true, isThread: true, isOmniBar: false, width: a.size.width, height: a.size.height)
                    .frame(minWidth: a.size.width * 0.9, maxWidth: a.size.width * 0.9, minHeight: 0, maxHeight: a.size.height * 0.5, alignment: .leading)
                    .background(Color(.tertiarySystemBackground))
                    .cornerRadius(5, corners: [.bottomLeft, .bottomRight, .topLeft, .topRight])
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 2)
                )
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom))
                    .animation(.default)
                Spacer()
            }
            .KeyboardAwarePadding()
            .sheet(isPresented: self.$showImagePicker) {
                ImagePicker(isImagePickerShown: self.$showImagePicker, image: self.$imagesDict[self.imagesArray[self.clickedImageIndex!]], data: self.$dataDict[self.imagesArray[self.clickedImageIndex!]], currentImages: self.$imagesArray, imagesDict: self.$imagesDict, dataDict: self.$dataDict)
                    .frame(width: a.size.width)
                    .background(appWideAssets.colors["darkButNotBlack"]!)
                    .cornerRadius(5, corners: [.topLeft, .topRight])
                    .transition(.move(edge: .bottom))
                    .animation(.default)
            }
        }
        .navigationBarTitle(Text("Post to \(self.forumDataStore.game.name)"))
        .navigationBarItems(trailing: submitButton)
    }
}
