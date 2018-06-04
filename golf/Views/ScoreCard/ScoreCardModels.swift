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
        struct request {
        }
        struct response {
            let scoredata:[String]
        }
        struct viewModel {
            let rounds:[Int:halfRound]
        }
    }
}

struct halfRound {
    let hole:rowStrings
    let par:rowStrings
    let Score:rowStrings
}

struct rowStrings {
    let title:String
    let holeNumber:[Int:String]
    let summaryColum:String
    let totalColumn:String
    let finalScore:String
}
