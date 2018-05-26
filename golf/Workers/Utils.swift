//
//  Utils.swift
//  golf
//
//  Created by Jules Burt on 2018-04-14.
//  Copyright © 2018 bethegame Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

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
    
    static func lock(obj: Any, blk:() -> ()) {
        objc_sync_enter(obj)
        blk()
        objc_sync_exit(obj)
    }
    
    
}
