//
//  Golf.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

// Please note this Class doesn't support getting both Leaderboards simultaneously.

protocol golfLeaderBoardLogic {
    func getLeaderBoard()
    func getCalculatedLeaderBoard()
    func setChosenPlayer(_ selection:Int)
}

class Golf : golfLeaderBoardLogic {
    
    static let data = Golf()
    var leaderBoardPresenter:LeaderBoardPresenter?
    var scoreCardPresenter:ScoreCardPresenter?
    var endPoints:EndPoints? = EndPoints()
    
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
        
        // assume golf class already has current data - so no new API for now
        if let selected_id = selectedPlayer, let scoreDetails = calculateScoreCard(chosen:selected_id) {
            scoreCardPresenter?.showScoreCardFromGolf(scoreDetails)
        } else {
            print("scores missing")
        }
    }
    
    func calculateScoreCard(chosen:Int) -> [String]? {
        var scores:[String] = []
        if let course = self.courseDetail, let event = event, let players = playerList {
            for each in scores {
                scores.append("Scores")
            }
        }
        return scores
    }
    
    func getLeaderBoard() {
        guard !inProgressAlready else { return }
        inProgressAlready = true

        var endPointCount = 2
        
        endPoints?.getLeaderboard(eventID: chosenGame, completion: { result in
            switch result {
            case .Success(let data):
                    self.leaderBoard = []
                    for (_, eachEntryJSON) in data {
                        let entry = Entries(json: eachEntryJSON)
                        self.leaderBoard?.append(entry)
                    }
            case .Error(let error, let code, let message):
                break
            }
            checkLeaderBoardReturns()
        })
        endPoints?.getPlayers(completion: { result in
            switch result {
            case .Success(let data):
                    self.playerList = [:]
                    for (_, eachEntryJSON) in data {
                        let player = Players(json: eachEntryJSON)
                        self.playerList?[player.ID] = player
                    }
            case .Error(let error, let code, let message):
                break
            }
            checkLeaderBoardReturns()
        })
        
        func checkLeaderBoardReturns() {
            endPointCount -= 1
            guard endPointCount == 0 else { return }
            inProgressAlready = false
            if let leader = self.leaderBoard, let players = self.playerList {
                leaderBoardPresenter?.showLeaderFromAPIAggregate(leader, players: players)
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

        endPoints?.getEvent(eventID: chosenGame, completion: { result in
            switch result {
            case .Success(let data):
                self.event = Event(json: data)
                
                self.endPoints?.getCourse(courseID: self.event!.courseID, completion: { result in
                    switch result {
                    case .Success(let data):
                        let course = Course(json: data)
                        self.courseDetail = course
                    case .Error(let error, let code, message: let message):
                        break
                    }
                    checkCalculatedReturns()
                })
            case .Error(let error, let code, let message):
                break
            }
            checkCalculatedReturns()

        })
        
    
        endPoints?.getPlayers(completion: { result in
            switch result {
            case .Success(let data):
                    self.playerList = [:]
                    for (_, eachEntryJSON) in data {
                        let player = Players(json: eachEntryJSON)   //Entries(json: eachEntryJSON)
                        self.playerList?[player.ID] = player
                    }
            case .Error(let error, let code, let message):
                break
            }
            checkCalculatedReturns()
        })
    
        func checkCalculatedReturns() {
            endPointCount -= 1
            guard endPointCount == 0 else { return }
            inProgressAlready = false
            if let event = self.event, let players = self.playerList, let course = self.courseDetail {
                calculateLeaderBoard(event: event, players:players, course:course)
                if let leader = self.leaderBoard {
                    leaderBoardPresenter?.showLeaderFromAPIAggregate(leader, players: players)
                }
            } else {
                print("likely no leaderboard")
            }
        }

    }
    
    func calculateLeaderBoard(event:Event, players:[Int:Players], course:Course) {
        var leader = [Entries]()
        if let players = event.participants {
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
            // let's ensure the leaderboard is sorted
            let sortedLeader = leader.sorted(by: { $0.score < $1.score })
            self.leaderBoard = sortedLeader
        }
    }
}


