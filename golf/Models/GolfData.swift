//
//  GolfData.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Players {
    let ID: Int
    let firstName: String
    let lastName:String
    var countryCode:String
    
    private init (ID: Int,firstName: String, lastName:String, countryCode:String) {
        self.ID = ID
        self.firstName = firstName
        self.lastName = lastName
        self.countryCode = countryCode
    }
    
    convenience init?(json:JSON) {
        guard let ID = json["id"].int,
            let firstName = json["first_name"].string,
            let lastName = json["last_name"].string,
            let countryCode = json["country_code"].string else {
                return nil }
        self.init(ID: ID, firstName: firstName, lastName: lastName, countryCode: countryCode)
    }
    
}

class Holes {
    let number:Int
    let length:Int
    let par:Int
    
    private init(number:Int, length:Int, par:Int) {
        self.number = number
        self.length = length
        self.par = par
    }
    
    convenience init?(json:JSON) {
        guard let number = json["number"].int,
            let length = json["length"].int,
            let par = json["par"].int else { return nil }
        self.init(number: number, length: length, par: par)
    }
}

class Course {
    let id:Int
    let name:String
    let holes:[Int:Holes]
    
    private init(id:Int, name:String, holes:[Int:Holes]) {
        self.id = id
        self.name = name
        self.holes = holes
    }
    
    convenience init?(json:JSON) {
        guard let id = json["id"].int,
            let name = json["name"].string else { return nil }
        let holes = json["holes"]
        guard holes.error?.errorCode == nil && !holes.isEmpty && holes.count > 0 else { return nil }
        let holeCourse = holes.compactMap { Holes(json: $0.1) }.reduce(into: [Int:Holes]()) { (result, hole) in
            result[hole.number] = hole
        }
        self.init(id: id, name: name, holes: holeCourse)
    }
}

class Event {
    let id:Int
    let courseID:Int
    var participants:[Int:[Int]]?
    
    init(id:Int, courseID:Int, participants:[Int:[Int]]) {
        self.id = id
        self.courseID = courseID
        self.participants = participants
    }
    
    convenience init(json:JSON) {
        if let eventID = json["id"].int,
            let courseID = json["course_id"].int {
            
            let data = json["participants"]
            var particpants:[Int:[Int]] = [:]
            if data.error?.errorCode == nil && !data.isEmpty && data.count > 0 {
                
                for (_, eachParticipant) in data {
                    if let player_id = eachParticipant["player_id"].int {
                        let holes = eachParticipant["holes"]
                        var rounds:[Int] = []
                        if holes.error?.errorCode == nil, !holes.isEmpty && holes.count > 0 {
                            for (_, each) in holes {
                                let round = each.int
                                if round != nil {
                                    rounds.append(round!)
                                }
                            }
                        }
                        particpants[player_id] = rounds
                    }
                }
            }
            self.init(id: eventID, courseID: courseID, participants: particpants)
        } else {
            self.init(id: -1, courseID: 0, participants: [:])
        }
    }
}

class Entries {
    let score: Int
    let player_id: Int
    let thru:Int
    let total:Int
    let rank:String?
    
    init(score:Int, player_id:Int, thru:Int, total:Int, rank:String?) {
        self.score = score
        self.player_id = player_id
        self.thru = thru
        self.total = total
        self.rank = rank
    }
    
    convenience init?(json:JSON) {
        guard let score = json["score"].int,
            let player_id = json["player_id"].int,
            let thru = json["thru"].int,
            let total = json["total"].int,
            let rank = json["rank"].string else { return nil }
        self.init(score: score, player_id: player_id, thru: thru, total: total, rank: rank)
    }
}
