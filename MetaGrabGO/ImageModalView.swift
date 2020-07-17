//
//  ImageModalView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-07-08.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct ImageModalView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Environment(\.imageCache) private var cache: ImageCache
    @Binding var threadDataStore: ThreadDataStore?
    @Binding var currentImageModalIndex: Int?
    
    var body: some View {
        GeometryReader { a in
            ZStack {
                Color.black
                ZStack {
                    if self.threadDataStore!.imageLoaders[self.currentImageModalIndex!]!.downloadedImage != nil {
                        Image(uiImage: self.threadDataStore!.imageLoaders[self.currentImageModalIndex!]!.downloadedImage!)
                            .resizable()
                            .transition(AnyTransition.slide)
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Rectangle()
                            .fill(appWideAssets.colors["darkButNotBlack"]!)
                            .aspectRatio(contentMode: .fit)
                    }
                    
                    VStack {
                        HStack(alignment: .center) {
                            Image(systemName: "multiply")
                                .resizable()
                                .frame(width: a.size.height * 0.025, height: a.size.height * 0.025)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    self.presentationMode.wrappedValue.dismiss()
                            }
                                
                            HStack {
                                Text(String(self.currentImageModalIndex! + 1))
                                    .bold()
                                Text("/")
                                    .bold()
                                Text(String(self.threadDataStore!.imageLoaders.count))
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                            Spacer()
                        }
                        .frame(width: a.size.width * 0.9, height: a.size.height * 0.05, alignment: .leading)
                        Spacer()
                    }
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        if value.translation.width < 20 {
                            if self.currentImageModalIndex! < self.threadDataStore!.imageLoaders.count - 1 {
                                self.currentImageModalIndex! += 1
                            }
                        }
                        
                        if value.translation.width > 20 {
                            if self.currentImageModalIndex! > 0 {
                                self.currentImageModalIndex! -= 1
                            }
                        }
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
