//
//  LeaderBoardModels.swift
//  golf
//
//  Created by Jules Burt on 2018-05-30.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

enum LeaderBoard {
    
    enum presentLeaderBoard {
        struct Request {
        }
        struct Response {
            let leaderboard:[Entries], players:[Int:Players], title:String?
        }
        struct ViewModel {
            struct LeaderBoardEntry {
                let pos:String
                let playerName:String
                let tot:String
                let score:String
                let thru:String
            }
            let tournamentTitle:String
            let leaderBoard:[LeaderBoardEntry]
        }
    }
}
