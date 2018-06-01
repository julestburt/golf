//
//  ScoreCardInteractor.swift
//  golf
//
//  Created by Jules Burt on 2018-05-30.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

protocol ScoreCardBusinessLogic {
    func getPlayerScoreCard(_ playerID:Int)
}

protocol ScoreCardDataStore {
    var selectedPlayer:Int? { get set }
    var playerList:[Int:Players]? {get set}
}

class ScoreCardInteractor: ScoreCardBusinessLogic, ScoreCardDataStore {
    
    var scoreCardPresenter:ScoreCardPresenterLogic?
    
    var selectedPlayer:Int? = nil
    var playerList:[Int:Players]?

    func getPlayerScoreCard(_ playerID:Int) {
        // assume golf class already has current data - so no new API for now
        if let selected_id = selectedPlayer, let scoreDetails = calculateScoreCard(chosen:selected_id) {
            scoreCardPresenter?.showScoreCardFromGolf(scoreDetails)
        } else {
            print("scores missing")
        }
    }
    func calculateScoreCard(chosen:Int) -> [String]? {
        var scores:[String] = []
//        if let course = self.courseDetail, let _ = event, let _ = playerList {
//            for _ in scores {
//                scores.append("Scores")
//            }
//        }
        return scores
    }

}
