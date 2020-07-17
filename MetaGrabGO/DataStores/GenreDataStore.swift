//
//  GenreDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-24.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import Combine

final class PopularListDataStore: ObservableObject {
    @Published private(set) var genresIdArr: [Int]
    
    private(set) var genresDataStore: [Int: GenreDataStore]
    private(set) var genres: [Int: Genre]
    private(set) var nextPageStartIndex: Int
    private var cancellableSet: Set<AnyCancellable> = []
    private let API = APIClient()
    
    init(globalGamesDataStore: GlobalGamesDataStore) {
        self.genresIdArr = []
        self.genres = [:]
        self.genresDataStore = [:]
        self.nextPageStartIndex = -1
        self.fetchGenresByPage(globalGamesDataStore: globalGamesDataStore)
    }
    
    private func fetchGenresByPage(start: Int = 0, count: Int = 5, refresh: Bool = false, globalGamesDataStore: GlobalGamesDataStore) {
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

final class GenreDataStore: ObservableObject {
    @Published private(set) var gamesArr: [Int]
    @Published var isLoadingGames: Bool = false
    private var genre: Genre
    private(set) var nextPageStartIndex: Int
    
    private let API = APIClient()
    private var cancellableSet: Set<AnyCancellable> = []
    
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
                        globalGamesDataStore.addGame(game: game)
                        gamesIdArr.append(game.id)
                    }
                    
                    self.gamesArr += gamesIdArr
                    self.isLoadingGames = false
                })
                .store(in: &self.cancellableSet)
        }
    }
}
