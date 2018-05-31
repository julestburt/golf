//
//  ScoreCardVC.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import UIKit

enum scoreCard {
    enum getPlayerScoreCard {
        struct rowStrings {
            let title:String
            let holeNumber:[Int:String]
            let summaryColum:String
            let totalColumn:String
            let finalScore:String
        }
        struct halfRound {
            let hole:rowStrings
            let par:rowStrings
            let Score:rowStrings
        }
        struct viewModel {
            let rounds:[Int:halfRound]
        }
        
    }
}

protocol ScoreCardVC_Logic {
    func displayScoreCard(show:scoreCard.getPlayerScoreCard.viewModel)
}

class ScoreCardVC: UIViewController, ScoreCardVC_Logic {
    func displayScoreCard(show: scoreCard.getPlayerScoreCard.viewModel) {
        scoreTable.reloadData()
    }
    

//    let golf = Golf.data

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scoreTable: UITableView!
    
    override func viewDidLoad() {
        let back = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = back
        scoreTable.delegate = self
        scoreTable.dataSource = self
    }
    
}

extension ScoreCardVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCardRowCell") as? ScoreCardRowCell {
            cell.hole.text = "Test"
            for eachNumber in 1...9 {
                cell.numbers[eachNumber]?.text = "\(21 + eachNumber)"
            }
            cell.front9.text = "check 9"
            cell.total.text = "tootel"
            cell.score.text = "999"
            return cell
        }
        return UITableViewCell()
    }
}

class ScoreCardRowCell : UITableViewCell {
    
    @IBOutlet weak var hole: UILabel!
    
    @IBOutlet weak var front9: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var score: UILabel!
    var numbers:[Int:UILabel] = [:]

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        for eachView in contentView.subviews {
            if let label = eachView as? UILabel, let title = label.text,
                let isHoleNumber = Int(title) {
                // found a UILabel w/ number text
                numbers[isHoleNumber - 1] = label
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


