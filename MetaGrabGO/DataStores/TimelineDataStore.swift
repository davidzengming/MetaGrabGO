//
//  TimelineDataStore.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-06-26.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class TimelineDataStore: ObservableObject {
    let monthDict = [
        1: "January",
        2: "February",
        3: "March",
        4: "April",
        5: "May",
        6: "June",
        7: "July",
        8: "August",
        9: "September",
        10: "October",
        11: "November",
        12: "December",
    ]
    
    @Published var gamesArr: [Int]
    var gamesCalendars: [Int: GameCalendarDataStore]
    
    // epoch times in seconds
    var startTime: Int
    var endTime: Int
    
    @Published var isLoadingPrev = false
    @Published var isLoadingAfter = false
    
    var fetchFirstLoad = false
    
    @Published var hasPrevPage = true
    @Published var hasNextPage = true
    
    init() {
        self.gamesArr = []
        self.gamesCalendars = [:]
        let currDate = Date()
        self.startTime = currDate.secondsSince1970
        self.endTime = currDate.secondsSince1970
    }
    
    func fetchFirstLoadAtEpochTime(count: Int = 10, globalGamesDataStore: GlobalGamesDataStore, userDataStore: UserDataStore) {
        let API = APIClient()
        let params = ["time_point_in_epoch": String(self.startTime), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesAtEpochTime, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let tempGamesTimelineResponse: GamesTimeLineResponse = load(jsonData: jsonString.data(using: .utf8)!)
                
                var addedTimelineArr: [Int] = []
                
                var lastGameId: Int? = nil
                if self.gamesArr.count > 0 {
                    lastGameId = self.gamesArr[self.gamesArr.count - 1]
                }
                
                for i in (0..<tempGamesTimelineResponse.gameArr.count) {
                    let game = tempGamesTimelineResponse.gameArr[i]
                    globalGamesDataStore.games[game.id] = game
                    addedTimelineArr.append(game.id)
                    
                    
                    let newGameCalendar = GameCalendarDataStore(epochTimeInSeconds: Int(tempGamesTimelineResponse.timeScores[i]))
                    
                    if lastGameId != nil {
                        let lastGameCalendar = self.gamesCalendars[lastGameId!]!
                        
                        if newGameCalendar.year == lastGameCalendar.year {
                            newGameCalendar.isShowingYear = false
                        }
                        
                        if newGameCalendar.month == lastGameCalendar.month {
                            newGameCalendar.isShowingMonth = false
                            lastGameCalendar.isLastDayInMonth = false
                        }
                        
                        if newGameCalendar.day == lastGameCalendar.day {
                            newGameCalendar.isShowingDay = false
                        }
                    }
                    
                    self.gamesCalendars[game.id] = newGameCalendar
                    lastGameId = tempGamesTimelineResponse.gameArr[i].id
                }
                
                if tempGamesTimelineResponse.timeScores.count > 0 {
                    self.startTime = Int(tempGamesTimelineResponse.timeScores[0])
                    self.endTime = Int(tempGamesTimelineResponse.timeScores[tempGamesTimelineResponse.timeScores.count - 1])
                }
                
                DispatchQueue.main.async {
                    self.gamesArr = addedTimelineArr
                }
            }
        }
    }
    
    func fetchGamesByBeforeEpochTime(count: Int = 10, globalGamesDataStore: GlobalGamesDataStore, userDataStore: UserDataStore) {
        self.isLoadingPrev = true
        
        let API = APIClient()
        let params = ["time_point_in_epoch": String(self.startTime), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesBeforeEpochTime, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let tempGamesTimelineResponse: GamesTimeLineResponse = load(jsonData: jsonString.data(using: .utf8)!)
                
                var addedTimelineArr: [Int] = []
                
                var lastGameId: Int? = nil
                if self.gamesArr.count > 0 {
                    lastGameId = self.gamesArr[0]
                } else {
                    self.hasPrevPage = false
                    self.isLoadingPrev = false
                    return
                }
                
                for i in (0..<tempGamesTimelineResponse.gameArr.count).reversed() {
                    let game = tempGamesTimelineResponse.gameArr[i]
                    globalGamesDataStore.games[game.id] = game
                    addedTimelineArr.append(game.id)
                    
                    let newGameCalendar = GameCalendarDataStore(epochTimeInSeconds: Int(tempGamesTimelineResponse.timeScores[i]))
                    
                    if lastGameId != nil {
                        let lastGameCalendar = self.gamesCalendars[lastGameId!]!
                        
                        if newGameCalendar.year == lastGameCalendar.year {
                            lastGameCalendar.isShowingYear = false
                        }
                        
                        if newGameCalendar.month == lastGameCalendar.month {
                            lastGameCalendar.isShowingMonth = false
                            newGameCalendar.isLastDayInMonth = false
                        }
                        
                        if newGameCalendar.day == lastGameCalendar.day {
                            lastGameCalendar.isShowingDay = false
                        }
                    }
                    
                    self.gamesCalendars[game.id] = newGameCalendar
                    lastGameId = tempGamesTimelineResponse.gameArr[i].id
                }
                
                if tempGamesTimelineResponse.timeScores.count > 0 {
                    self.startTime = Int(tempGamesTimelineResponse.timeScores[0])
                }
                DispatchQueue.main.async {
                    self.gamesArr = addedTimelineArr.reversed() + self.gamesArr
                    self.isLoadingPrev = false
                }
            }
        }
    }
    
    func fetchGamesByAfterEpochTime(count: Int = 10, globalGamesDataStore: GlobalGamesDataStore, userDataStore: UserDataStore) {
        self.isLoadingAfter = true
        
        let API = APIClient()
        let params = ["time_point_in_epoch": String(self.startTime), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesAfterEpochTime, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        API.sessionHandler(request: request, userDataStore: userDataStore) { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                let tempGamesTimelineResponse: GamesTimeLineResponse = load(jsonData: jsonString.data(using: .utf8)!)
                
                var addedTimelineArr: [Int] = []
                
                var lastGameId: Int? = nil
                if self.gamesArr.count > 0 {
                    lastGameId = self.gamesArr[self.gamesArr.count - 1]
                } else {
                    self.hasNextPage = false
                    self.isLoadingAfter = false
                    return
                }
                
                for i in (0..<tempGamesTimelineResponse.gameArr.count) {
                    let game = tempGamesTimelineResponse.gameArr[i]
                    globalGamesDataStore.games[game.id] = game
                    addedTimelineArr.append(game.id)
                    
                    
                    let newGameCalendar = GameCalendarDataStore(epochTimeInSeconds: Int(tempGamesTimelineResponse.timeScores[i]))
                    
                    if lastGameId != nil {
                        let lastGameCalendar = self.gamesCalendars[lastGameId!]!
                        
                        if newGameCalendar.year == lastGameCalendar.year {
                            newGameCalendar.isShowingYear = false
                        }
                        
                        if newGameCalendar.month == lastGameCalendar.month {
                            newGameCalendar.isShowingMonth = false
                            lastGameCalendar.isLastDayInMonth = false
                        }
                        
                        if newGameCalendar.day == lastGameCalendar.day {
                            newGameCalendar.isShowingDay = false
                        }
                    }
                    
                    self.gamesCalendars[game.id] = newGameCalendar
                    lastGameId = tempGamesTimelineResponse.gameArr[i].id
                }
                
                if tempGamesTimelineResponse.timeScores.count > 0 {
                    self.endTime = Int(tempGamesTimelineResponse.timeScores[tempGamesTimelineResponse.timeScores.count - 1])
                }
                DispatchQueue.main.async {
                    self.gamesArr = self.gamesArr + addedTimelineArr
                    self.isLoadingAfter = false
                }
            }
        }
    }
}

class GameCalendarDataStore: ObservableObject {
    @Published var isShowingYear: Bool = true
    @Published var isShowingMonth: Bool = true
    @Published var isShowingDay: Bool = true
    
    @Published var isLastDayInMonth: Bool = true
    
    var year: Int
    var month: Int
    var day: Int
    
    init(epochTimeInSeconds: Int) {
        let date = Date(seconds: epochTimeInSeconds)
        let calendar = Calendar.current
        
        self.year = calendar.component(.year, from: date)
        self.month = calendar.component(.month, from: date)
        self.day = calendar.component(.day, from: date)
    }
}

extension Date {
    var secondsSince1970: Int {
        return Int(self.timeIntervalSince1970.rounded())
        //RESOLVED CRASH HERE
    }
    
    init(seconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
}