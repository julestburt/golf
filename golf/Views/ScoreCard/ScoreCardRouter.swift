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
    weak var viewController:ScoreCardViewController?
    
    func routeToLeaderBoard(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destinationVC = segue.destination as! LeaderBoardViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToLeaderBoard(source: dataStore!, destination: &destinationDS)
        } else {
            let destinationVC = viewController?.storyboard?.instantiateViewController(withIdentifier: "LeaderBoard") as! LeaderBoardViewController
            var destinationDS = destinationVC.router!.dataStore!
            passDataToLeaderBoard(source: dataStore!, destination: &destinationDS)
            navigateToLeaderBoard(source: viewController!, destination: destinationVC)
            
        }
    }
    
    func navigateToLeaderBoard(source: ScoreCardViewController, destination: LeaderBoardViewController) {
        source.show(destination, sender: nil)
    }

    func passDataToLeaderBoard(source: ScoreCardDataStore, destination: inout LeaderBoardDataStore) {
        print("here we pass...")
    }
}
