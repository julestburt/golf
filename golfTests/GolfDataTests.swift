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
    
    func testPlayers() {
        let player = Players(ID: 2002, firstName: "Joe", lastName: "Bloggs", countryCode: "NZ")
        XCTAssertEqual(player.ID, 2002)
        let jsonPlayerString = "{\"last_name\":\"Nicklaus\",\"country_code\":\"US\",\"id\":1000,\"first_name\":\"Jack\"}".data(using: String.Encoding.utf8)
        let json = JSON(data:jsonPlayerString!)
        let player2 = Players(json: json)
        XCTAssertEqual(player2.ID, 1000)
        XCTAssertEqual(player2.firstName, "Jack")
        XCTAssertEqual(player2.lastName, "Nicklaus")
        XCTAssertEqual(player2.countryCode, "US")
        let jsonNonPlayerString = "{\"last_name\":\"Nicklaus\",\"country_code\":\"US\",\"first_name\":\"Jack\"}".data(using: String.Encoding.utf8)
        let jsonNon = JSON(data:jsonNonPlayerString!)
        let player2Non = Players(json: jsonNon)
        XCTAssertEqual(player2Non.ID, -1)
    }
        
    func testEvent() {
        
        let stringJSON = "{\"participants\":[{\"holes\":[4,4,4,4,4,2,4,4,3,4,4,2],\"player_id\":1005},{\"holes\":[],\"player_id\":68787}],\"id\":1000,\"title\":\"Masters\",\"end_date\":\"2018-04-08\",\"course_id\":9000,\"start_date\":\"2018-04-05\"}".data(using: String.Encoding.utf8)
        let json = JSON(data:stringJSON!)
        let event = Event(json: json)
        XCTAssert((event.participants![1005])!.count == 12)
        XCTAssert((event.participants![68787])!.count == 0)
        
        // missing course_id
        let stringJSONnoID = "{\"participants\":[{\"holes\":[4,4,4,4,4,2,4,4,3,4,4,2],\"player_id\":1005},{\"holes\":[],\"player_id\":68787}],\"title\":\"Masters\",\"end_date\":\"2018-04-08\",\"course_id\":9000,\"start_date\":\"2018-04-05\"}".data(using: String.Encoding.utf8)
        let jsonNoID = JSON(data:stringJSONnoID!)
        let eventNoID = Event(json: jsonNoID)
        XCTAssert(eventNoID.id == -1)
    }
    
    func testEntries() {
        let stringJSONEntry1 = "{\"total\" : 63,\"score\" : -5,\"player_id\" : 1000,\"thru\" : 17,\"rank\" : \"1\"}".data(using: String.Encoding.utf8)
        let jsonEntry1 = JSON(data: stringJSONEntry1!)
        let entry1 = Entries(json: jsonEntry1)
        XCTAssert(entry1.player_id == 1000)
        XCTAssert(entry1.rank == "1")
        let stringJSONEntry2 = "{\"total\" : 63,\"score\" : -5,\"thru\" : 17,\"rank\" : \"1\"}".data(using: String.Encoding.utf8)
        let jsonEntry2 = JSON(data: stringJSONEntry2!)
        let entry2 = Entries(json: jsonEntry2)
        XCTAssert(entry2.player_id == -1)
        XCTAssert(entry2.rank == "")
        let entry3 = Entries(score: -2, player_id: 1001, thru: 17, total: 56, rank: nil)
        XCTAssertTrue(entry3.player_id == 1001)
    }
    
}

