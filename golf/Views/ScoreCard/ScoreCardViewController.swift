//
//  ScoreCardViewController.swift
//  golf
//
//  Created by Jules Burt on 2018-03-12.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ScoreCardDisplay {
    func showScoreCard(viewModel:ScoreCard.getPlayerScoreCard.viewModel)
}

class ScoreCardViewController: UIViewController, ScoreCardDisplay {
    var rounds:[Int:halfRound]? = nil

    var displayScoreCardCalled:Bool = false
    func showScoreCard(viewModel: ScoreCard.getPlayerScoreCard.viewModel) {
        rounds = viewModel.rounds
        scoreTable.reloadData()
        displayScoreCardCalled = true
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    override func viewDidLoad() {
        let back = UIBarButtonItem.init(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem = back
        scoreTable.delegate = self
        scoreTable.dataSource = self
        let request = ScoreCard.getPlayerScoreCard.request()
        interactor?.getPlayerScoreCard(request)
    }
    
    func setUp() {
        let viewController = self
        let interactor = ScoreCardInteractor()
        let presenter = ScoreCardPresenter()
        let router = ScoreCardRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.scoreCardPresenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    var interactor:ScoreCardBusinessLogic?
    var router: (NSObjectProtocol & ScoreCardRoutingLogic & ScoreCardDataPassing)?
    @IBOutlet weak var scoreTable: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    
}

extension ScoreCardViewController : UITableViewDelegate, UITableViewDataSource {
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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


