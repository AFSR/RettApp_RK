//
//  DSTask.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class DSTask: DSReflect {
    
    @objc var taskId:String!
    @objc var name:String!
    @objc var file:String!
    @objc var frequencyNumber:NSNumber!
    @objc var frequencyType:String!
    @objc var questions:[DSQuestion] = [DSQuestion]()
    @objc var type:String!
    @objc var status:Bool = true
    
    @objc init(plistFileName:String){
        super.init()
        self.file = plistFileName
        if let path = Bundle.main.path(forResource: plistFileName, ofType: "plist") {
            if let taskDictionary = NSDictionary(contentsOfFile: path){
                let properties = self.properties()
                for property in properties{
                    switch(property){
                    case "file":
                        continue
                        
                    case "questions":
                        if let questionsArray = taskDictionary.object(forKey: property) as? NSArray{
                            for questionDictionary in questionsArray as! [NSDictionary]{
                                let question = DSQuestion(questionDictionary: questionDictionary)
                                questions += [question]
                            }
                        }else{
                            print("problema ao gerar array das questions na DSTask")
                        }
                    case "type":
                        type = taskDictionary.object(forKey: "type") as? String

                    case "status":
                        status = (taskDictionary.object(forKey: "status") as! Bool)

                    default:
                        print("default")
                    }
                    
                    let propertyValue: AnyObject? = taskDictionary.object(forKey: property) as AnyObject
                    assert(propertyValue != nil, "\(property) in task \(self.name) is nil")
                    self.setValue(propertyValue, forKey: property)
                }
                
            }
        }
    }
    /*
        Returns true if the Frequency is set to OnDemand
    */
    func isComplete() -> Bool{
        let userDefaults = UserDefaults.standard
        var numberOfTasksCompletedes:AnyObject!
        
        if let taskDic = userDefaults.object(forKey: self.taskId) as? [String:AnyObject]{
            numberOfTasksCompletedes = (taskDic[PlistFile.Task.FrequencyNumber.rawValue] as! Int == 0) ? nil : taskDic[PlistFile.Task.FrequencyNumber.rawValue]
        } else {
            numberOfTasksCompletedes = nil
        }
        
        if(numberOfTasksCompletedes?.intValue >= self.frequencyNumber.intValue) && (self.frequencyType != Frequency.OnDemand.rawValue){
            return true
        } else if(self.frequencyType == Frequency.OnDemand.rawValue){
            return true
        } else{
            return false
        }
    }
    
    func writeProperties(){
        if let taskPath = Bundle.main.path(forResource: file, ofType: "plist") {
            if let taskFromPlist = NSMutableDictionary(contentsOfFile: taskPath){
                taskFromPlist.setValue(type, forKeyPath: "type")
                taskFromPlist.setValue(status, forKeyPath: "status")
                taskFromPlist.write(toFile: taskPath, atomically: true)
            }
        }
        
    }
    
    
}
