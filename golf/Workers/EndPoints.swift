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

    typealias jsonCompletion = ((JSON)->())?

    let returnLeaderBoard = "/api/1/events/{event_id}/leaderboard/"
    var leaderBoardCompletion:jsonCompletion = nil
    func getLeaderboard(eventID:Int, completion: jsonCompletion) {
        leaderBoardCompletion = completion
        let url = returnLeaderBoard.replacingOccurrences(of: "{event_id}", with: "\(eventID)")
        let _ = apiService.request(tag: APITags.getLeader, url: url, delegate: self)
    }

    let returnPlayers = "/api/1/players/"
    var playersCompletion:jsonCompletion = nil
    func getPlayers(completion: jsonCompletion) {
        playersCompletion = completion
        let url = returnPlayers
        let _ = apiService.request(tag: APITags.getPlayers, url: url, delegate: self)
    }
    
    let returnEvent = "/api/1/events/{event_id}/"
    var eventCompletion:jsonCompletion = nil
    func getEvent(eventID:Int, completion: jsonCompletion) {
        eventCompletion = completion
        let url = returnEvent.replacingOccurrences(of: "{event_id}", with: "\(eventID)")
        let _ = apiService.request(tag: APITags.getEvent, url: url, delegate: self)
}
    
    let returnCourse = "/api/1/courses/{course_id}/"
    var courseCompletion:jsonCompletion = nil
    func getCourse(courseID:Int, completion: jsonCompletion) {
        courseCompletion = completion
        let url = returnCourse.replacingOccurrences(of: "{course_id}", with: "\(courseID)")
        let _ = apiService.request(tag: APITags.getCourse, url: url, delegate: self)
    }
}

extension EndPoints: APIResponse {
    func didRecieve(tag: String, result: JSON) {
        switch tag {
        case APITags.getLeader:
            if let completion = leaderBoardCompletion {
                completion(result)
            }
        case APITags.getPlayers:
            if let completion = playersCompletion {
                completion(result)
            }
        case APITags.getCourse:
            if let completion = courseCompletion {
                completion(result)
            }
        case APITags.getEvent:
            if let completion = eventCompletion {
                completion(result)
            }
        default:
            break
        }
    }
    
    func didFail(tag: String, error: String, code: Int?) {
        switch tag {
        case APITags.getLeader, APITags.getPlayers, APITags.getEvent, APITags.getCourse:
            // display error msg / or process some retries
            print("error:\(error), code:\(code)")
        default:
            break
        }
    }
    
    
}

