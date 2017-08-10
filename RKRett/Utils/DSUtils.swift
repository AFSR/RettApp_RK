//
//  DSUtils.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/22/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit

class DSUtils{
    
    static func applyStyleDictionary(dictionary:NSDictionary, onTag tag:String, withText text:String) -> String{
        var string = ""
        for key in dictionary.allKeys{
            if let value = dictionary.objectForKey(key) as? String{
                string += "\(key):\(value);"
            }
        }
        
        string = "<\(tag) style='\(string)'>\(text)</\(tag)>"
        return string
    }

    
    static func updateUserDefaultsFor(task: DSTask){
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var taskDic = userDefaults.objectForKey(task.taskId) as? [String:AnyObject]
        
        if (taskDic != nil){
            let numberOfCompleted = taskDic![PlistFile.Task.FrequencyNumber.rawValue] as! Int
            taskDic![PlistFile.Task.FrequencyNumber.rawValue] = numberOfCompleted+1
        } else {
            taskDic = [String: AnyObject]()
            taskDic![PlistFile.Task.FrequencyType.rawValue] = task.frequencyType
            taskDic![PlistFile.Task.FrequencyNumber.rawValue] = 1
        }
        
        userDefaults.setObject(taskDic, forKey: task.taskId)
        userDefaults.synchronize()
    }
    
    static func resetUserDefaults(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let date = NSDate()
        
        if let updateDic = userDefaults.objectForKey(LastUpdated.Key.rawValue) as? [String:Int] {
            print(updateDic)
            let sunday = (date.weekDay == kSundayIdentifier)
            let monthChanged = !(date.month == updateDic[LastUpdated.Month.rawValue])
            
            for task in tasks{
                var taskDic = userDefaults.objectForKey(task.taskId) as? [String: AnyObject]
                if (taskDic != nil) {
                    if let taskFrequency = taskDic![PlistFile.Task.FrequencyType.rawValue] as? String{
                        let shouldReset = ( (taskFrequency==Frequency.Monthly.Key.rawValue && monthChanged) || (taskFrequency==Frequency.Weekly.Key.rawValue && sunday) || (taskFrequency==Frequency.Daily.Key.rawValue))
                        if(shouldReset){
                            taskDic![PlistFile.Task.FrequencyNumber.rawValue] = 0
                            userDefaults.setObject(taskDic, forKey: task.taskId)
                        }
                    }
                }
                
            }
        } else {
            var updateDic = [String:Int]()
            updateDic[LastUpdated.Month.rawValue] = date.month
            updateDic[LastUpdated.DayOfTheWeek.rawValue] = date.weekDay
            userDefaults.setObject(updateDic, forKey: LastUpdated.Key.rawValue)
        }
    }
}

///lastUpdate
    ///dayString -> didChangeWeek
    ///monthString -> monthly
