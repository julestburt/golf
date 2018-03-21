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
        
        let alamoRequest = alamoFire.request(serviceURL + request.url, method: .get, parameters: params, encoding: URLEncoding.default, headers: headers) .validate() .responseJSON { response in
            
            switch response.result {
            case .success:
                if let json = response.result.value {
                    let result = JSON(json)
                    if let serverMessage = Utils.stringJSON(result["message"]) {
                        delegate.didFail(tag: request.tag, error: serverMessage, code: nil)
                        return
                    }
                    Utils().saveDebugData(result.description, fileName: request.tag)
                    delegate.didRecieve(tag: request.tag, result: result)
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
                delegate.didFail(tag: request.tag, error: error.localizedDescription, code: errorCode)
            }
        
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
    
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString

    func saveDebugData(_ sourceString:String, fileName:String) {
        
        #if DEBUG
            let fileNamePath = documentsPath.appendingPathComponent(fileName+".txt")
            do {
                
                try sourceString.write(toFile: fileNamePath, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("error saving file \(fileNamePath)")
                print(error.localizedDescription)
            }
        #endif
    }
    
    func loadDebugData(fileName:String) -> [AnyObject]? {
        let inventoryPath = documentsPath.appendingPathComponent(fileName)
        do {
            let sourceString = try NSString(contentsOfFile: inventoryPath, encoding: String.Encoding.utf8.rawValue)
            let strippedText = sourceString.replacingOccurrences(of: "#!\"C:\\Bitnami\\wampstack-5.5.34-0\\php\\php\"\r\n", with: "")
            let data2 = strippedText.data(using: String.Encoding.utf8)
            let array = try JSONSerialization.jsonObject(with: data2!, options: JSONSerialization.ReadingOptions(rawValue: 0))  as? [AnyObject]
            return array!
        } catch let error as NSError {
            print("error loading from file \(inventoryPath)")
            print(error.localizedDescription)
            return nil
        }
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
