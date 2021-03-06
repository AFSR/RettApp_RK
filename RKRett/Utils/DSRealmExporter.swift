//
//  DSResultsExporter.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/24/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import Foundation
import CoreData

@available(iOS 10.0, *)
class DSRealmExporter: NSObject {
    
    static let Separator = ","
    static let NewLine = "\n"
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    static func exportResultsToCSV() throws -> URL{
        var fileContent = "Date,Task,ResultKey,ResultValue"
//        do{
//
//            //Core Data
//            let context = appDelegate.persistentContainer.viewContext
//            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer")
//            // Configure the request's entity, and optionally its predicate
//            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "taskName", ascending: true)]
//            let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//            do {
//                try controller.performFetch()
//            } catch {
//                fatalError("Failed to fetch entities: \(error)")
//            }
//
//            for object in controller.fetchedObjects as! [NSManagedObject]{
//                let jsonString = object.value(forKey: "json")
//                let json = try JSONSerialization.jsonObject(with: jsonString, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
//                let results = json["results"] as! NSDictionary
//
//                for key in results.allKeys{
//                    let resultKey = results.object(forKey: key) as! NSDictionary
//                    let dateString = resultKey.object(forKey: "date") as! String
//                    let value = resultKey.object(forKey: "result")!
//                    fileContent += "\n\(taskAnswer.taskName),\(dateString),\(key),\(value)"
//                }
//            }
//
////            let realm = try Realm()
////            let taskAnswers = realm.objects(DSTaskAnswerRealm.self).sorted(byKeyPath: "taskName")
////            if taskAnswers.isEmpty {
////                throw NSError(domain: "io.darkshine", code: 1, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("No results to export!", comment:"")])
////            }
//
//            for taskAnswer in taskAnswers{
//                let jsonString = taskAnswer.json
//                if let data = jsonString.data(using: String.Encoding.utf8){
//                    let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
////                    print(json)
//                    let results = json["results"] as! NSDictionary
//                    //let results = (json as AnyObject).object("results") as! NSDictionary
//
//                    for key in results.allKeys{
////                        print(result)
//                        let resultKey = results.object(forKey: key) as! NSDictionary
//                        let dateString = resultKey.object(forKey: "date") as! String
//                        let value = resultKey.object(forKey: "result")!
//                        fileContent += "\n\(taskAnswer.taskName),\(dateString),\(key),\(value)"
//                    }
//                }
//            }
//
////            print(fileContent)
            let fileName = Date().stringDateWithFormat() + ".csv"
            let filePath = NSTemporaryDirectory() + fileName
            let url = URL(fileURLWithPath: filePath)
            try fileContent.write(to: url, atomically: true, encoding: String.Encoding.utf8)
            return url
//        }catch let error as NSError{
//            print(error.localizedDescription)
//            throw error
//        }
    }
    
}
