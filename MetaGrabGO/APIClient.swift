//
//  APIClient.swift
//  MetaGrabGO
//
//  Created by David Zeng on 2020-05-21.
//  Copyright © 2020 David Zeng. All rights reserved.
//

import Foundation
import Combine
import Cloudinary

enum Resource: String, CodingKey {
    case games = "games"
    case genre = "genre"
    case developers = "developers"
    case forums = "forums"
    case threads = "threads"
    case users = "users"
    case usersProfile = "users_profile"
    case groups = "group"
    case comments = "comments"
    case votes = "votes"
    case reports = "reports"
    case emojis = "emojis"
    case redis = "redis"
    case api = "api"
}

enum EndPoint: String, CodingKey {
    
    // forum stats
    case getForumStats = "get_forum_stats"
    
    // genre endpoints
    case getGenresByRange = "get_genres_by_range"
    
    // game endpoints
    case getGameHistoryByUserId = "get_game_history_by_user_id"
    case getRecentGames = "get_recent_games"
    case insertGameHistoryByUserId = "insert_game_history_by_user_id"
    
    case getGamesByGenreId = "get_games_by_genre_id"
    
    case getGamesBeforeEpochTime = "get_games_before_epoch_time"
    case getGamesAfterEpochTime = "get_games_after_epoch_time"
    case getGamesAtEpochTime = "get_games_at_epoch_time"
    
    // get threads
    case getThreadsByGameId = "get_threads_by_game_id"
    
    // post thread
    case postThreadByGameId = "post_thread_by_game_id"
    
    // post comment
    case postCommentByThreadId = "post_comment_by_thread_id"
    case postCommentByParentCommentId = "post_comment_by_parent_comment_id"
    
    // fetch comments
    case getCommentTreeByThreadId = "get_comment_tree_by_thread_id"
    
    case getCommentTreeByCommentId = "get_comment_tree_by_parent_comment"
    
    // follow games
    case getFollowGameByUserId = "get_followed_games_by_user_id"
    case followGameByGameId = "follow_game_by_game_id"
    case unfollowGameByGameId = "unfollow_game_by_game_id"
    
    // user
    case refreshToken = "token/refresh"
    case acquireToken = "token"
    
    // null
    case empty = ""
    
    // block and hidden
    case hideThreadByUserId = "hide_thread_by_user_id"
    case unhideThreadByUserId = "unhide_thread_by_user_id"
    case hideCommentByUserId = "hide_comment_by_user_id"
    case unhideCommentByUserId = "unhide_comment_by_user_id"
    
    // black list and hide
    case blockUser = "add_user_to_blacklist_by_user_id"
    case unblockUser = "remove_user_from_blacklist_by_user_id"
    case getBlacklist = "get_blacklisted_users_by_user_id"
    
    case getHiddenThreads = "get_hidden_threads_by_user_id"
    case getHiddenComments = "get_hidden_comments_by_user_id"
    
    // vote
    
    case upvoteByExistingVoteId = "upvote_by_vote_id"
    case downvoteByVoteId = "downvote_by_vote_id"
    
    case addNewUpvoteByThreadId = "add_new_upvote_by_thread_id"
    case switchUpvoteByThreadId = "downvote_to_upvote_by_thread_id"
    case addNewDownvoteByThreadId = "add_new_downvote_by_thread_id"
    case switchDownvoteByThreadId = "upvote_to_downvote_by_thread_id"
    
    case addEmojiByThreadId = "add_new_emoji_by_thread_id"
    case removeEmojiByThreadId = "remove_emoji_by_thread_id"
    case deleteVoteByVoteIdThread = "delete_vote_by_vote_id_thread"
    
    case addNewUpvoteByCommentId = "add_new_upvote_by_comment_id"
    case switchUpvoteByCommentId = "downvote_to_upvote_by_comment_id"
    case addNewDownvoteByCommentId = "add_new_downvote_by_comment_id"
    case switchDownvoteByCommentId = "upvote_to_downvote_by_comment_id"
    
    case deleteVoteByVoteIdComment = "delete_vote_by_vote_id_comment"
    
    // report
    case addReportByThreadId = "add_report_by_thread_id"
    case addReportByCommentId = "add_report_by_comment_id"
}

enum HttpMethod: String, CodingKey {
    case GET = "GET"
    case POST = "POST"
}

struct APIClient {
    private let cloudinary = CLDCloudinary(configuration: CLDConfiguration(cloudName: "dzengcdn", apiKey: "348513889264333", secure: true))
    
    //134.122.31.85
    //127.0.0.1
    private let baseUrl: URL? = URL(string: "http://134.122.31.85:8000/")
    
    func generateURL(resource: Resource, endPoint: EndPoint, detail: String? = nil, params: [String: String]? = nil) -> URL? {
        
        var detailStr = ""
        if detail != nil {
            detailStr = detail! + "/"
        }
        
        var paramStr = ""
        if params != nil {
            for (key, val) in params! {
                var suffix = ""
                if paramStr.count == 0 {
                    suffix = "?" + key + "=" + val
                } else {
                    suffix = "&" + key + "=" + val
                }
                paramStr += suffix
            }
        }
        
        var endpointStr = ""
        if endPoint != .empty {
            endpointStr = endPoint.rawValue + "/"
        }
        
        return URL(string: resource.rawValue + "/" + detailStr + endpointStr + paramStr, relativeTo: baseUrl!)
    }
    
    func generateRequest(url: URL, method: HttpMethod, json: [String: Any]? = nil, bodyData: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if method == .POST {
            if json != nil {
                let jsonData = try? JSONSerialization.data(withJSONObject: json!)
                request.httpBody = jsonData
            }
            
            if bodyData != nil {
                request.httpBody = bodyData!.data(using: .utf8)
            }
        }
        return request
    }
    
    func generateSession(access: String) -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let authString: String? = "Bearer \(access)"
        sessionConfig.httpAdditionalHeaders = ["Authorization": authString!]
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        return session
    }
    
    func getData(request: URLRequest, completion: @escaping(Data) -> Void, userDataStore: UserDataStore) {
        processingRequestsTaskGroup.enter()
        let session = self.generateSession(access: userDataStore.token!.access)
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completion(data)
            }
            
            processingRequestsTaskGroup.leave()
        }.resume()
    }
    
    func sessionHandler(request: URLRequest, userDataStore: UserDataStore, completion: @escaping(Data) -> Void) {
        let count = refreshingRequestTaskGroup.debugDescription.components(separatedBy: ",").filter({$0.contains("count")}).first?.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap{Int($0)}.first
        
        if count != 0 {
            refreshingRequestTaskGroup.notify(queue: .global()) {
                self.getData(request: request, completion: completion, userDataStore: userDataStore)
            }
        } else {
            let curDateEpoch = Date().secondsSince1970

            if curDateEpoch >= userDataStore.token!.expDateEpoch - 300 {
                refreshingRequestTaskGroup.enter()
                
                processingRequestsTaskGroup.notify(queue: .global()) {
                    let url = self.generateURL(resource: Resource.users, endPoint: EndPoint.empty)
                    let request = self.generateRequest(url: url!, method: .POST, bodyData: "refresh=\(userDataStore.token!.refresh)")
                    
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if let data = data {
                            if let jsonString = String(data: data, encoding: .utf8) {
                                let accessTokenResponse: AccessToken = load(jsonData: jsonString.data(using: .utf8)!)
                                
                                DispatchQueue.main.async {
                                    userDataStore.token!.access = accessTokenResponse.access
                                    refreshingRequestTaskGroup.leave()
                                }
                            }
                        }
                    }.resume()
                }
                
                refreshingRequestTaskGroup.notify(queue: .global()) {
                    self.getData(request: request, completion: completion, userDataStore: userDataStore)
                }
            } else {
                self.getData(request: request, completion: completion, userDataStore: userDataStore)
            }
        }
    }
}

let processingRequestsTaskGroup = DispatchGroup()
let refreshingRequestTaskGroup = DispatchGroup()
