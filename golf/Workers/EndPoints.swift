//
//  EndPoints.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class EndPoints {
    var apiService = API.service
    
    struct APITags {
        struct endpoint { let tag:String, endpoint:String }
        static let getPlayers = endpoint(tag: "getPlayers", endpoint: "/api/1/players/")
        static let getEvent = endpoint(tag: "getEvent", endpoint: "/api/1/events/{eventID}/")
        static let getCourse = endpoint(tag: "getCourse", endpoint: "/api/1/courses/{courseID}/")
        static let getLeader = endpoint(tag:"getLeader", endpoint:"/api/1/events/{eventID}/leaderboard/")
    }

    typealias jsonCompletion = ((APIDataResult<NSData>)->())
    enum APIDataResult<T> {
        case Success(data:JSON)
        case Error((error:String, code:Int, message:String))
    }
    
    var completionReturns:[String:jsonCompletion] = [:]

    func getLeaderboard(eventID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let getLeader = APITags.getLeader
        let url = getLeader.endpoint.replacingOccurrences(of: "{eventID}", with: "\(eventID)")
        _ = apiService.request(tag: getLeader.tag, url: url, delegate: self)
        completionReturns[getLeader.tag]=completion
    }

    func getPlayers(completion: @escaping (APIDataResult<NSData>)->()) {
        let getPlayers = APITags.getPlayers
        let _ = apiService.request(tag: getPlayers.tag, url: getPlayers.endpoint, delegate: self)
        completionReturns[getPlayers.tag]=completion
    }
    
    func getEvent(eventID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let getEvent = APITags.getEvent
        let url = getEvent.endpoint.replacingOccurrences(of: "{eventID}", with: "\(eventID)")
        let _ = apiService.request(tag: getEvent.tag, url: url, delegate: self)
        completionReturns[getEvent.tag]=completion
    }
    
    func getCourse(courseID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let getCourse = APITags.getCourse
        let url = getCourse.endpoint.replacingOccurrences(of: "{courseID}", with: "\(courseID)")
        let _ = apiService.request(tag: getCourse.tag, url: url, delegate: self)
        completionReturns[getCourse.tag]=completion
    }
    
    func processArrayJSON (_ data:JSON) -> JSON? {
        if !data.isEmpty && data.count > 0 {
            return data
        }
        return nil
    }
    
}

extension EndPoints: APIResponse {
    func didRecieve(tag: String, result: JSON) {
        let data = result["data"]
        if data.error?.code == nil, let completion = completionReturns[tag] {
            switch tag {
            case APITags.getLeader.tag, APITags.getPlayers.tag:
                if let array = processArrayJSON(data) {
                    completion(.Success(data:array))
                } else {
                    completion(.Error((error:"Couldn't process array from JSON", code:-1, message:tag)))
                }
            case APITags.getCourse.tag, APITags.getEvent.tag:
                completion(.Success(data:data))
            default:
                assertionFailure("need to cover all cases")
                break
            }
            
            completionReturns[tag] = nil
        } else {
            assert(true, "Problem with extracting JSON or missing completion return. Both bad!")
        }
    }
    
    func didFail(tag: String, error: String, code: Int?) {
        if let completion = completionReturns[tag] {
            completion(.Error((error:error, code:code != nil ? code! : -1, message:tag)))
            completionReturns[tag] = nil
            print("API error:\(error), code:\(String(describing: code)), tag:\(tag)")
        }
    }
        
}

