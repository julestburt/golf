//
//  GolfDataTests.swift
//  golfTests
//
//  Created by Jules Burt on 2018-03-22.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import golf

class GolfDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
        
    func testprepareLeaderBoardForView() {
        
        let stringJSON = "{\"participants\":[{\"holes\":[4,4,4,4,4,2,4,4,3,4,4,2],\"player_id\":1005},{\"holes\":[],\"player_id\":68787}],\"id\":1000,\"title\":\"Masters\",\"end_date\":\"2018-04-08\",\"course_id\":9000,\"start_date\":\"2018-04-05\"}".data(using: String.Encoding.utf8)
        let json = JSON(data:stringJSON!)
        let event = Event(json: json)
        XCTAssert((event.participants![1005])!.count == 12, "didn't find the right hole count")
        XCTAssert((event.participants![68787])!.count == 0, "didn't find the zero hole count")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

