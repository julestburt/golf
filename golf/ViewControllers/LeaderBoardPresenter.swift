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
protocol LeaderBoardPresentationLogic {
    func showLeaderFromAPIAggregate(_ leaderboard:[Entries], players:[Int:Players], title:String?)
    func prepareLeaderBoardForView(_ leaderboard:[Entries], players:[Int:Players], title:String?) -> leaderBoard.showLeaderBoard.ViewModel
}

class LeaderBoardPresenter: LeaderBoardPresentationLogic {
    
    var viewController: LeaderBoardVCDisplayLogic?
    
    // this displays the assembled leaderboard from various API endpoints
    func showLeaderFromAPIAggregate(_ leaderboard:[Entries], players:[Int:Players], title:String?) {
        let viewModel = prepareLeaderBoardForView(leaderboard, players:players, title:title)
        viewController?.present(viewModel: viewModel)
    }
    
    func prepareLeaderBoardForView(_ leaderboard:[Entries], players:[Int:Players], title:String? = nil) -> leaderBoard.showLeaderBoard.ViewModel {
        var leaderboardPresent:[LeaderBoardEntry] = []
        
        var lastPos:Int? = nil
        var lastWasEven:Bool? = nil
        var position = 1
        
        func nextEntryScoreSameThis(_ current:Int, score:Int) -> Bool {
            if !(leaderboard.count > current + 1) {
                return false
            }
            let entry = leaderboard[current+1]
            return entry.score == score ? true : false
        }
        
        for (presentCount, eachEntry) in leaderboard.enumerated() {
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
        let title = title != nil ? title! : NSLocalizedString("Golf Leaderboard", comment: "alternative title when none found")
        let viewModel = leaderBoard.showLeaderBoard.ViewModel(tournamentTitle: title, leaderBoard: leaderboardPresent)
        return viewModel

    }

}
