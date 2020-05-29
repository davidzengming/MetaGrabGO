//
//  UserDataStore.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class UserDataStore: ObservableObject {
    @Published var username: String? = nil
    @Published var isAuthenticated: Bool = false
    
    var user: User? = nil
    
    var password: String? = nil
    var token: Token? = nil
    
    let API = APIClient()
    
    func onStart() {
        if let usernameData = KeyChain.load(key: "metagrabusername"), let passwordData = KeyChain.load(key: "metagrabpassword"), let tokenaccessData = KeyChain.load(key: "metagrabtokenaccess"), let tokenrefreshData = KeyChain.load(key: "metagrabtokenrefresh"), let userId = KeyChain.load(key: "userid") {
            self.username = String(data: usernameData, encoding: String.Encoding.utf8) as String?
            self.password = String(data: passwordData, encoding: String.Encoding.utf8) as String?
            self.token = Token(refresh: String(data: tokenrefreshData, encoding: String.Encoding.utf8)!, access: String(data: tokenaccessData, encoding: String.Encoding.utf8)!, userId: Int(String(data: userId, encoding: String.Encoding.utf8)!)!)
            self.user = User(id: self.token!.userId, username: self.username!)
        }
    }
    
    func autologin() {
        acquireToken()
    }
    
    func login(username: String, password: String) {
        self.username = username
        self.password = password
        
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        self.acquireToken(taskGroup: taskGroup)
        
        taskGroup.notify(queue: DispatchQueue.global()) {
            print("saved to keychain credentials")
            let status1 = KeyChain.save(key: "metagrabusername", data: username.data(using: String.Encoding.utf8)!)
            let status2 = KeyChain.save(key: "metagrabpassword", data: password.data(using: String.Encoding.utf8)!)
            let status3 = KeyChain.save(key: "metagrabtokenaccess", data: self.token!.access.data(using: String.Encoding.utf8)!)
            let status4 = KeyChain.save(key: "metagrabtokenrefresh", data: self.token!.refresh.data(using: String.Encoding.utf8)!)
            let status5 = KeyChain.save(key: "userid", data: String(self.token!.userId).data(using: String.Encoding.utf8)!)
        }
    }
    
    func refreshToken(queryGroup: DispatchGroup) {
        
        let url = API.generateURL(resource: Resource.api, endPoint: EndPoint.refreshToken)
        let request = API.generateRequest(url: url!, method: .POST, json: nil)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.token!.access = load(jsonData: jsonString.data(using: .utf8)!)
                        queryGroup.leave()
                    }
                }
            }
        }.resume()
    }
    
    func acquireToken(taskGroup: DispatchGroup? = nil) {
        let url = API.generateURL(resource: Resource.api, endPoint: EndPoint.acquireToken)
        let request = API.generateRequest(url: url!, method: .POST, json: nil, bodyData: "username=\(self.username!)&password=\(self.password!)")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.token = load(jsonData: jsonString.data(using: .utf8)!)
                        self.isAuthenticated = true
                        if taskGroup != nil {
                            taskGroup!.leave()
                        }
                    }
                }
            }
        }.resume()
    }
    
    func register(username: String, password: String, email: String) {
        let url = API.generateURL(resource: Resource.users, endPoint: EndPoint.empty)
        let request = API.generateRequest(url: url!, method: .POST, bodyData: "username=\(username)&password=\(password)&email=\(email)")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if String(data: data, encoding: .utf8) != nil {
                    DispatchQueue.main.async {
                        //let data = String(bytes: data, encoding: String.Encoding.utf8)
                        self.username = username
                        self.password = password
                        self.acquireToken()
                    }
                }
            }
        }.resume()
    }
}
