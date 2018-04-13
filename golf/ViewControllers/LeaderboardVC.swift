//
//  ViewController.swift
//  golf
//
//  Created by Jules Burt on 2018-03-11.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol LeaderBoardVCDisplayLogic : class {
    func present(viewModel: leaderBoard.showLeaderBoard.ViewModel)
}

class LeaderboardVC: UIViewController, LeaderBoardVCDisplayLogic {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var loadingScreen: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    let refreshControl = UIRefreshControl()
    
    var interactor:golfLeaderBoardLogic? = nil
    var leaderboardData:[LeaderBoardEntry]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false

        let viewController = self
        let presenter = LeaderBoardPresenter()
        let golfInteractor = Golf.data
        interactor = golfInteractor
        golfInteractor.leaderBoardPresenter = presenter
        viewController.interactor = interactor
        presenter.viewController = viewController
        
        getAlternatedAPI()
        
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        if #available(iOS 10.0, *) {
            table.refreshControl = refreshControl
        } else {
            table.addSubview(refreshControl)
        }
        activity.startAnimating()
    }
    var alternate:Bool = true
    func getAlternatedAPI() {
        if alternate {
            interactor?.getCalculatedLeaderBoard()
        } else {
            interactor?.getLeaderBoard()
        }
        alternate = alternate ? false : true
    }
    
    @objc func refreshPulled() {
        getAlternatedAPI()
    }

    func present(viewModel: leaderBoard.showLeaderBoard.ViewModel) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        
        leaderboardData = viewModel.leaderBoard
        title = viewModel.tournamentTitle
        
        UIView.animate(withDuration: 0.25) {
            self.loadingScreen.alpha = 0
            self.activity.stopAnimating()
        }
        table.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

enum leaderBoard
{
    // MARK: Use cases
    
    enum showLeaderBoard
    {
        struct Request
        {
        }
        struct Response
        {
        }
        struct ViewModel
        {
            let tournamentTitle:String
            let leaderBoard:[LeaderBoardEntry]
        }
    }
}

extension LeaderboardVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardData != nil ? leaderboardData!.count + 1 : 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return leaderboardData != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = nil
        
        if indexPath.row == 0 {
            if let headerCell = table.dequeueReusableCell(withIdentifier: "LeaderHeaderCell") {
                cell = headerCell
            }
        } else if let leaderCell = table.dequeueReusableCell(withIdentifier: "LeaderBoardCell") as? LeaderBoardCell,
            let leaderEntry = leaderboardData?[indexPath.row - 1] {
            leaderCell.entryDetails(pos: leaderEntry.pos, player: leaderEntry.playerName, tot: leaderEntry.tot, score: leaderEntry.score, thru:leaderEntry.thru)
            cell = leaderCell
        }
        if cell == nil {
            cell = UITableViewCell()
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        
        let selection = indexPath.row-1
        interactor?.setChosenPlayer(selection)
        performSegue(withIdentifier: "showPlayerDetail", sender: nil)
        table.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.row != 0 else {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}

class LeaderBoardCell: UITableViewCell {

    @IBOutlet weak var pos: UILabel!
    @IBOutlet weak var player: UILabel!
    @IBOutlet weak var tot: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var thru: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pos.text = "-"
        player.text = "-"
        tot.text = "-"
        score.text = "-"
        thru.text = "-"
    }
    
    func entryDetails(pos:String,player:String,tot:String,score:String,thru:String) {
        self.pos.text = pos
        self.player.text = player
        self.tot.text = tot
        self.score.text = score
        self.thru.text = thru
    }
}



