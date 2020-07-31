//
//  PersonalInfoView.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-07-31.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import SwiftUI

struct PersonalInfoView: View {
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
                        Text("USERNAME")
                        .tracking(1)
                        .padding()
                    }
                    .frame(width: a.size.width, alignment: .leading)
                    .background(appWideAssets.colors["teal"]!)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    VStack {
                        Text(keychainService.getUserName())
                            .padding()
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    HStack {
                        Text("EMAIL")
                        .tracking(1)
                        .padding()
                    }
                    .frame(width: a.size.width, alignment: .leading)
                    .background(appWideAssets.colors["teal"]!)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    
                    VStack {
                        Text(keychainService.getEmail())
                            .padding()
                    }
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                }
            }
        }
        .navigationBarTitle(Text("Account Profile"))
        .navigationBarHidden(false)
    }
}
