//
//  ScoreCardRouter.swift
//  golf
//
//  Created by Jules Burt on 2018-05-31.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import UIKit

protocol ScoreCardRoutingLogic {
    func routeToLeaderBoard(segue:UIStoryboardSegue?)
}

protocol ScoreCardDataPassing {
    var dataStore: ScoreCardDataStore? { get set }
}

class ScoreCardRouter: NSObject, ScoreCardRoutingLogic, ScoreCardDataPassing {
    var dataStore:ScoreCardDataStore?
    weak var viewController:ScoreCardVC?
    
    func routeToLeaderBoard(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! LeaderBoardVC
            var destinationDS = destinationVC.router!.dataStore!
//            passDataToLeaderBoard(source: dataStore!, destination: &destinationDS)
        } else {
            let destinationVC = viewController?.storyboard?.instantiateViewController(withIdentifier: "LeaderBoardVC") as! LeaderBoardVC
            var destinationDS = destinationVC.router!.dataStore!
//            passDataToLeaderBoard(source: dataStore!, destination: &destinationDS)
            navigateToLeaderBoard(source: viewController!, destination: destinationVC)
            
        }
    }
    
    func navigateToLeaderBoard(source: ScoreCardVC, destination: LeaderBoardVC) {
        source.show(destination, sender: nil)
    }

//    func passDataToLeaderBoard(source: ScoreCardDataStore, destination: LeaderBoardDataStore) {
//        print("here we pass...")
//    }
}
