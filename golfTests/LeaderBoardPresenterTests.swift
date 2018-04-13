//
//  LeaderBoardPresenterTests.swift
//  golfTests
//
//  Created by Jules Burt on 2018-03-21.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import XCTest
@testable import golf

class leaderBoardPresenterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShowLeaderFromAPIAggregate() {
        
        let entry1 = Entries(score: -3, player_id: 1001, thru: 12, total: 56, rank: nil)
        let entry2 = Entries(score: -2, player_id: 1002, thru: 18, total: 7, rank: nil)
        let entry3 = Entries(score: 0, player_id: 1003, thru: 12, total: 45, rank: nil)
        let entry4 = Entries(score: 0, player_id: 1004, thru: 0, total: 0, rank: nil)
        let leaderBoard = [entry1, entry2, entry3, entry4]
        
        let player1 = Players(ID: 1001, firstName: "Jules", lastName: "Burt", countryCode: "UK")
        let player2 = Players(ID: 1010, firstName: "Steve", lastName: "Jones", countryCode: "US")
        let player3 = Players(ID: 1003, firstName: "Bob", lastName: "Newton", countryCode: "CA")
        let player4 = Players(ID: 1004, firstName: "Sally", lastName: "Granger", countryCode: "CA")
        var players:[Int:Players] = [:]
        players[player1.ID] = player1
        players[player2.ID] = player2
        players[player3.ID] = player3
        players[player4.ID] = player4

        let leaderBoardPresenter = LeaderBoardPresenter()

        // I faked the view, to get the output of leaderBoardPresenter, but then I also changed code in presenter to help test that function specifically...see below
        
        class FakeVC : LeaderBoardVCDisplayLogic {
            var presentationOutput:leaderBoard.showLeaderBoard.ViewModel? = nil
            func present(viewModel: leaderBoard.showLeaderBoard.ViewModel) {
                presentationOutput = viewModel
            }
        }
        let fakeVC:FakeVC = FakeVC()
        leaderBoardPresenter.viewController = fakeVC
        leaderBoardPresenter.showLeaderFromAPIAggregate(leaderBoard, players: players, title:nil)
        var viewModel = (fakeVC.presentationOutput)!
        
        XCTAssertEqual(viewModel.leaderBoard[1].thru, "F")
        
        XCTAssertEqual(viewModel.leaderBoard[3].thru, "-")
        
        XCTAssertFalse(viewModel.leaderBoard[1].playerName == "Steve Jones")
        
        XCTAssertEqual(viewModel.leaderBoard[2].score, "EVEN")
        
        XCTAssertEqual(viewModel.leaderBoard[0].playerName, "Jules Burt")
        
        XCTAssertEqual(viewModel.tournamentTitle, "Golf Leaderboard")
        
        leaderBoardPresenter.showLeaderFromAPIAggregate(leaderBoard, players: players, title:"Test Title")
        viewModel = (fakeVC.presentationOutput)!
        XCTAssertEqual(viewModel.tournamentTitle, "Test Title")

   }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
