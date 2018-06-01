//
//  ScoreCardPresenter.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

protocol ScoreCardPresenterLogic {
    func showScoreCardFromGolf(_ scoredata:[String])
    func present(scorecard:[String])
}


class ScoreCardPresenter : ScoreCardPresenterLogic {
    
    var viewController:ScoreCardVC_Logic?
    
    func showScoreCardFromGolf(_ scoredata:[String]) {
        
    }
    
    func present(scorecard:[String]) {
        
    }

}
