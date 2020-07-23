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

final class TimelineDataStore: ObservableObject {
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
    
    @Published private(set) var gamesArr: [Int]?
    private(set) var gamesCalendars: [Int: GameCalendarDataStore]
    
    // epoch times in seconds
    private(set) var startTime: Int
    private(set) var endTime: Int
    
    @Published private(set) var isLoadingPrev = false
    @Published private(set) var isLoadingAfter = false
    @Published private(set) var isLoadingFirst = false
    
    @Published private(set) var hasPrevPage = false
    @Published private(set) var hasNextPage = false
    
    private let API = APIClient()
    
    private var firstLoadProcess: AnyCancellable?
    private var prevLoadProcess: AnyCancellable?
    private var nextLoadProcess: AnyCancellable?
    
    init() {
        self.gamesCalendars = [:]
        let currDate = Date()
        self.startTime = currDate.secondsSince1970
        self.endTime = currDate.secondsSince1970
    }
    
    func cancelFirstLoadProcess() {
        self.firstLoadProcess?.cancel()
        self.firstLoadProcess = nil
    }
    
    func cancelPrevLoadProcess() {
        self.prevLoadProcess?.cancel()
        self.prevLoadProcess = nil
    }
    
    func cancelNextLoadProcess() {
        self.nextLoadProcess?.cancel()
        self.nextLoadProcess = nil
    }
    
    func fetchFirstLoadAtEpochTime(count: Int = 5, globalGamesDataStore: GlobalGamesDataStore) {
        if self.firstLoadProcess != nil {
            return
        }

        isLoadingFirst = true
        
        let params = ["time_point_in_epoch": String(self.startTime), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesAtEpochTime, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.firstLoadProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: GamesTimeLineResponseAtEpochTime.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelFirstLoadProcess()
                        self.isLoadingFirst = false
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] tempGamesTimelineResponse in
                    
                    self.hasPrevPage = tempGamesTimelineResponse.hasPrevPage
                    self.hasNextPage = tempGamesTimelineResponse.hasNextPage
                    
                    var addedTimelineArr: [Int] = []
                    var lastGameId: Int? = nil
                    if self.gamesArr != nil {
                        lastGameId = self.gamesArr!.last
                    }
                    
                    for i in (0..<tempGamesTimelineResponse.gameArr.count) {
                        let game = tempGamesTimelineResponse.gameArr[i]
                        globalGamesDataStore.addGame(game: game)
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
                    
                    self.gamesArr = addedTimelineArr
                })
        }
    }
    
    func fetchGamesByBeforeEpochTime(count: Int = 5, globalGamesDataStore: GlobalGamesDataStore) {
        if self.prevLoadProcess != nil || self.hasPrevPage == false {
            return
        }

        self.isLoadingPrev = true
        
        let params = ["time_point_in_epoch": String(self.startTime), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesBeforeEpochTime, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.prevLoadProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: GamesTimeLineResponseBeforeEpochTime.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelPrevLoadProcess()
                        self.isLoadingPrev = false
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] tempGamesTimelineResponse in
                    var addedTimelineArr: [Int] = []
                    var lastGameId = self.gamesArr!.first
                    
                    for i in (0..<tempGamesTimelineResponse.gameArr.count) {
                        let game = tempGamesTimelineResponse.gameArr[i]
                        globalGamesDataStore.addGame(game: game)
                        addedTimelineArr.append(game.id)
                        
                        let newGameCalendar = GameCalendarDataStore(epochTimeInSeconds: Int(tempGamesTimelineResponse.timeScores[i]))
                        
                        if lastGameId != nil {
                            let lastGameCalendar = self.gamesCalendars[lastGameId!]!
                            
                            if newGameCalendar.year == lastGameCalendar.year {
                                lastGameCalendar.isShowingYear = false
                                
                                if newGameCalendar.month == lastGameCalendar.month {
                                    lastGameCalendar.isShowingMonth = false
                                    newGameCalendar.isLastDayInMonth = false
                                    
                                    if newGameCalendar.day == lastGameCalendar.day {
                                        lastGameCalendar.isShowingDay = false
                                    }
                                }
                            }
                        }
                        
                        self.gamesCalendars[game.id] = newGameCalendar
                        lastGameId = tempGamesTimelineResponse.gameArr[i].id
                    }
                    
                    if tempGamesTimelineResponse.timeScores.count > 0 {
                        self.startTime = Int(tempGamesTimelineResponse.timeScores[tempGamesTimelineResponse.timeScores.count - 1])
                    }

                    self.gamesArr = addedTimelineArr.reversed() + self.gamesArr!
                    self.hasPrevPage = tempGamesTimelineResponse.hasPrevPage
                })
        }
    }
    
    func fetchGamesByAfterEpochTime(count: Int = 5, globalGamesDataStore: GlobalGamesDataStore) {
        if self.nextLoadProcess != nil || self.hasNextPage == false {
            return
        }
        
        self.isLoadingAfter = true
        
        let API = APIClient()
        let params = ["time_point_in_epoch": String(self.endTime), "count": String(count)]
        let url = API.generateURL(resource: Resource.games, endPoint: EndPoint.getGamesAfterEpochTime, params: params)
        let request = API.generateRequest(url: url!, method: .GET, json: nil)
        
        self.API.accessTokenRefreshHandler(request: request)
        
        refreshingRequestTaskGroup.notify(queue: .global()) {
            let session = self.API.generateSession()
            processingRequestsTaskGroup.enter()
            self.nextLoadProcess = session.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: GamesTimeLineResponseAfterEpochTime.self, decoder: self.API.getJSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.cancelNextLoadProcess()
                        self.isLoadingAfter = false
                        processingRequestsTaskGroup.leave()
                        break
                    case .failure(let error):
                        #if DEBUG
                        print("error: ", error)
                        #endif
                        processingRequestsTaskGroup.leave()
                        break
                    }
                }, receiveValue: { [unowned self] tempGamesTimelineResponse in
                    var addedTimelineArr: [Int] = []
                    
                    var lastGameId = self.gamesArr!.last
                    
                    for i in (0..<tempGamesTimelineResponse.gameArr.count) {
                        let game = tempGamesTimelineResponse.gameArr[i]
                        globalGamesDataStore.addGame(game: game)
                        addedTimelineArr.append(game.id)
                        
                        let newGameCalendar = GameCalendarDataStore(epochTimeInSeconds: Int(tempGamesTimelineResponse.timeScores[i]))
                        
                        if lastGameId != nil {
                            let lastGameCalendar = self.gamesCalendars[lastGameId!]!
                            
                            if newGameCalendar.year == lastGameCalendar.year {
                                newGameCalendar.isShowingYear = false
                                
                                if newGameCalendar.month == lastGameCalendar.month {
                                    newGameCalendar.isShowingMonth = false
                                    lastGameCalendar.isLastDayInMonth = false
                                    
                                    if newGameCalendar.day == lastGameCalendar.day {
                                        newGameCalendar.isShowingDay = false
                                    }
                                }
                            }
                        }
                        
                        self.gamesCalendars[game.id] = newGameCalendar
                        lastGameId = tempGamesTimelineResponse.gameArr[i].id
                    }
                    
                    if tempGamesTimelineResponse.timeScores.count > 0 {
                        self.endTime = Int(tempGamesTimelineResponse.timeScores[tempGamesTimelineResponse.timeScores.count - 1])
                    }
                    self.gamesArr = self.gamesArr! + addedTimelineArr
                    self.hasNextPage = tempGamesTimelineResponse.hasNextPage
                })
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
