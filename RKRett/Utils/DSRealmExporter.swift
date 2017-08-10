//
//  DSResultsExporter.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/24/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import Foundation
//import Realm
import RealmSwift

class DSRealmExporter: NSObject {
    
    static let Separator = ","
    static let NewLine = "\n"
    
    static func exportResultsToCSV() throws -> NSURL{
        var fileContent = "Date,Task,ResultKey,ResultValue"
        do{
            let realm = try Realm()
            let taskAnswers = realm.objects(DSTaskAnswerRealm).sorted("taskName")
            if taskAnswers.isEmpty {
                throw NSError(domain: "io.darkshine", code: 1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("No results to export!", comment:"")])
            }
            
            for taskAnswer in taskAnswers{
                let jsonString = taskAnswer.json
                if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding){
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
//                    print(json)
                    let results = json.objectForKey("results") as! NSDictionary
                    for key in results.allKeys{
//                        print(result)
                        let resultKey = results.objectForKey(key) as! NSDictionary
                        let dateString = resultKey.objectForKey("date") as! String
                        let value = resultKey.objectForKey("result")!
                        fileContent += "\n\(taskAnswer.taskName),\(dateString),\(key),\(value)"
                    }
                }
            }
            
//            print(fileContent)
            let fileName = NSDate().stringDateWithFormat() + ".csv"
            let filePath = NSTemporaryDirectory() + fileName
            let url = NSURL(fileURLWithPath: filePath)
            try fileContent.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            return url
        }catch let error as NSError{
            print(error.localizedDescription)
            throw error
        }
    }
    
}
