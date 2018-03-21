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
        static let getLeader = "getLeader"
        static let getPlayers = "getPlayers"
        static let getEvent = "getEvent"
        static let getCourse = "getCourse"
    }

    typealias jsonCompletion = ((APIDataResult<NSData>)->())
    enum APIDataResult<T> {
        case Success(data:JSON)
        case Error((error:String, code:Int, message:String))
    }
    
    var completionReturns:[String:jsonCompletion] = [:]

    let returnLeaderBoard = "/api/1/events/{event_id}/leaderboard/"
    func getLeaderboard(eventID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let url = returnLeaderBoard.replacingOccurrences(of: "{event_id}", with: "\(eventID)")
        _ = apiService.request(tag: APITags.getLeader, url: url, delegate: self)
        completionReturns[APITags.getLeader]=completion
    }

    let returnPlayers = "/api/1/players/"
    func getPlayers(completion: @escaping (APIDataResult<NSData>)->()) {
        let url = returnPlayers
        let _ = apiService.request(tag: APITags.getPlayers, url: url, delegate: self)
        completionReturns[APITags.getPlayers]=completion
    }
    
    let returnEvent = "/api/1/events/{event_id}/"
    func getEvent(eventID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let url = returnEvent.replacingOccurrences(of: "{event_id}", with: "\(eventID)")
        let _ = apiService.request(tag: APITags.getEvent, url: url, delegate: self)
        completionReturns[APITags.getEvent]=completion
    }
    
    let returnCourse = "/api/1/courses/{course_id}/"
    func getCourse(courseID:Int, completion: @escaping (APIDataResult<NSData>)->()) {
        let url = returnCourse.replacingOccurrences(of: "{course_id}", with: "\(courseID)")
        let _ = apiService.request(tag: APITags.getCourse, url: url, delegate: self)
        completionReturns[APITags.getCourse]=completion
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
            case APITags.getLeader, APITags.getPlayers:
                if let array = processArrayJSON(data) {
                    completion(.Success(data:array))
                } else {
                    completion(.Error((error:"Couldn't process array from JSON", code:-1, message:tag)))
                }
            case APITags.getCourse, APITags.getEvent:
                completion(.Success(data:data))
            default:
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

