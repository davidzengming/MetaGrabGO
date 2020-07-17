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

struct KeyChainService {
    
    func getUserName() -> String {
        let usernameData = KeyChain.load(key: "metagrab.username")!
        return String(data: usernameData, encoding: String.Encoding.utf8)!
    }
    
    func getPassword() -> String {
        let passwordData = KeyChain.load(key: "metagrab.password")!
        return String(data: passwordData, encoding: String.Encoding.utf8)!
    }
    
    func getAccessToken() -> String {
        let tokenAccessData = KeyChain.load(key: "metagrab.tokenaccess")!
        return String(data: tokenAccessData, encoding: String.Encoding.utf8)!
    }
    
    func getRefreshToken() -> String {
        let tokenRefreshData = KeyChain.load(key: "metagrab.tokenrefresh")!
        return String(data: tokenRefreshData, encoding: String.Encoding.utf8)!
    }
    
    func getUserId() -> Int {
        let userId = KeyChain.load(key: "metagrab.userid")!
        return Int(String(data: userId, encoding: String.Encoding.utf8)!)!
    }
    
    func getAccessExpDateEpoch() -> Int {
        let accessExpDateEpoch = KeyChain.load(key: "metagrab.accessExpDateEpoch")!
        return Int(String(data: accessExpDateEpoch, encoding: String.Encoding.utf8)!)!
    }
    
    func getRefreshExpDateEpoch() -> Int {
        let refreshExpDateEpoch = KeyChain.load(key: "metagrab.refreshExpDateEpoch")!
        return Int(String(data: refreshExpDateEpoch, encoding: String.Encoding.utf8)!)!
    }
}

final class UserDataStore: ObservableObject {
    
    @Published private(set) var isAuthenticated: Bool = false
    
    private let API = APIClient()
    private(set) var isAutologinEnabled = true
    
    func logout() {
        self.isAutologinEnabled = false
        self.isAuthenticated = false
    }
    
    func autologin() {
        if self.isAutologinEnabled == true {
            if KeyChain.load(key: "metagrab.hasLoggedInBefore") == nil {
                return
            }
//            acquireToken()
        }
    }
    
    func acquireToken(taskGroup: DispatchGroup? = nil, username: String? = nil, password: String? = nil) {
        let url = API.generateURL(resource: Resource.api, endPoint: EndPoint.acquireToken)
        
        var loadedUsername = ""
        if username == nil {
            loadedUsername = keychainService.getUserName()
        } else {
            loadedUsername = username!
        }
        
        var loadedPassword = ""
        if password == nil {
            loadedPassword = keychainService.getPassword()
        } else {
            loadedPassword = password!
        }
        
        let request = API.generateRequest(url: url!, method: .POST, json: nil, bodyData: "username=\(loadedUsername)&password=\(loadedPassword)")
        
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
                        let token: Token = load(jsonData: jsonString.data(using: .utf8)!)
                        self.isAuthenticated = true
                        
                        _ = KeyChain.save(key: "metagrab.hasLoggedInBefore", data: "true".data(using: String.Encoding.utf8)!)
                        _ = KeyChain.save(key: "metagrab.username", data: loadedUsername.data(using: String.Encoding.utf8)!)
                        _ = KeyChain.save(key: "metagrab.password", data: loadedPassword.data(using: String.Encoding.utf8)!)
                        _ = KeyChain.save(key: "metagrab.tokenaccess", data: token.access.data(using: String.Encoding.utf8)!)
                        _ = KeyChain.save(key: "metagrab.tokenrefresh", data: token.refresh.data(using: String.Encoding.utf8)!)
                        _ = KeyChain.save(key: "metagrab.userid", data: String(token.userId).data(using: String.Encoding.utf8)!)
                        _ = KeyChain.save(key: "metagrab.accessExpDateEpoch", data: String(token.accessExpDateEpoch).data(using: String.Encoding.utf8)!)
                        _ = KeyChain.save(key: "metagrab.refreshExpDateEpoch", data: String(token.refreshExpDateEpoch).data(using: String.Encoding.utf8)!)
                        print("saved to keychain credentials")
                        taskGroup?.leave()
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
                        self.acquireToken(username: username, password: password)
                    }
                }
            }
        }.resume()
    }
}
