    //
//  EndPoints.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class EndPoint {
    
    let api:APIService = API.service
    
    struct APITags {
        struct endpoint { let tag:String, endpoint:String }
        static let getPlayers = endpoint(tag: "getPlayers", endpoint: "/api/1/players/")
        static let getEvent = endpoint(tag: "getEvent", endpoint: "/api/1/events/{eventID}/")
        static let getCourse = endpoint(tag: "getCourse", endpoint: "/api/1/courses/{courseID}/")
        static let getLeader = endpoint(tag:"getLeader", endpoint:"/api/1/events/{eventID}/leaderboard/")
    }
    
    func getLeaderboard(eventID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let getLeader = APITags.getLeader
        let url = getLeader.endpoint.replacingOccurrences(of: "{eventID}", with: "\(eventID)")
        api.request(tag: getLeader.tag, url: url, expectJSONArray: true, completion:completion)
    }

    func getPlayers(completion: @escaping (APIDataResult<NSData>)->()) {
        let getPlayers = APITags.getPlayers
        api.request(tag: getPlayers.tag, url: getPlayers.endpoint, expectJSONArray: true, completion:completion)
    }
    
    func getEvent(eventID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let getEvent = APITags.getEvent
        let url = getEvent.endpoint.replacingOccurrences(of: "{eventID}", with: "\(eventID)")
        api.request(tag: getEvent.tag, url: url, expectJSONArray: false, completion:completion)
    }
    
    func getCourse(courseID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let getCourse = APITags.getCourse
        let url = getCourse.endpoint.replacingOccurrences(of: "{courseID}", with: "\(courseID)")
        api.request(tag: getCourse.tag, url: url, expectJSONArray: false, completion:completion)
    }
    
}


