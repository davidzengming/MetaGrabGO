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

final class ImageLoader: ObservableObject {
    @Published private(set) var downloadedImage: UIImage?
    
    private var cache: ImageCache?
    private var url: URL
    private var cancellable: AnyCancellable?
    var whereIsThisFrom: String
    private var imageHeight: CGFloat?
    
    init(url: String, cache: ImageCache?, whereIsThisFrom: String, loadManually: Bool = false) {
        self.url = URL(string: url)!
        self.cache = cache
        
        self.whereIsThisFrom = whereIsThisFrom
        
        if loadManually == false {
            self.load()
        }
    }
    
    deinit {
        cancelProcess()
    }
    
    func cancelProcess() {
        self.cancellable?.cancel()
        self.cancellable = nil
    }
    
    func load() {
        if cancellable != nil {    
            return
        }

        //
        if let image = cache?[self.url] {
            DispatchQueue.main.async {
                self.imageHeight = image.size.height
                self.downloadedImage = image
            }
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: self.url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveOutput: { [weak self] in self?.cache($0) })
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.cancelProcess()
                    break
                case .failure(let error):
                    print("failed")
                    self.cancelProcess()
                    print("received error: ", error)
                }
            }, receiveValue: {[unowned self] image in
                if image == nil {
                    return
                }
                
                self.imageHeight = image!.size.height
                self.downloadedImage = image
            })
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
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
