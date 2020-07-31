//
//  AcknowledgementsView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-07-30.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct AcknowledgementsView: View {
    @State private var showAcknowledgements: Bool = true
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        // For navigation bar background color
        UINavigationBar.appearance().barTintColor = hexStringToUIColor(hex: "#2C2F33")
        //        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default) //makes status bar translucent
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        ZStack {
            appWideAssets.colors["notQuiteBlack"].edgesIgnoringSafeArea(.all)
            
            GeometryReader { a in
                List {
                    Spacer()
                    HStack {
                        Text("TWEMOJI")
                        .tracking(1)
                        .padding()
                    }
                    .frame(width: a.size.width, alignment: .leading)
                    .background(appWideAssets.colors["teal"]!)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    if self.showAcknowledgements == false {
                        Button(action: { self.showAcknowledgements = true }) {
                            Text("Show acknowledgements")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                        .padding(.vertical)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    
                    if self.showAcknowledgements == true {
                        VStack {
                            Text("Twemoji graphics is made by Twitter and other contributors, licensed under CC-BY 4.0: https://creativecommons.org/licenses/by/4.0/.")
                                .padding()
                        }
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))

                        HStack(spacing: 0) {
                            Spacer()
                            ForEach(appWideAssets.emojiArray, id: \.self) { emojiId in
                                Image(uiImage: appWideAssets.emojis[emojiId]!!)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding(.horizontal, 3)
                            }
                            Spacer()
                        }
                        .animation(.easeIn)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    Spacer()
                    
                    HStack {
                        Text("GAME METADATA")
                        .tracking(1)
                        .padding()
                    }
                    .frame(width: a.size.width, alignment: .leading)
                    .background(appWideAssets.colors["teal"]!)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    VStack {
                        Text("Game metadata including banners, screenshots, icons, and descriptions shown in this app are created by users and are in no way affliated with Metagrab. If a developer, publisher, or copyright holder feels that any metadata including banners, screenshots, icons, or descriptions on the platform is misrepresenting their product or are in violation of copyright or fairuse, please contact me through davidzengming@gmail.com and I will try to resolve it as quickly as possible.")
                            .padding()
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    
                }
            }
        }
        .navigationBarTitle(Text("Acknowledgements"))
        .navigationBarHidden(false)
    }
}
