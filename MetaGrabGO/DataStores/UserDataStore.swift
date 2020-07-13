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
    
    var isAutologinEnabled = true
    
    func onStart() {
        if let usernameData = KeyChain.load(key: "metagrab.username"), let passwordData = KeyChain.load(key: "metagrab.password"), let tokenaccessData = KeyChain.load(key: "metagrab.tokenaccess"), let tokenrefreshData = KeyChain.load(key: "metagrab.tokenrefresh"), let userId = KeyChain.load(key: "metagrab.userid"), let accessExpDateEpoch = KeyChain.load(key: "metagrab.accessExpDateEpoch"), let refreshExpDateEpoch = KeyChain.load(key: "metagrab.refreshExpDateEpoch") {
            self.username = String(data: usernameData, encoding: String.Encoding.utf8) as String?
            self.password = String(data: passwordData, encoding: String.Encoding.utf8) as String?
            self.token = Token(refresh: String(data: tokenrefreshData, encoding: String.Encoding.utf8)!, access: String(data: tokenaccessData, encoding: String.Encoding.utf8)!, userId: Int(String(data: userId, encoding: String.Encoding.utf8)!)!, refreshExpDateEpoch: Int(String(data: refreshExpDateEpoch, encoding: String.Encoding.utf8)!)!, accessExpDateEpoch: Int(String(data: accessExpDateEpoch, encoding: String.Encoding.utf8)!)!)
            self.user = User(id: self.token!.userId, username: self.username!)
        }
    }
    
    func autologin() {
        if self.isAutologinEnabled == true {
            acquireToken()
        }
    }
    
    func login(username: String, password: String) {
        self.username = username
        self.password = password
        
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        self.acquireToken(taskGroup: taskGroup)
        
        
        taskGroup.notify(queue: DispatchQueue.global()) {
            _ = KeyChain.save(key: "metagrab.username", data: username.data(using: String.Encoding.utf8)!)
            _ = KeyChain.save(key: "metagrab.password", data: password.data(using: String.Encoding.utf8)!)
            _ = KeyChain.save(key: "metagrab.tokenaccess", data: self.token!.access.data(using: String.Encoding.utf8)!)
            _ = KeyChain.save(key: "metagrab.tokenrefresh", data: self.token!.refresh.data(using: String.Encoding.utf8)!)
            _ = KeyChain.save(key: "metagrab.userid", data: String(self.token!.userId).data(using: String.Encoding.utf8)!)
            _ = KeyChain.save(key: "metagrab.accessExpDateEpoch", data: String(self.token!.accessExpDateEpoch).data(using: String.Encoding.utf8)!)
            _ = KeyChain.save(key: "metagrab.refreshExpDateEpoch", data: String(self.token!.refreshExpDateEpoch).data(using: String.Encoding.utf8)!)
            print("saved to keychain credentials")
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
//            if let httpResponse = response as? HTTPURLResponse {
//                httpResponse.statusCode
//            }
            
            if error != nil {
                print("auto login failed")
                self.isAutologinEnabled = false
                
                if taskGroup != nil {
                    taskGroup!.leave()
                }
                
                return
            }
            
            
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.token = load(jsonData: jsonString.data(using: .utf8)!)
                        self.isAuthenticated = true
                        if taskGroup != nil {
                            self.user = User(id: self.token!.userId, username: self.username!)
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
