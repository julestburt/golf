//
//  ViewController.swift
//  golf
//
//  Created by Jules Burt on 2018-03-11.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import UIKit
import SwiftyJSON

class LeaderboardVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var loadingScreen: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    var leaderboardData:[LeaderBoardEntry]? = nil
    
    var golf:Golf? = nil
    var presenter:LeaderBoardPresenter? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
        
        presenter = LeaderBoardPresenter(delegate: self)
        golf = Golf.data
        golf?.presenter = presenter
        
//        golf?.getLeaderBoard()  // getting the pre-build LeaderBoard
        
        golf?.getCalculatedLeaderBoard()    // getting the leaderboard from various endpoints
        activity.startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LeaderboardVC : LeaderBoardAction {
    func present(leaderboard: [LeaderBoardEntry]) {
        leaderboardData = leaderboard
        UIView.animate(withDuration: 0.25) {
            self.loadingScreen.alpha = 0
            self.activity.stopAnimating()
        }
        table.reloadData()
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
        
        // set chosen row / player ID
        // golf.?selectedPlayerRow()
        performSegue(withIdentifier: "showPlayerDetail", sender: nil)
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



