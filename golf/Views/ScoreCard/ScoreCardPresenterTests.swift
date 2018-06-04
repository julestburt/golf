//
//  ScoreCardPresenterTests.swift
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

class ScoreCardPresenterTests: XCTestCase
{
  // MARK: Subject under test
  
  var sut: ScoreCardPresenter!
  
  // MARK: Test lifecycle
  
  override func setUp()
  {
    super.setUp()
    setupScoreCardPresenter()
  }
  
  override func tearDown()
  {
    super.tearDown()
  }
  
  // MARK: Test setup
  
  func setupScoreCardPresenter()
  {
    sut = ScoreCardPresenter()
  }
  
  // MARK: Test doubles
  
  class ScoreCardDisplayLogicSpy: ScoreCardVCLogic
  {
    var displayScoreCardCalled:Bool = false
    func displayScoreCard(viewModel: ScoreCard.getPlayerScoreCard.viewModel) {
        displayScoreCardCalled = true
    }
  }
  
  // MARK: Tests
  
  func testPresentSomething()
  {
    // Given
    let spy = ScoreCardDisplayLogicSpy()
    sut.viewController = spy
    let response = ScoreCard.getPlayerScoreCard.response(scoredata: [])
    
    // When
    sut.presentScoreCard(response)
    
    // Then
    XCTAssertTrue(spy.displayScoreCardCalled, "presentSomething(response:) should ask the view controller to display the result")
  }
}
