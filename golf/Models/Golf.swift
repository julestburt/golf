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
    private var scoreCardPresenter:ScoreCardPresenter?
    var endPoints:EndPoints? = EndPoints()
    
    var leaderBoard:[Entries]? = nil
    var playerList:[Int:Players]? = [:]
    var event:Event? = nil
    var courseDetail:Course? = nil
    
    private var selectedPlayer:Int? = nil

    let chosenGame = 1000

    // TODO: SECOND SCREEN SCORE CARD NEEDS FINISHING
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
        if let course = self.courseDetail, let _ = event, let _ = playerList {
            for _ in scores {
                scores.append("Scores")
            }
        }
        return scores
    }
    
    // Get the complete leaderboard direct from the API
    func getLeaderBoard() {

        guard !inProgressAlready else { return }
        inProgressAlready = true
        Utils.lock(obj: endPointCount) {
            endPointCount = 2
        }

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
            Utils.lock(obj: endPointCount) {
                endPointCount -= 1
            }
            guard endPointCount == 0 else { return }
            inProgressAlready = false
            if let leader = self.leaderBoard, let players = self.playerList {
                leaderBoardPresenter?.showLeaderFromAPIAggregate(leader, players: players, title:nil)
            } else {
                print("problem data missing")
            }
        }
    }
    
    // Basic check for number of endpoints used
    private var inProgressAlready:Bool = false
    private var _endPointCount: Int = 2
    private var endPointCount: Int {
        get {
            return _endPointCount
        }
        set {
            _endPointCount = newValue
        }
    }
    
    internal func getCalculatedLeaderBoard () {
        guard !inProgressAlready else { return }
        inProgressAlready = true
        Utils.lock(obj: endPointCount) {
            endPointCount = 3
        }

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
            Utils.lock(obj: endPointCount) {
                endPointCount -= 1
            }
            guard endPointCount == 0 else { return }
            inProgressAlready = false
            if let event = self.event, let players = self.playerList, let course = self.courseDetail {
                calculateLeaderBoard(event: event, players:players, course:course)
                if let leader = self.leaderBoard {
                    leaderBoardPresenter?.showLeaderFromAPIAggregate(leader, players: players, title:courseDetail?.name)
                }
            } else {
                print("likely no leaderboard")
            }
        }
    }
    
    private func calculateLeaderBoard(event:Event, players:[Int:Players], course:Course) {
        var leader = [Entries]()
        
        func sortLeaderBoard(_ leader: [Entries]) -> [Entries] {
            return leader.sorted(by: { (entry1, entry2) -> Bool in
                if entry1.score == entry2.score {
                    if entry1.thru == entry2.thru {
                        if let lastname1 = players[entry1.player_id]?.lastName, let lastname2 = players[entry2.player_id]?.lastName {
                            // SORT LAST BY SURNAME
                            return lastname1 < lastname2
                        }
                    }
                    // SORT SECOND BY ROUNDS THRU
                    return entry1.thru > entry2.thru
                }
                // SORT FIRST BY SCORE
                return entry1.score < entry2.score
            })
        }

        // each participant is a player's array of scores
        if let playersScores = event.participants {
            for (player_id, rounds) in playersScores {
                var par = 0
                var total = 0
                var roundsTaken = 0
                for eachScore in rounds {
                    roundsTaken += 1
                    total += eachScore
                    if let roundPar = course.holes[roundsTaken] {
                        par += roundPar.par
                    } else {
                        assert(true, "cannot be missing a par!")
                    }
                }
                let score = total - par
                let thru = roundsTaken
                let entry = Entries(score: score, player_id: player_id, thru: thru, total: total, rank: nil)
                leader.append(entry)
            }
            self.leaderBoard = sortLeaderBoard(leader)
        }
    }
}


