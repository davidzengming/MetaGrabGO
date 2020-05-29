//
//  UserView.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import SwiftUI

struct UserView: View {
    @State var isShowRegister = false
    
    var body: some View {
        VStack {
            Button(action: toggleShowRegister) {
                Text("Switch to register/login")
            }
            .padding()
            
            if isShowRegister == true {
                RegisterUserView()
            } else {
                LoginUserView()
            }
        }
    }
    
    func toggleShowRegister() {
        self.isShowRegister.toggle()
    }
}

struct LoginUserView: View {
    @State private var name: String = ""
    @State private var password: String = ""
    @EnvironmentObject var userDataStore: UserDataStore
    
    private func submit() {
        userDataStore.login(username: name, password: password)
    }
    
    var body: some View {
        VStack {
            Text(verbatim: "USERNAME").font(.headline)
            TextField("Type in username", text: $name)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .multilineTextAlignment(.center)
            
            Text(verbatim: "PASSWORD").font(.headline)
            SecureField("Enter password", text: $password)
                .disableAutocorrection(true)
                .textContentType(.password)
                .autocapitalization(.none)
                .multilineTextAlignment(.center)
            
            Button(action: submit) {
                Text("Submit")
            }
            .onAppear() {
                self.userDataStore.onStart()
                if self.userDataStore.username != nil {
                    self.userDataStore.autologin()
                }
            }
        }
    }
}

struct RegisterUserView : View {
    @State var name: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var email: String = ""
    @State var showDetail = false
    @EnvironmentObject var userDataStore: UserDataStore
    
    var body: some View {
        VStack {
            Text(verbatim: "USERNAME").font(.headline)
            TextField("Type in username", text: $name)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            
            Text(verbatim: "PASSWORD").font(.headline)
            SecureField("Enter password", text: $password)
                .disableAutocorrection(true)
                .textContentType(.password)
                .autocapitalization(.none)
            
            Text(verbatim: "CONFIRM PASSWORD").font(.headline)
            SecureField("Confirm password", text: $confirmPassword)
                .disableAutocorrection(true)
                .textContentType(.password)
                .autocapitalization(.none)
            
            Text(verbatim: "EMAIL").font(.headline)
            TextField("Fill in email", text: $email)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            Button(action: submit) {
                Text("Submit")
            }
        }
    }
    
    func submit() {
        if password == confirmPassword {
            userDataStore.register(username: name, password: password, email: email)
        } else {
            print("Passwords do not match.")
        }
    }
}

//#if DEBUG
//struct RegisterUserView_Previews : PreviewProvider {
//    static var previews: some View {
//        RegisterUserView()
//    }
//}
//#endif
