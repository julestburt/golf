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

protocol APIService {
    func request(tag:String, url:String, expectJSONArray:Bool, completion:@escaping jsonCompletion)
}

typealias jsonCompletion = ((APIDataResult<NSData>)->())
enum APIDataResult<T> {
    case Success(data:JSON)
    case Error((error:String, code:Int, message:String))
}

let serviceURL = "https://leaderboard-techtest.herokuapp.com"

class API : NSObject, APIService {
    
    private static var _instance: API?
    
    class var service: API {
        if _instance == nil {
            _instance = API()
        }
        return _instance!
    }
    
    func dispose() {
        API._instance = nil
        print("Disposed Singleton instance")
    }
    
    fileprivate(set) var alamoFire:SessionManager!
    var currentRequests:[String:APIRequest] = [:]

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
        print("started")
    }
    
    func request(tag:String, url:String, expectJSONArray:Bool, completion:@escaping jsonCompletion) {
        return requestWithRetries(tag: tag, url: url, expectJSONArray:expectJSONArray, completion:completion)
    }

    func requestWithRetries(tag:String, url:String, maxRetry:Int = 3, expectJSONArray:Bool,  completion:@escaping jsonCompletion) {
        var headers = [String:String]()
        let params = [String:AnyObject]()
        let token = "UNVCRDFR5M8BW0P72KU6"
        headers["Authorization"] = token
        
        let alamoRequest = alamoFire.request(serviceURL + url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers) .validate() .responseJSON { response in
            
            switch response.result {
            case .success:
                if let json = response.result.value {
                    let result = JSON(json)
                    if let serverMessage = Utils.stringJSON(result["message"]) {
                        self.didFail(tag: tag, error: serverMessage, code: nil)
                        return
                    }
                    Utils().saveDebugData(result.description, fileName: tag)
                    self.didRecieve(tag: tag, result: result)
                }
            case .failure(let error):
                var errorMessage:String = ""
                var errorCode:Int?
                if let error = error as? AFError {
                    switch error {
                    case .invalidURL(let url):
                        errorMessage = "Invalid URL: \(url) - \(error.localizedDescription)"
                    case .parameterEncodingFailed(let reason):
                        errorMessage = "Parameter encoding failed: \(error.localizedDescription)"
                        errorMessage += " - Failure Reason: \(reason)"
                    case .multipartEncodingFailed(let reason):
                        errorMessage = "Multipart encoding failed: \(error.localizedDescription)"
                        errorMessage += "- Failure Reason: \(reason)"
                    case .responseValidationFailed(let reason):
                        errorMessage = "Response validation failed: \(error.localizedDescription)"
                        errorMessage += " - Failure Reason: \(reason)"
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            errorMessage += ", Downloaded file could not be read"
                        case .missingContentType(let acceptableContentTypes):
                            errorMessage += ", Content Type Missing: \(acceptableContentTypes)"
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            errorMessage += ", Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)"
                        case .unacceptableStatusCode(let code):
                            errorMessage += ", Response status code was unacceptable: \(code)"
                            errorCode = code
                        }
                    case .responseSerializationFailed(let reason):
                        errorMessage = "Response serialization failed: \(error.localizedDescription)"
                        errorMessage += "- Failure Reason: \(reason)"
                    }
                    
                }
                self.didFail(tag: tag, error: error.localizedDescription, code: errorCode)
            }
        }
        let request = APIRequest(tag:tag, url:url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers, retryCount:maxRetry, processJSONArray: expectJSONArray, request: alamoRequest, completion:completion)
        currentRequests[tag] = request
    }
}

extension API: APIResponse {
    func didRecieve(tag: String, result: JSON) {
        print(result)
        let data = result["data"]
        if let request = currentRequests[tag] {
            if request.processJSONArray {
                if let array = processArrayJSON(data) {
                    request.completion(.Success(data:array))
                } else {
                    request.completion(.Error((error:"Couldn't process array from JSON", code:-1, message:tag)))
                }
            } else {
                request.completion(.Success(data:data))
            }
            removeRequests(tag: tag)
        } else {
            assert(true, "Problem with extracting JSON or missing completion return. Both bad!")
        }
    }
    
    func didFail(tag: String, error: String, code: Int?) {
        if let request = currentRequests[tag] {
            request.completion(.Error((error:error, code:code != nil ? code! : -1, message:tag)))
            removeRequests(tag: tag)
            print("API error:\(error), code:\(String(describing: code)), tag:\(tag)")
        }
    }
    
    func removeRequests(tag:String) {
        currentRequests[tag] = nil
        if currentRequests.count == 0 {
            dispose()
        }
    }
    
    func processArrayJSON (_ data:JSON) -> JSON? {
        if !data.isEmpty && data.count > 0 {
            return data
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
    let processJSONArray:Bool
    let request:DataRequest
    let completion:jsonCompletion
    
    init(tag:String, url:String, method:APIRequestMethod, parameters:[String:AnyObject], encoding:ParameterEncoding, headers:[String:String], retryCount:Int, processJSONArray:Bool, request:DataRequest, completion:@escaping jsonCompletion) {
        self.ID = UUID().uuidString
        self.tag = tag
        self.url = url
        self.method = method
        self.encoding = encoding
        self.headers = headers
        self.params = parameters
        self.retryCount = retryCount
        self.processJSONArray = processJSONArray
        self.request = request
        self.completion = completion
    }
}
