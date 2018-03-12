//
//  APIService.swift
//  golf
//
//  Created by Jules Burt on 2018-03-11.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//
import Foundation
import SwiftyJSON
import Alamofire

//protocol APIResponse: class {
//    func didRecieve(_ service:APIService, tag:String, result:JSON)
//    func didFail(_ service)
//}

class API : NSObject {
    
    static let service = API()
    
    fileprivate(set) var alamoFire:SessionManager!
    
    fileprivate var APIcompletions = [((APICompletionResult<NSData>) -> Void)?]()
    enum APICompletionResult<T> {
        case Success((service:API, tag:String, result:JSON))
        case Error((error:String, code:Int, message:String))
    }
    
    override init() {
        super.init()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20
        sessionConfig.timeoutIntervalForResource = 60
//        let alamo = Alamofire.
    }
    
    

}
