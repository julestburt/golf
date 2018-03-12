//
//  ViewController.swift
//  golf
//
//  Created by Jules Burt on 2018-03-11.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import UIKit

class LeaderboardVC: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
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
        
        golf?.getLeaderBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension LeaderboardVC : LeaderBoardAction {
    func present(leaderboard: [LeaderBoardEntry]) {
        leaderboardData = leaderboard
        table.reloadData()
    }
}

extension LeaderboardVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardData != nil ? leaderboardData!.count : 0
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return leaderboardData != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = nil
        if let leaderCell = table.dequeueReusableCell(withIdentifier: "LeaderBoardCell") as? LeaderBoardCell,
            let leaderEntry = leaderboardData?[indexPath.row] {
            leaderCell.entryDetails(pos: leaderEntry.pos, player: leaderEntry.playerName, tot: leaderEntry.tot, score: leaderEntry.score, thru:leaderEntry.thru)
            cell = leaderCell
        }
        if cell == nil {
            cell = UITableViewCell()
        }
        return cell!
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

class Golf {
    
    static let data = Golf()
    var presenter:LeaderBoardPresenter?
    
    let chosenGame = 1000
    
    func getLeaderBoard() {
        // get results from somewhere
        leaderBoardReadyForDisplay()
    }
    
    var leaderBoard:[PlayerResults]? = nil
    
    func leaderBoardReadyForDisplay() {
        let player = PlayerResults()
        if let leader = leaderBoard {
            presenter?.showLeader(leader)
        }
    }
}

class PlayerResults {
    
    var score:Int
    
    init() {
        score = 100
    }
}

struct LeaderBoardEntry {
    let pos:String
    let playerName:String
    let tot:String
    let score:String
    let thru:String
}

protocol LeaderBoardAction:class {
    func present(leaderboard:[LeaderBoardEntry])
}

class LeaderBoardPresenter: NSObject {
    
    var delegate:LeaderBoardAction? = nil
    
    init(delegate:LeaderBoardAction) {
        self.delegate = delegate
    }
    
    func showLeader(_ leaderboard:[PlayerResults]) {
        var leaderboard:[LeaderBoardEntry] = []
        leaderboard.append(LeaderBoardEntry(pos: "1", playerName: "Jack Nicklaus", tot: "46", score: "-1", thru: "12"))
        leaderboard.append(LeaderBoardEntry(pos: "T2", playerName: "Seve Ballesteros", tot: "40", score: "EVEN", thru: "10"))
        leaderboard.append(LeaderBoardEntry(pos: "T2", playerName: "Nick Faldo", tot: "36", score: "EVEN", thru: "9"))
        leaderboard.append(LeaderBoardEntry(pos: "3", playerName: "Greg Norman", tot: "73", score: "+1", thru: "F"))
        leaderboard.append(LeaderBoardEntry(pos: "4", playerName: "Tom Kite", tot: "6", score: "+2", thru: "1"))
        leaderboard.append(LeaderBoardEntry(pos: "5", playerName: "Mike Weir", tot: "18", score: "+3", thru: "4"))
        delegate?.present(leaderboard: leaderboard)
    }
}
