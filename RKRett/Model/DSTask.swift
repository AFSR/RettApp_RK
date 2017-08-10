//
//  DSTask.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

class DSTask: DSReflect {
    
    var taskId:String!
    var name:String!
    var file:String!
    var frequencyNumber:NSNumber!
    var frequencyType:String!
    var questions:[DSQuestion] = [DSQuestion]()
    
    init(plistFileName:String){
        super.init()
        self.file = plistFileName
        if let path = NSBundle.mainBundle().pathForResource(plistFileName, ofType: "plist") {
            if let taskDictionary = NSDictionary(contentsOfFile: path){
                let properties = self.properties()
                for property in properties{
                    switch(property){
                    case "file":
                        continue
                        
                    case "questions":
                        if let questionsArray = taskDictionary.objectForKey(property) as? NSArray{
                            for questionDictionary in questionsArray as! [NSDictionary]{
                                let question = DSQuestion(questionDictionary: questionDictionary)
                                questions += [question]
                            }
                        }else{
                            print("problema ao gerar array das questions na DSTask")
                        }
                        
                    default:
                        print(property)
                    }
                    
                    let propertyValue: AnyObject? = taskDictionary.objectForKey(property)
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
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var numberOfTasksCompletedes:AnyObject!
        
        if let taskDic = userDefaults.objectForKey(self.taskId) as? [String:AnyObject]{
            numberOfTasksCompletedes = (taskDic[PlistFile.Task.FrequencyNumber.rawValue] as! Int == 0) ? nil : taskDic[PlistFile.Task.FrequencyNumber.rawValue]
        } else {
            numberOfTasksCompletedes = nil
        }
        
        if(numberOfTasksCompletedes?.integerValue >= self.frequencyNumber.integerValue) && (self.frequencyType != Frequency.OnDemand.rawValue){
            return true
        } else if(self.frequencyType == Frequency.OnDemand.rawValue){
            return true
        } else{
            return false
        }
    }
    
}