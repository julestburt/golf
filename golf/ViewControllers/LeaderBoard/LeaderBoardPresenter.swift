//
//  LeaderBoardPresenter.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

protocol LeaderBoardPresentationLogic {
    func showLeaderBoard(_ response:LeaderBoard.presentLeaderBoard.Response)
}

class LeaderBoardPresenter: LeaderBoardPresentationLogic {

    var viewController: ViewActions?

    func showLeaderBoard(_ response:LeaderBoard.presentLeaderBoard.Response) {
        let viewModel = createLeaderBoard(response)
        viewController?.presentLeaderBoard(viewModel: viewModel)
    }
    
    func createLeaderBoard(_ response:LeaderBoard.presentLeaderBoard.Response) -> LeaderBoard.presentLeaderBoard.ViewModel {
        var leaderboardPresent:[LeaderBoard.presentLeaderBoard.ViewModel.LeaderBoardEntry] = []
        
        let title = response.title != nil ? response.title! : NSLocalizedString("Golf Leaderboard", comment: "alternative title when none found")

        var lastPos:Int? = nil
        var lastWasEven:Bool? = nil
        var position = 1
        
        func nextEntryScoreSameThis(_ current:Int, score:Int) -> Bool {
            if !(response.leaderboard.count > current + 1) {
                return false
            }
            let entry = response.leaderboard[current+1]
            return entry.score == score ? true : false
        }

        for (presentCount, eachEntry) in response.leaderboard.enumerated() {
            
            // prepend 'T' if position equals another player
            let position:String = {
                var posString:String = ""
                if nextEntryScoreSameThis(presentCount, score:eachEntry.score) {
                    posString = posString + "T" + "\(position)"
                    lastWasEven = true
                } else {
                    if let lastEven = lastWasEven, lastEven {
                        posString = posString + "T" + "\(position)"
                        lastWasEven = false
                    } else {
                        posString = "\(position)"
                    }
                    position += 1
                }
                return posString
            }()
            
            // create Player Name to Display
            let playerName:String = {
                if let player = response.players[eachEntry.player_id] {
                    return player.firstName + " " + player.lastName
                } else {
                    return "missing player - name?"
                }
            }()
            
            // show running total
            let tot = String(eachEntry.total)
            
            // show 'EVEN' if score is "0"
            let score = eachEntry.score == 0 ? "EVEN" : String(eachEntry.score)
            
            var thru:String {
                // Ensure 'F' is shown for 18, '-' for zero
                switch String(eachEntry.thru) {
                case "18":
                    return "F"
                case "0":
                    return "-"
                default:
                    return String(eachEntry.thru)
                }
            }
            
            let presentEntry = LeaderBoard.presentLeaderBoard.ViewModel.LeaderBoardEntry(pos: position, playerName: playerName, tot: tot, score: score, thru: thru)
            
            leaderboardPresent.append(presentEntry)
        }
        return LeaderBoard.presentLeaderBoard.ViewModel(tournamentTitle: title, leaderBoard: leaderboardPresent)
    }
}
