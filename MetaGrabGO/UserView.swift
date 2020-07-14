//
//  UserView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @State var isRegisterPage = false
    
    var body: some View {
        VStack {
            if self.isRegisterPage == true {
                RegisterUserView(isRegisterPage: self.$isRegisterPage)
            } else {
                LoginUserView(isRegisterPage: self.$isRegisterPage)
            }
        }
    }
}

struct LoginUserView: View {
    @Binding var isRegisterPage: Bool
    @State private var name: String = ""
    @State private var password: String = ""
    @EnvironmentObject var userDataStore: UserDataStore
    
    private func submit() {
        userDataStore.acquireToken(username: name, password: password)
    }
    
    var body: some View {
        GeometryReader { a in
            VStack(alignment: .leading) {
                Text(verbatim: "USERNAME")
                    .bold()
                TextField("", text: self.$name)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(10)
                    .background(appWideAssets.colors["notQuiteBlack"]!)
                    .cornerRadius(5)
                    .frame(width: a.size.width * 0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .accentColor(Color.white)
                    .foregroundColor(Color.white)
                
                    .padding(.bottom, 10)
                
                Text(verbatim: "PASSWORD")
                .bold()
                SecureField("", text: self.$password)
                    .disableAutocorrection(true)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .padding(10)
                    .background(appWideAssets.colors["notQuiteBlack"]!)
                    .cornerRadius(5)
                    .frame(width: a.size.width * 0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .accentColor(Color.white)
                    .foregroundColor(Color.white)
                .padding(.bottom, 20)

                Button(action: self.submit) {
                    Text("Login")
                    .bold()
                        .frame(width: a.size.width * 0.6, height: a.size.height * 0.06)
                        .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                    .shadow(radius: 5)
                }
                .onAppear() {
                    if self.userDataStore.isAuthenticated == false && self.userDataStore.isAutologinEnabled == true {
                        self.userDataStore.autologin()
                    }
                }
                .padding(.bottom, 10)
                
                HStack(spacing: 0) {
                    Text("Need an account? ")
                    Button(action: {self.isRegisterPage.toggle()}) {
                        Text("Register")
                        .bold()
                            .foregroundColor(Color.white)
                    }
                }
            }
        }
        
//    .KeyboardAwarePadding()
        .foregroundColor(Color(.lightText))
    }
}

struct RegisterUserView : View {
    @Binding var isRegisterPage: Bool
    @State var name: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var email: String = ""
    @State var showDetail = false
    @EnvironmentObject var userDataStore: UserDataStore
    
    var body: some View {
        GeometryReader { a in
            VStack(alignment: .leading) {
                Text(verbatim: "EMAIL")
                .bold()
                TextField("", text: self.$email)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(10)
                    .background(appWideAssets.colors["notQuiteBlack"]!)
                    .cornerRadius(5)
                    .frame(width: a.size.width * 0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .accentColor(Color.white)
                    .foregroundColor(Color.white)
                .padding(.bottom, 10)
                
                Text(verbatim: "USERNAME")
                .bold()
                TextField("", text: self.$name)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .padding(10)
                    .background(appWideAssets.colors["notQuiteBlack"]!)
                    .cornerRadius(5)
                    .frame(width: a.size.width * 0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .accentColor(Color.white)
                    .foregroundColor(Color.white)
                .padding(.bottom, 10)
                
                Text(verbatim: "PASSWORD")
                .bold()
                SecureField("", text: self.$password)
                    .disableAutocorrection(true)
                    .textContentType(.password)
                    .autocapitalization(.none)
                    .padding(10)
                    .background(appWideAssets.colors["notQuiteBlack"]!)
                    .cornerRadius(5)
                    .frame(width: a.size.width * 0.6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .accentColor(Color.white)
                    .foregroundColor(Color.white)
                .padding(.bottom, 10)
                
                
                Button(action: self.submit) {
                    Text("Continue")
                    .bold()
                        .frame(width: a.size.width * 0.6, height: a.size.height * 0.06)
                        .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                    .shadow(radius: 5)
                }
                .padding(.bottom, 10)

                HStack(spacing: 0) {
                    Button(action: {self.isRegisterPage.toggle()}) {
                        Text("Already have an account?")
                        .bold()
                        .foregroundColor(Color.white)
                    }
                }
            }
            .foregroundColor(Color(.lightText))
        }
    }
    
    func submit() {
        userDataStore.register(username: name, password: password, email: email)
    }
}

//#if DEBUG
//struct RegisterUserView_Previews : PreviewProvider {
//    static var previews: some View {
//        RegisterUserView()
//    }
//}
//#endif
