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

protocol APIResponse: class {
    func didRecieve(tag:String, result:JSON)
    func didFail(tag:String, error:String, code:Int?)
}

let serviceURL = "https://leaderboard-techtest.herokuapp.com"

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
        alamoFire = Alamofire.SessionManager(configuration: sessionConfig)
    }
    var currentRequests:[DataRequest] = []
    
    func request(tag:String, url:String, delegate:APIResponse, maxRetry:Int = 3) -> String {
        var headers = [String:String]()
        let params = [String:AnyObject]()
        let token = "UNVCRDFR5M8BW0P72KU6"
        headers["Authorization"] = token
        let request = APIRequest(tag:tag, url:url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers, retryCount:maxRetry)
        
        // check about API reachbility...
        
        let alamoRequest = alamoFire.request(serviceURL + request.url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers) .responseJSON { response in
            guard response.result.error == nil else {
                
                // basic error handling here
                if let error = response.result.error as NSError? {
                    if error.code > 0 {
                        delegate.didFail(tag: request.tag, error: "\(error.code)", code: error.code)
                        return
                    }
                }
                return
            }
            if response.result.isFailure {
                delegate.didFail(tag: request.tag, error: response.result.description, code: -1)
                return
            }
            
            let result = JSON(response.result.value!)
//            print(result)
            if result["message"] == "unauthorized" {
                delegate.didFail(tag: request.tag, error: result["message"].stringValue, code: nil)
                return
            }
            
            let jsonResponse = JSON(response.data!)
            if result["status"].exists(), let code = Utils.intJSON(result["status"]["code"]) {
                if !(code >= 200 && code < 300) {
                    if let message = Utils.stringJSON(result["status"]["message"]) {
                        delegate.didFail(tag: request.tag, error: message, code: code)
                    } else {
                        delegate.didFail(tag: request.tag, error: "No Message", code: code)
                    }
                    return
                }
            }
            delegate.didRecieve(tag: request.tag, result: result)
            return
        }
        currentRequests.append(alamoRequest)
        return request.ID
    }
}

class Utils {
    
    static func stringJSON(_ json:JSON) -> String? {
        if json.exists() && json.type == .string, let string = json.string {
            return string
        }
        return nil
    }
    
    static func intJSON(_ json:JSON) -> Int? {
        if json.exists() {
            if json.type == .number {
                return json.intValue
            } else if json.type == .string, let val = Int(json.stringValue) {
                return val
            }
        }
        return nil
    }
}

enum APIRequestMethod {
    case get, post
}

class APIRequest: NSObject {
    let ID:String
    let tag:String
    let url:String
    let method:APIRequestMethod
    let encoding:ParameterEncoding
    let headers:[String:String]
    let params:[String:AnyObject]
    var retryCount:Int = 0
    
    init(tag:String, url:String, method:APIRequestMethod, parameters:[String:AnyObject], encoding:ParameterEncoding, headers:[String:String], retryCount:Int) {
        self.ID = UUID().uuidString
        self.tag = tag
        self.url = url
        self.method = method
        self.encoding = encoding
        self.headers = headers
        self.params = parameters
        self.retryCount = retryCount
    }
}
