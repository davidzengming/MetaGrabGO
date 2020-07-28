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
    
    @State private var offset: CGFloat = 0
    @Binding var index: Int
    
    let spacing: CGFloat = 20
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: self.spacing) {
                            ForEach(self.threadDataStore!.imageArr, id: \.self) { id in
                                HStack {
                                    if self.threadDataStore!.imageLoaders[id]!.downloadedImage != nil {
                                        Image(uiImage: self.threadDataStore!.imageLoaders[id]!.downloadedImage!)
                                            .resizable()
                                            .transition(AnyTransition.slide)
                                            .aspectRatio(contentMode: .fit)
                                    } else {
                                        Rectangle()
                                            .fill(appWideAssets.colors["darkButNotBlack"]!)
                                            .aspectRatio(contentMode: .fit)
                                    }
                                }
                                .frame(width: geometry.size.width)
                            }
                        }
                    }
                    .content.offset(x: self.offset)
                    .frame(width: geometry.size.width, alignment: .leading)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                self.offset = value.translation.width - geometry.size.width * CGFloat(self.index)
                            })
                            .onEnded({ value in
                                if value.predictedEndTranslation.width > geometry.size.width / 2 {
                                    
                                    if self.index > 0 {
                                        self.index -= 1
                                    } else {
                                        withAnimation {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                        return
                                    }
                                }
                                
                                if -value.predictedEndTranslation.width > geometry.size.width / 2, self.index < self.threadDataStore!.imageArr.count - 1 {
                                    self.index += 1
                                }
                                
                                withAnimation(.spring()) { self.offset = -(geometry.size.width + self.spacing) * CGFloat(self.index) }
                            })
                    )
                    
                    VStack {
                        HStack(alignment: .center) {
                            Image(systemName: "multiply")
                                .resizable()
                                .frame(width: geometry.size.height * 0.025, height: geometry.size.height * 0.025)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    self.presentationMode.wrappedValue.dismiss()
                            }
                            
                            HStack {
                                Text(String(self.index + 1))
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
                        .frame(width: geometry.size.width * 0.95, height: geometry.size.height * 0.05, alignment: .leading)
                        .padding(.top, geometry.size.height * 0.02)
                        Spacer()
                    }
                }
                .onAppear() {
                    self.offset = -(geometry.size.width + self.spacing) * CGFloat(self.index)
                }
            }
        }
    }
}
