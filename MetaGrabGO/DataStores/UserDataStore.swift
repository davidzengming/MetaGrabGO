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
import Cloudinary

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
    
    func getEmail() -> String {
        let email = KeyChain.load(key: "metagrab.email")!
        return String(data: email, encoding: String.Encoding.utf8)!
    }
}

final class MyUserImage {
    var profileImageUrl: String
    var profileImageWidth: String
    var profileImageHeight: String
    
    init(profileImageUrl: String, profileImageWidth: String, profileImageHeight: String) {
        self.profileImageUrl = profileImageUrl
        self.profileImageWidth = profileImageWidth
        self.profileImageHeight = profileImageHeight
    }
}

var myUserImage: MyUserImage?

final class UserDataStore: ObservableObject {
    
    var profileImageLoader: ImageLoader?
    var profileImageLoaderSub: AnyCancellable?
    
    @Published private(set) var isAuthenticated: Bool = false
    @Environment(\.imageCache) private var cache: ImageCache
    @Published private(set) var isLoadingPicture: Bool = false
    
    @Published var loginError: String? = nil
    
    private let API = APIClient()
    private(set) var isAutologinEnabled = true
    
    private var loginProcess: AnyCancellable?
    private var updateProfileImageProcess: AnyCancellable?
    
    deinit {
        cancelUpdateProfileImageProcess()
    }
    
    func logout() {
        self.isAutologinEnabled = false
        
        withAnimation(.easeIn) {
            self.isAuthenticated = false
        }
        
        self.profileImageLoader = nil
        self.cancelLoginProcess()
        self.cancelUpdateProfileImageProcess()
    }
    
    func autologin() {
        if self.isAutologinEnabled == true {
            if KeyChain.load(key: "metagrab.hasLoggedInBefore") == nil {
                return
            }
            login()
        }
    }
    
    func cancelLoginProcess() {
        self.loginProcess?.cancel()
        self.loginProcess = nil
    }
    
    func cancelUpdateProfileImageProcess() {
        self.updateProfileImageProcess?.cancel()
        self.updateProfileImageProcess = nil
    }
    
    enum HTTPError: LocalizedError {
        case statusCode
    }

    func login(taskGroup: DispatchGroup? = nil, username: String? = nil, password: String? = nil) {
        if loginProcess != nil {
            return
        }
        
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
        
        self.loginProcess = URLSession.shared.dataTaskPublisher(for: request)
            .mapError({ (error) -> Error in
                return error
            })
            .map(\.data)
            .decode(type: Token.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.cancelLoginProcess()
                    
                    break
                case .failure(let error):
                    self.cancelLoginProcess()
                    self.isAutologinEnabled = false
                    #if DEBUG
                    print("auto login failed", error)
                    #endif
                    
                    self.loginError = "Invalid credentials. Please check username and password."
                    break
                }
                taskGroup?.leave()
            }, receiveValue: { [unowned self] token in
                self.loginError = nil
                self.isAuthenticated = true
                _ = KeyChain.save(key: "metagrab.hasLoggedInBefore", data: "true".data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.username", data: loadedUsername.data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.password", data: loadedPassword.data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.tokenaccess", data: token.access.data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.tokenrefresh", data: token.refresh.data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.userid", data: String(token.userId).data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.accessExpDateEpoch", data: String(token.accessExpDateEpoch).data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.refreshExpDateEpoch", data: String(token.refreshExpDateEpoch).data(using: String.Encoding.utf8)!)
                _ = KeyChain.save(key: "metagrab.email", data: token.email.data(using: String.Encoding.utf8)!)
                
                myUserImage = MyUserImage(profileImageUrl: token.profileImageUrl, profileImageWidth: token.profileImageWidth, profileImageHeight: token.profileImageHeight)
                
                if token.profileImageUrl != "" {
                    self.profileImageLoader = ImageLoader(url: myUserImage!.profileImageUrl, cache: self.cache, whereIsThisFrom: "profile image loader", loadManually: true)
                    self.profileImageLoaderSub = self.profileImageLoader!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
                }
                
                #if DEBUG
                print("saved to keychain credentials")
                #endif
            })
    }
    
    func register(username: String, password: String, email: String) {
        let url = API.generateURL(resource: Resource.users, endPoint: EndPoint.empty)
        let request = API.generateRequest(url: url!, method: .POST, bodyData: "username=\(username)&password=\(password)&email=\(email)")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if String(data: data, encoding: .utf8) != nil {
                    DispatchQueue.main.async {
                        self.login(username: username, password: password)
                    }
                }
            }
        }.resume()
    }
    
    func uploadProfilePicture(data: Data) {
        if self.updateProfileImageProcess != nil {
            #if DEBUG
            print("Image uploading already in process")
            #endif
            return
        }
        
        
        self.isLoadingPicture = true
        let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: "dzengcdn", apiKey: "348513889264333", secure: true))
        let taskGroup = DispatchGroup()
        var imageUrl: String = ""
        var profileImageWidth: String = ""
        var profileImageHeight: String = ""

        taskGroup.enter()
        let preprocessChain = CLDImagePreprocessChain()
            .addStep(CLDPreprocessHelpers.limit(width: 300, height: 300))
            .addStep(CLDPreprocessHelpers.dimensionsValidator(minWidth: 100, maxWidth: 800, minHeight: 100, maxHeight: 800))
        _ = cloudinary.createUploader().upload(data: data, uploadPreset: "cyr1nlwn", preprocessChain: preprocessChain)
            .response({response, error in
                if error == nil {
                    imageUrl = response!.secureUrl!
                    profileImageWidth = String(response!.width!)
                    profileImageHeight = String(response!.height!)
                    taskGroup.leave()
                }
            })
        
        taskGroup.notify(queue: DispatchQueue.global()) {
            let params = ["user_id": String(keychainService.getUserId())]
            let json: [String: Any] = ["profile_image_url": imageUrl, "profile_image_width": profileImageWidth, "profile_image_height": profileImageHeight]
            
            let url = self.API.generateURL(resource: Resource.usersProfile, endPoint: EndPoint.uploadProfileImage, params: params)
            let request = self.API.generateRequest(url: url!, method: .POST, json: json)
            
            self.API.accessTokenRefreshHandler(request: request)
            
            refreshingRequestTaskGroup.notify(queue: .global()) {
                let session = self.API.generateSession()
                processingRequestsTaskGroup.enter()
                self.updateProfileImageProcess = session.dataTaskPublisher(for: request)
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            myUserImage = MyUserImage(profileImageUrl: imageUrl, profileImageWidth: profileImageWidth, profileImageHeight: profileImageHeight)
                            
                            self.profileImageLoader = ImageLoader(url: imageUrl, cache: self.cache, whereIsThisFrom: "profile image loader reupload", loadManually: false)
                            self.profileImageLoaderSub = self.profileImageLoader!.objectWillChange.receive(on: DispatchQueue.main).sink(receiveValue: {[weak self] _ in self?.objectWillChange.send() })
                            
                            self.isLoadingPicture = false
                            self.cancelUpdateProfileImageProcess()
                            processingRequestsTaskGroup.leave()
                            break
                        case .failure(let error):
                            self.cancelUpdateProfileImageProcess()
                            #if DEBUG
                            print("error: ", error)
                            #endif
                            processingRequestsTaskGroup.leave()
                            break
                        }
                    }, receiveValue: { _ in
                    })
            }
        }
    }
}
