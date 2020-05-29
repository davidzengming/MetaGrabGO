//
//  ImageLoader.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var downloadedImage: UIImage?
    
    private var cache: ImageCache?
    private var url: URL
    private var cancellable: AnyCancellable?
    
    private var whereIsThisFrom: String
    
    var imageHeight: CGFloat?
    
    init(url: String, cache: ImageCache?, whereIsThisFrom: String, loadManually: Bool = false) {
        self.url = URL(string: url)!
        self.cache = cache
        
        self.whereIsThisFrom = whereIsThisFrom
        
        if loadManually == false {
            self.load()
        }
    }
    
    func load(dispatchGroup: DispatchGroup? = nil) {
        print("loading", self.whereIsThisFrom)
        
        dispatchGroup?.enter()
        
        if let image = cache?[self.url] {
            DispatchQueue.main.async {
                self.imageHeight = image.size.height
                self.downloadedImage = image
                dispatchGroup?.leave()
            }
            
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: self.url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in self?.cache($0) })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                    case .finished:
                        dispatchGroup?.leave()
                        break
                    case .failure(let error):
                        print("received error: ", error)
                        dispatchGroup?.leave()
                        
                }
            }, receiveValue: { image in
                self.imageHeight = image!.size.height
                self.downloadedImage = image
        })
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
    
    deinit {
        cancellable?.cancel()
        print("image loader being deinit" + self.whereIsThisFrom)
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, UIImage>()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCache = TemporaryImageCache()
}

extension EnvironmentValues {
    var imageCache: ImageCache {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
