/////////////////////////////////////////////////////////////////////////////////
//
//  LeaderBoard ViewController.swift
//  golf
//
//  Created by Jules Burt on 2018-03-11.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//
/////////////////////////////////////////////////////////////////////////////////
import UIKit

//------------------------------------------------------------------------------
// MARK: View Actions
//------------------------------------------------------------------------------

protocol ViewActions : class {
    func presentLeaderBoard(viewModel: LeaderBoard.presentLeaderBoard.ViewModel)
}

extension LeaderBoardVC: ViewActions {
    func presentLeaderBoard(viewModel: LeaderBoard.presentLeaderBoard.ViewModel) {
        title = viewModel.tournamentTitle
        displayLeaderBoard(viewModel.leaderBoard)
    }
}

//------------------------------------------------------------------------------
// MARK: Interactor Actions
//------------------------------------------------------------------------------

extension LeaderBoardVC {
    func getLeaderBoard() {
        if alternateRoute {
            interactor?.getCalculatedLeaderBoard()
        } else {
            interactor?.getLeaderBoard()
        }
        alternateRoute = alternateRoute ? false : true
    }
}

//------------------------------------------------------------------------------
// MARK: View Controller
//------------------------------------------------------------------------------

class LeaderBoardVC: UIViewController {

    ////////////////////////////////////////////////////////////////////////////////
    // MARK: View Control / LifeCycle
    ////////////////////////////////////////////////////////////////////////////////
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.showsVerticalScrollIndicator = false
        addRefreshControl()
        activity.startAnimating()
        getLeaderBoard()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }

    fileprivate func setUp() {
        let viewController = self
        let interactor = LeaderBoardInteractor()
        let presenter = LeaderBoardPresenter()
        let router = LeaderBoardRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.leaderBoardPresenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    var interactor:LeaderBoardBusinessLogic? = nil
    var router:(NSObjectProtocol & LeaderBoardRoutingLogic & LeaderBoardDataPassing)?
    var leaderboardData:[LeaderBoard.presentLeaderBoard.ViewModel.LeaderBoardEntry]? = nil
    var alternateRoute:Bool = true
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    //------------------------------------------------------------------------------
    // MARK: UITableView
    //------------------------------------------------------------------------------


    @IBOutlet weak var loadingScreen: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    @IBOutlet weak var table: UITableView!
    fileprivate func displayLeaderBoard(_ leaderBoard: [LeaderBoard.presentLeaderBoard.ViewModel.LeaderBoardEntry]) {
        leaderboardData = leaderBoard
        UIView.animate(withDuration: 0.25) {
            self.loadingScreen.alpha = 0
            self.activity.stopAnimating()
        }
        resetRefreshControl()
        table.reloadData()
    }

    //------------------------------------------------------------------------------
    // MARK: Refresh Control
    //------------------------------------------------------------------------------
    
    let refreshControl = UIRefreshControl()
    
    fileprivate func addRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        if #available(iOS 10.0, *) {
            table.refreshControl = refreshControl
        } else {
            table.addSubview(refreshControl)
        }
    }
    
    @objc func refreshPulled() {
        getLeaderBoard()
    }
    
    func resetRefreshControl() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}

//------------------------------------------------------------------------------
// MARK: UITableView DataSource / Delegate
//------------------------------------------------------------------------------

extension LeaderBoardVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboardData != nil ? leaderboardData!.count + 1 : 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return leaderboardData != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0, let cell = table.dequeueReusableCell(withIdentifier: "LeaderHeaderCell") {
            return cell
        }
        
        if let leaderCell = table.dequeueReusableCell(withIdentifier: "LeaderBoardCell") as? LeaderBoardCell,
            let entry = leaderboardData?[indexPath.row - 1] {
            leaderCell.entryDetails(pos: entry.pos, player: entry.playerName, tot: entry.tot, score: entry.score, thru:entry.thru)
            return leaderCell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        table.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.row != 0 else { return false }
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}



