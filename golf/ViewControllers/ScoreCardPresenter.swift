//
//  ScoreCardPresenter.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation

protocol ScoreCardAction:class {
    func present(scorecard:[String])
}


class ScoreCardPresenter: NSObject {
    
    var delegate:ScoreCardAction? = nil
    
    init(delegate:ScoreCardAction) {
        self.delegate = delegate
    }

    func showScoreCardFromGolf(_ scoredata:[String]) {
        
    }
}
