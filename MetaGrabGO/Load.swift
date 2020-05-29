//
//  Load.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation

func load<T: Decodable>(jsonData: Data, as type: T.Type = T.self) -> T {
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormat)
        return try(decoder.decode(T.self, from: jsonData))
    } catch {
        fatalError("Couldn't parse JSON file as \(T.self):\n\(error)")
    }
}
