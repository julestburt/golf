//
//  ScoreCardVCTests.swift
//  golf
//
//  Created by Jules Burt on 2018-06-02.
//  Copyright (c) 2018 bethegame Inc.. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

@testable import golf
import XCTest

class ScoreCardViewControllerTests: XCTestCase {
  // MARK: Subject under test
  
  var sut: ScoreCardViewController!
  var window: UIWindow!
  
  // MARK: Test lifecycle
  
  override func setUp() {
    super.setUp()
    window = UIWindow()
    setupScoreCardVC()
  }
  
  override func tearDown() {
    window = nil
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupScoreCardVC() {
    let bundle = Bundle.main
    let storyboard = UIStoryboard(name: "Main", bundle: bundle)
    sut = storyboard.instantiateViewController(withIdentifier: "ScoreCard") as? ScoreCardViewController
  }
  
  func loadView() {
    window.addSubview(sut.view)
    RunLoop.current.run(until: Date())
  }
  
  // MARK: Test doubles
  
  class ScoreCardBusinessLogicSpy: ScoreCardBusinessLogic {
    var getPlayerScoreCardCalled:Bool = false
    func getPlayerScoreCard(_ request: ScoreCard.getPlayerScoreCard.request) {
        getPlayerScoreCardCalled = true
    }
  }
  
  // MARK: Tests
  
    func testShouldDoSomethingWhenViewIsLoaded() {
        // Given
        let spy = ScoreCardBusinessLogicSpy()
        sut.interactor = spy

        // When
        loadView()

        // Then
        XCTAssertTrue(spy.getPlayerScoreCardCalled, "viewDidLoad() should ask the interactor to do something")
    }
  
  func testDisplaySomething() {
    // Given
    let viewModel = ScoreCard.getPlayerScoreCard.viewModel(rounds: [:])
    
    // When
    loadView()
    sut.showScoreCard(viewModel: viewModel)
    
    // Then
    XCTAssertEqual(sut.displayScoreCardCalled, true, "displaySomething(viewModel:) should update the name text field")
  }
}
