//
//  LeaderBoardPresenter.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

struct LeaderBoardEntry {
    let pos:String
    let playerName:String
    let tot:String
    let score:String
    let thru:String
}

protocol LeaderBoardAction:class {
    func present(leaderboard:[LeaderBoardEntry])
}

class LeaderBoardPresenter: NSObject {
    
    var delegate:LeaderBoardAction? = nil
    
    init(delegate:LeaderBoardAction) {
        self.delegate = delegate
    }
    
    // this displays the 'pre-made' leaderboard received from the API
    func showLeaderFromAPI(_ leaderboard:[Entries]) {
        var leaderboardPresent:[LeaderBoardEntry] = []
        
        for eachEntry in leaderboard {
            
            if let pos = eachEntry.rank {
                let playerName = String(eachEntry.player_id)
                let tot = String(eachEntry.total)
                let score = String(eachEntry.score)
                let thru = String(eachEntry.thru)
                
                let presentEntry = LeaderBoardEntry(pos: pos, playerName: playerName, tot: tot, score: score, thru: thru)
                
                leaderboardPresent.append(presentEntry)
            } else {
                assert(true, "error - missing pos / rank in data")
            }
        }
        delegate?.present(leaderboard: leaderboardPresent)
    }
    
    // this displays the assembled leaderboard from various API endpoints
    func showLeaderFromAPIAggregate(_ leaderboard:[Entries], players:[Int:Players]) {
        var leaderboardPresent:[LeaderBoardEntry] = []
        
        
        var sortedLeader = leaderboard.sorted(by: { $0.score < $1.score })
        
        var lastPos:Int? = nil
        var lastWasEven:Bool? = nil
        var position = 1
        
        func nextEntryScoreSameThis(_ current:Int, score:Int) -> Bool {
            if !(sortedLeader.count > current + 1) {
                return false
            }
            let entry = sortedLeader[current+1]
            return entry.score == score ? true : false
        }
        
        for (presentCount, eachEntry) in sortedLeader.enumerated() {
            var pos:String = ""
            if nextEntryScoreSameThis(presentCount, score:eachEntry.score) {
                pos = pos + "T" + "\(position)"
                lastWasEven = true
            } else {
                if let lastEven = lastWasEven, lastEven {
                    pos = pos + "T" + "\(position)"
                    lastWasEven = false
                } else {
                    pos = "\(position)"
                }
                position += 1
            }
            
            var playerName = ""
            if let player = players[eachEntry.player_id] {
                playerName = player.firstName + " " + player.lastName
            } else {
                playerName = "missing player - name?"
            }

            let tot = String(eachEntry.total)
            let score = String(eachEntry.score) != "0" ? String(eachEntry.score) : "EVEN"
            
            // Ensure 'F' is shown for 18, '-' for zero
            var thru:String = ""
            switch String(eachEntry.thru) {
            case "18":
                thru = "F"
            case "0":
                thru = "-"
            default:
                thru = String(eachEntry.thru)
            }
            
            let presentEntry = LeaderBoardEntry(pos: pos, playerName: playerName, tot: tot, score: score, thru: thru)
            
            leaderboardPresent.append(presentEntry)
        }
        delegate?.present(leaderboard: leaderboardPresent)
    }

}
