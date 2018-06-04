//
//  LeaderBoardCell.swift
//  golf
//
//  Created by Jules Burt on 2018-06-03.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import UIKit

//------------------------------------------------------------------------------
// MARK: UITableView
//------------------------------------------------------------------------------

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

