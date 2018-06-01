//
//  ScoreCardModels.swift
//  golf
//
//  Created by Jules Burt on 2018-05-31.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

enum ScoreCard {
    
    enum getPlayerScoreCard {
        struct rowStrings {
            let title:String
            let holeNumber:[Int:String]
            let summaryColum:String
            let totalColumn:String
            let finalScore:String
        }
        struct halfRound {
            let hole:rowStrings
            let par:rowStrings
            let Score:rowStrings
        }
        struct viewModel {
            let rounds:[Int:halfRound]
        }
    }
}
