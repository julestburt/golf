//
//  Golf.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class Golf : NSObject {
    
    static let data = Golf()
    var leaderBoardPresenter:LeaderBoardPresenter?
    var scoreCardPresenter:ScoreCardPresenter?
    var endPoints:EndPoints? = EndPoints()
    
    override init() {
        super.init()
    }
    
    var leaderBoard:[Entries]? = nil
    var playerList:[Int:Players]? = [:]
    var event:Event? = nil
    var courseDetail:Course? = nil
    var parDetails:[Int:Int] = [:]
    
    var selectedPlayer:Int? = nil

    let chosenGame = 1000
    
    func setChosenPlayer(_ selection:Int) {
        selectedPlayer = selection
    }
    
    func getPlayerScoreCard() {
        // assume golf already has current data - so no new API
        if let selected_id = selectedPlayer, let scoreDetails = calculateScoreCard(chosen:selected_id) {
            self.scoreCardPresenter?.showScoreCardFromGolf(scoreDetails)
        } else {
            print("scores missing")
        }
    }
    
    func calculateScoreCard(chosen:Int) -> [String]? {
        var scores:[String]? = nil
        if let course = self.courseDetail, let event = event, let players = playerList {
        }        
        return scores
    }

    func getLeaderBoard() {
        guard !inProgressAlready else { return }
        inProgressAlready = true

        var endPointCount = 2
        
        endPoints?.getLeaderboard(eventID: chosenGame, completion: { json in
            let data = json["data"]
            if data.error?.code == nil && !data.isEmpty && data.count > 0 {
                self.leaderBoard = []
                for (_, eachEntryJSON) in data {
                    let entry = Entries(json: eachEntryJSON)
                    self.leaderBoard?.append(entry)
                }
                checkLeaderBoardReturns()
            }
        })
        
        endPoints?.getPlayers(completion: { json in
            let data = json["data"]
            if data.error?.code == nil && !data.isEmpty && data.count > 0 {
                self.playerList = [:]
                for (_, eachEntryJSON) in data {
                    let player = Players(json: eachEntryJSON)   //Entries(json: eachEntryJSON)
                    self.playerList?[player.ID] = player
                }
                checkLeaderBoardReturns()
            }
        })
        
        func checkLeaderBoardReturns() {
            endPointCount -= 1
            guard endPointCount == 0 else { return }
            inProgressAlready = false
            if let leader = self.leaderBoard, let players = self.playerList {
                self.leaderBoardPresenter?.showLeaderFromAPIAggregate(leader, players: players)
            } else {
                print("problem data missing")
            }
        }
    }
    
    var inProgressAlready:Bool = false
    
    func getCalculatedLeaderBoard () {
        
        guard !inProgressAlready else { return }
        inProgressAlready = true
        var endPointCount = 3

        
        endPoints?.getEvent(eventID: chosenGame, completion: { json in
            let data = json["data"]
            if data.error?.code == nil {
                self.event = Event(json: data)
                checkCalculatedReturns()
                
                // get course
                self.endPoints?.getCourse(courseID: self.event!.courseID, completion: { json in
                    let data = json["data"]
                    if data.error?.code == nil {
                        let course = Course(json: data)
                        self.courseDetail = course
                        checkCalculatedReturns()
                    }
                })
            }
        })
    
    
        endPoints?.getPlayers(completion: { json in
            let data = json["data"]
            if data.error?.code == nil && !data.isEmpty && data.count > 0 {
                self.playerList = [:]
                for (_, eachEntryJSON) in data {
                    let player = Players(json: eachEntryJSON)   //Entries(json: eachEntryJSON)
                    self.playerList?[player.ID] = player
                }
                checkCalculatedReturns()
            }
    
        })
    
        func checkCalculatedReturns() {
            endPointCount -= 1
            guard endPointCount == 0 else { return }
            inProgressAlready = false
            if let event = self.event, let players = self.playerList, let course = self.courseDetail {
                calculateLeaderBoard()
                if let leader = self.leaderBoard {
                    self.leaderBoardPresenter?.showLeaderFromAPIAggregate(leader, players: players)
                }
            } else {
                print("likely no leaderboard")
            }
        }

    }
    
    func calculateLeaderBoard() {
        var leader = [Entries]()
        if let players = event?.participants, let course = self.courseDetail {
            parDetails = [:]
            for (number, hole) in course.holes {
                parDetails[number] = hole.par
            }
            for (player_id, rounds) in players {
                
                var par = 0
                var total = 0
                var roundsTaken = 0
                for (round, eachRound) in rounds.enumerated() {
                    total += eachRound
                    roundsTaken += 1
                    par += (parDetails[round+1])!                    
                }
                let score = total - par
                let thru = roundsTaken
                let entry = Entries(score: score, player_id: player_id, thru: thru, total: total, rank: nil)
                leader.append(entry)
            }
            self.leaderBoard = leader
        }
    }
}


