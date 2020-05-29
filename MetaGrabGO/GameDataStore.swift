//
//  GameDataStore.swift
//  MetaGrab
//
//  Created by David Zeng on 2019-08-17.
//  Copyright © 2019 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class GameDataStore: ObservableObject {
    // Game and Icon States
    @Published var games = [Int: Game]()
    
    // Games by timeline
    @Published var gamesByYear = [Int: [Int: [Int:Set<Int>]]]()
    @Published var sortedDaysListByMonthYear = [Int: [Int: [Int]]]()
    @Published var sortedGamesListByDayMonthYear = [Int: [Int: [Int: [Int]]]]()
    @Published var hasGameByYear = [Int: Bool]()
    
    // Genre
    @Published var genres = [Int: Genre]()
    @Published var genreGameArray = [Int: [Int]]()
    
    // Visit history
    @Published var myGameVisitHistory = [Int]()
    @Published var myGameVisitHistorySet = Set<Int>()
    
    // Follow
    @Published var followedGames = [Int]()
    @Published var isFollowed = [Int: Bool]()
    @Published var isBackToGamesView = true
    
    // initial fetch
    @Published var didFetchGames = false
    
    // loading state
    @Published var isLoadingFollowGames = true
    @Published var isLoadingRecentlyVisitedGames = true
    
    let API = APIClient()
    
    func fetchFollowGames(access: String, userDataStore: UserDataStore, start:Int = 0, count:Int = 10) {

        DispatchQueue.main.async {
            if self.games.count != 0 {
                return
            }
            
            if self.isLoadingFollowGames == false {
                self.isLoadingFollowGames = true
            }
        }
        
        let params = ["start": String(start), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getFollowGameByUserId, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let followGames: [Game] = load(jsonData: jsonString.data(using: .utf8)!)
                    var followedGamesTempArr = [Int]()
                    DispatchQueue.main.async {
                        for game in followGames {
                            self.isFollowed[game.id] = true
                            
                            if self.games[game.id] != game {
                                self.games[game.id] = game
                            }
                            
                            followedGamesTempArr.append(game.id)
                        }
                        
                        if self.followedGames != followedGamesTempArr {
                            self.followedGames = followedGamesTempArr
                        }
                        
                        self.isLoadingFollowGames = false
                    }
                }
            }
        }.resume()
    }
    
    func getGameHistory(access: String) {
        DispatchQueue.main.async {
            if self.isLoadingRecentlyVisitedGames == false {
                self.isLoadingRecentlyVisitedGames = true
            } else {
                return
            }
        }
        
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGameHistoryByUserId)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    let gameHistoryResponse: GameHistoryResponse = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    DispatchQueue.main.async {
                        var gameHistorySet = Set<Int>()
                        
                        for gameId in gameHistoryResponse.gameHistory {
                            gameHistorySet.insert(gameId)
                        }
                        
                        if self.myGameVisitHistorySet != gameHistorySet {
                            self.myGameVisitHistorySet = gameHistorySet
                        }
                        
                        if self.myGameVisitHistory != gameHistoryResponse.gameHistory {
                            self.myGameVisitHistory = gameHistoryResponse.gameHistory
                        }
                        
                        self.isLoadingRecentlyVisitedGames = false
                    }
                }
            }
        }.resume()
    }
    
    func fetchGenres(access: String, userDataStore: UserDataStore, taskGroup: DispatchGroup) {
        let url = API.generateURL(resource: Resource.genre, endPoint: EndPoint.empty)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    var tempGenres = [Genre]()
                    tempGenres = load(jsonData: jsonString.data(using: .utf8)!)
                    
                    DispatchQueue.main.async {
                        for genre in tempGenres {
                            self.genres[genre.id] = genre
                            self.genreGameArray[genre.id] = [Int]()
                        }
                        print("----- Done fetching genres----- ", self.genres, self.genreGameArray)
                        taskGroup.leave()
                    }
                }
            }
        }.resume()
    }
    
    func fetchAndSortGamesWithGenre(access: String, userDataStore: UserDataStore) {
        let taskGroup = DispatchGroup()
        taskGroup.enter()
        self.fetchGenres(access: access, userDataStore: userDataStore, taskGroup: taskGroup)
        taskGroup.enter()
        self.fetchAllGames(access: access, userDataStore: userDataStore, taskGroup: taskGroup)
        
        print("---- WAITING FOR GAMES AND GENRE ------")
        taskGroup.notify(queue: .global()) {
            print("----- NOTIFIED - LOADED GAMES AND GENRE -----")
            print(self.genreGameArray)
            var tempGenreGameArray = self.genreGameArray
            for (game_id, game) in self.games {
                let genreIndex = game.genre.id
                tempGenreGameArray[genreIndex]!.append(game_id)
            }
            
            DispatchQueue.main.async {
                self.genreGameArray = tempGenreGameArray
                self.didFetchGames = true
            }
        }
    }
    
    func fetchAllGames(access: String, userDataStore: UserDataStore, taskGroup: DispatchGroup, start:Int = 0, count:Int = 10) {
        let params = ["start": String(start), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getRecentGames, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        let session = API.generateSession(access: access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    
                    let tempGames: [Game] = load(jsonData: jsonString.data(using: .utf8)!)
                    let calendar = Calendar.current
                    
                    DispatchQueue.main.async {
                        for game in tempGames {
                            if self.isFollowed[game.id] == nil {
                                self.isFollowed[game.id] = false
                            }
                            
                            if self.games[game.id] == nil || self.games[game.id] != game {
                                self.games[game.id] = game
                            }
                            
                            var releaseYear = calendar.component(.year, from: game.releaseDate)
                            var releaseMonth = calendar.component(.month, from: game.releaseDate)
                            var releaseDay = calendar.component(.day, from: game.releaseDate)
                            
                            if game.nextExpansionReleaseDate != nil {
                                releaseYear = calendar.component(.year, from: game.nextExpansionReleaseDate!)
                                releaseMonth = calendar.component(.month, from: game.nextExpansionReleaseDate!)
                                releaseDay = calendar.component(.day, from: game.nextExpansionReleaseDate!)
                            }
                            
                            if self.gamesByYear[releaseYear] == nil {
                                self.gamesByYear[releaseYear] = [Int:[Int: Set<Int>]]()
                            }
                            
                            if self.gamesByYear[releaseYear]![releaseMonth] == nil {
                                self.gamesByYear[releaseYear]![releaseMonth] = [Int: Set<Int>]()
                            }
                            
                            if self.gamesByYear[releaseYear]![releaseMonth]![releaseDay] == nil {
                                self.gamesByYear[releaseYear]![releaseMonth]![releaseDay] = Set<Int>()
                            }
                            
                            if self.gamesByYear[releaseYear]![releaseMonth]![releaseDay]!.contains(game.id) {
                                continue
                            } else {
                                self.gamesByYear[releaseYear]![releaseMonth]![releaseDay]!.insert(game.id)
                            }
                        }
                        
                        for (year, _) in self.gamesByYear {
                            
                            if self.hasGameByYear[year] == nil || self.hasGameByYear[year]! == false {
                                self.hasGameByYear[year] = true
                            }
                            
                            for (month, _) in self.gamesByYear[year]! {
                                if self.sortedDaysListByMonthYear[year] == nil {
                                    self.sortedDaysListByMonthYear[year] = [:]
                                }
                                
                                self.sortedDaysListByMonthYear[year]![month] = Array(self.gamesByYear[year]![month]!.keys).sorted{$0 < $1}
                                
                                for (day, _) in self.gamesByYear[year]![month]! {
                                    
                                    if self.sortedGamesListByDayMonthYear[year] == nil {
                                        self.sortedGamesListByDayMonthYear[year] = [:]
                                    }
                                    
                                    if self.sortedGamesListByDayMonthYear[year]![month] == nil {
                                        self.sortedGamesListByDayMonthYear[year]![month] = [:]
                                    }
                                    
                                    self.sortedGamesListByDayMonthYear[year]![month]![day] = Array(self.gamesByYear[year]![month]![day]!).sorted()
                                }
                            }
                        }
                        
                        print("----- Done fetching games ----- ")
                        taskGroup.leave()
                    }
                }
            }
        }.resume()
    }
}
