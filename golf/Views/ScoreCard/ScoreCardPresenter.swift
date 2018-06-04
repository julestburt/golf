//
//  ScoreCardPresenter.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

protocol ScoreCardPresenterLogic {
    func presentScoreCard(_ response:ScoreCard.getPlayerScoreCard.response)
}


class ScoreCardPresenter : ScoreCardPresenterLogic {
    
    var viewController:ScoreCardVCLogic?
    
    func presentScoreCard(_ response:ScoreCard.getPlayerScoreCard.response) {
        let viewModel = ScoreCard.getPlayerScoreCard.viewModel(rounds: [:])
        viewController?.displayScoreCard(viewModel: viewModel)
    }
    
}
