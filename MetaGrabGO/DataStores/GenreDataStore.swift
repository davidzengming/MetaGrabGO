//
//  GenreDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-24.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import Combine

class PopularListDataStore: ObservableObject {
    @Published var genresIdArr: [Int]
    
    var genresDataStore: [Int: GenreDataStore]
    var genres: [Int: Genre]
    var nextPageStartIndex: Int
    var cancellableSet: Set<AnyCancellable> = []
    let API = APIClient()

    init(globalGamesDataStore: GlobalGamesDataStore) {
        self.genresIdArr = []
        self.genres = [:]
        self.genresDataStore = [:]
        self.nextPageStartIndex = -1
        
        self.fetchGenresByPage(globalGamesDataStore: globalGamesDataStore)
    }
    
    func fetchGenresByPage(start: Int = 0, count: Int = 5, refresh: Bool = false, globalGamesDataStore: GlobalGamesDataStore) {
        let params = ["start": String(start), "count": String(count)]
        let url = self.API.generateURL(resource: Resource.genre, endPoint: EndPoint.getGenresByRange, params: params)
        let request = self.API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GenresPageResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { [unowned self] genresPageResponse in
               if genresPageResponse.hasNextPage == true {
                self.nextPageStartIndex = start + count
                } else {
                    self.nextPageStartIndex = -1
                }
                
                var tempGenresIdArr: [Int] = []
                for genre in genresPageResponse.genresArr {
                    if self.genres[genre.id] == nil {
                        tempGenresIdArr.append(genre.id)
                        self.genres[genre.id] = genre
                        self.genresDataStore[genre.id] = GenreDataStore(genre: genre, globalGamesDataStore: globalGamesDataStore)
                    }
                }
                
                self.genresIdArr += tempGenresIdArr
            })
            .store(in: &self.cancellableSet)
        }
    }
}

class GenreDataStore: ObservableObject {
    @Published var gamesArr: [Int]
    @Published var isLoadingGames: Bool = false
    var genre: Genre
    var nextPageStartIndex: Int
    
    let API = APIClient()
    var cancellableSet: Set<AnyCancellable> = []
    
    init(genre: Genre, globalGamesDataStore: GlobalGamesDataStore) {
        self.genre = genre
        self.gamesArr = []
        self.nextPageStartIndex = -1

        self.fetchGamesByGenrePage(globalGamesDataStore: globalGamesDataStore)
    }
    
    func fetchGamesByGenrePage(start: Int = 0, count: Int = 5, refresh: Bool = false, globalGamesDataStore: GlobalGamesDataStore) {
        self.isLoadingGames = true
        
        let params = ["genre_id": String(genre.id), "start": String(start), "count": String(count)]
        let url = self.API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesByGenreId, params: params)
        let request = self.API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        let session = self.API.generateSession()
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            processingRequestsTaskGroup.enter()
            session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GamesPageResponse.self, decoder: self.API.getJSONDecoder())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    processingRequestsTaskGroup.leave()
                    break
                case .failure(let error):
                    print("error: ", error)
                    processingRequestsTaskGroup.leave()
                    break
                }
            }, receiveValue: { [unowned self] gamesPageResponse in
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
               
               self.gamesArr += gamesIdArr
               self.isLoadingGames = false
            })
            .store(in: &self.cancellableSet)
        }
    }
}
