//
//  GenreDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-24.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation

class PopularListDataStore: ObservableObject {
    @Published var genresIdArr: [Int]
    var genres: [Int: Genre]
    var nextPageStartIndex: Int
    
    init(access: String) {
        self.genresIdArr = []
        self.genres = [:]
        self.nextPageStartIndex = -1
        
        self.fetchGenresByPage(access: access)
    }
    
    func fetchGenresByPage(access: String, start: Int = 0, count: Int = 5, refresh: Bool = false) {
        let API = APIClient()
        let params = ["start": String(start), "count": String(count)]
        let url = API.generateURL(resource: Resource.genre, endPoint: EndPoint.getGenresByRange, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let genresPageResponse: GenresPageResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    var tempGenresIdArr: [Int] = []
                    
                    if genresPageResponse.hasNextPage == true {
                        self.nextPageStartIndex = start + count
                    } else {
                        self.nextPageStartIndex = -1
                    }
                    
                    for genre in genresPageResponse.genresArr {
                        if self.genres[genre.id] == nil {
                            tempGenresIdArr.append(genre.id)
                            self.genres[genre.id] = genre
                        }
                    }

                    DispatchQueue.main.async {
                        self.genresIdArr += tempGenresIdArr
                    }
                }
            }
        }.resume()
    }
}

class GenreDataStore: ObservableObject {
    @Published var gamesArr: [Int]
    @Published var isLoadingGames: Bool = false
    var genre: Genre
    var nextPageStartIndex: Int
    
    init(access: String, genre: Genre, globalGamesDataStore: GlobalGamesDataStore) {
        self.genre = genre
        self.gamesArr = []
        self.nextPageStartIndex = -1
        
        self.fetchGamesByGenrePage(access: access, globalGamesDataStore: globalGamesDataStore)
    }
    
    func fetchGamesByGenrePage(access: String, start: Int = 0, count: Int = 5, refresh: Bool = false, globalGamesDataStore: GlobalGamesDataStore) {
        let API = APIClient()
        
        self.isLoadingGames = true
        
        let params = ["genre_id": String(genre.id), "start": String(start), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesByGenreId, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let gamesPageResponse: GamesPageResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    var gamesIdArr: [Int] = []

                    if gamesPageResponse.hasNextPage == true {
                        self.nextPageStartIndex = start + count
                    } else {
                        self.nextPageStartIndex = -1
                    }
                    
                    for game in gamesPageResponse.gamesArr {
                        if globalGamesDataStore.games[game.id] == nil {
                            globalGamesDataStore.games[game.id] = game
                        }
                        gamesIdArr.append(game.id)
                    }
                    
                    DispatchQueue.main.async {
                        self.gamesArr += gamesIdArr
                        self.isLoadingGames = false
                    }
                }
            }
        }.resume()
    }
}
