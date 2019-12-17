//
//  RetryTests RetryTests.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 22/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import XCTest
import Then

class RetryTests: XCTestCase {
    
    var tryCount = 0
    
    func testRetryNumberWhenKeepsFailing() {
        let e = expectation(description: "")
        testPromise()
        .retry(5).then {
            XCTFail("testRetryNumberWhenKeepsFailing failed")
        }.onError { _ in
            e.fulfill()
            XCTAssertEqual(5, self.tryCount)
        }
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRetrySucceedsAfter3times() {
        let e = expectation(description: "")
        succeedsAfter3Times()
            .retry(10).then {
                e.fulfill()
                XCTAssertEqual(3, self.tryCount)
            }.onError { _ in
                XCTFail("testRetrySucceedsAfter3times failed")
            }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testRetryFailsIfNumberOfRetriesposisitethan1() {
        let e = expectation(description: "")
        testPromise()
            .retry(0).onError { _ in
            e.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testPromise() -> Promise<Void> {
        
        let callback: ((_ resolve: @escaping ((()) -> Void), _ reject: @escaping ((Error) -> Void)) -> Void)
            = { (resolve: @escaping ((()) -> Void), reject: @escaping ((Error) -> Void)) in
            self.tryCount += 1
            waitTime(0.1) {
                reject(ARandomError())
            }
        }
        
        return Promise<Void>(callback: callback)
    }
    
    func succeedsAfter3Times() -> Promise<Void> {
        
        let callback: ((_ resolve: @escaping ((()) -> Void), _ reject: @escaping ((Error) -> Void)) -> Void)
            = { (resolve: @escaping ((()) -> Void), reject: @escaping ((Error) -> Void)) in
                self.tryCount += 1
                if self.tryCount == 3 {
                    resolve(())
                } else {
                    reject(ARandomError())
                }
        }
        
        return Promise<Void>(callback: callback)
    }
}

struct ARandomError: Error { }
