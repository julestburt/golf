//
//  LeaderBoardRouter.swift
//  golf
//
//  Created by Jules Burt on 2018-05-30.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import UIKit

@objc protocol LeaderBoardRoutingLogic {
    func routeToScoreCard(segue: UIStoryboardSegue?)
}

protocol LeaderBoardDataPassing {
    var dataStore: LeaderBoardDataStore? { get }
}

class LeaderBoardRouter: NSObject, LeaderBoardRoutingLogic, LeaderBoardDataPassing {
    
    var dataStore:LeaderBoardDataStore?
    
    func routeToScoreCard(segue: UIStoryboardSegue?) {
        if let segue = segue {
            let destVC = segue.destination as! ScoreCardViewController
            var destDataStore = destVC.router!.dataStore!
            passDataToScoreCard(source: dataStore!, destination: &destDataStore)
        } else {
            let destVC = viewController?.storyboard?.instantiateViewController(withIdentifier: "ScoreCard") as! ScoreCardViewController
            var destDataStore = destVC.router!.dataStore!
            passDataToScoreCard(source: dataStore!, destination: &destDataStore)
            navigateToScoreCard(source: viewController!, destination: destVC)
        }
    }
    
    var viewController: LeaderBoardViewController?

    // MARK: Routing
    
    func navigateToScoreCard(source: LeaderBoardViewController, destination: ScoreCardViewController)
    {
        source.show(destination, sender: nil)
    }
    
    func passDataToScoreCard(source: LeaderBoardDataStore, destination: inout ScoreCardDataStore)
    {
        let selectedRow = (viewController?.table.indexPathForSelectedRow?.row)! - 1
        destination.selectedPlayer = source.leaderBoard?[selectedRow].player_id
    }
    
}
