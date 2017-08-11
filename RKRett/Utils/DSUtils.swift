//
//  DSUtils.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/22/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit

class DSUtils{
    
    static func applyStyleDictionary(_ dictionary:NSDictionary, onTag tag:String, withText text:String) -> String{
        var string = ""
        for key in dictionary.allKeys{
            if let value = dictionary.object(forKey: key) as? String{
                string += "\(key):\(value);"
            }
        }
        
        string = "<\(tag) style='\(string)'>\(text)</\(tag)>"
        return string
    }

    
    static func updateUserDefaultsFor(_ task: DSTask){
        
        let userDefaults = UserDefaults.standard
        var taskDic = userDefaults.object(forKey: task.taskId) as? [String:AnyObject]
        
        if (taskDic != nil){
            let numberOfCompleted = taskDic![PlistFile.Task.FrequencyNumber.rawValue] as! Int
            taskDic![PlistFile.Task.FrequencyNumber.rawValue] = numberOfCompleted+1 as AnyObject
        } else {
            taskDic = [String: AnyObject]()
            taskDic![PlistFile.Task.FrequencyType.rawValue] = task.frequencyType as AnyObject
            taskDic![PlistFile.Task.FrequencyNumber.rawValue] = 1 as AnyObject
        }
        
        userDefaults.set(taskDic, forKey: task.taskId)
        userDefaults.synchronize()
    }
    
    static func resetUserDefaults(){
        let userDefaults = UserDefaults.standard
        let date = Date()
        let myCalendar = Calendar(identifier: .gregorian)
        
        if let updateDic = userDefaults.object(forKey: LastUpdated.Key.rawValue) as? [String:Int] {
            print(updateDic)
            
            let sunday = (myCalendar.component(.weekday, from: date as Date) == kSundayIdentifier)
            //let sunday = (date.weekDay == kSundayIdentifier)
            
            //let monthChanged = !(date.month == updateDic[LastUpdated.Month.rawValue])
            let monthChanged = !(myCalendar.component(.month, from: date as Date) == updateDic[LastUpdated.Month.rawValue])
            
            
            for task in tasks{
                var taskDic = userDefaults.object(forKey: task.taskId) as? [String: AnyObject]
                if (taskDic != nil) {
                    if let taskFrequency = taskDic![PlistFile.Task.FrequencyType.rawValue] as? String{
                        let shouldReset = ( (taskFrequency==Frequency.Monthly.Key.rawValue && monthChanged) || (taskFrequency==Frequency.Weekly.Key.rawValue && sunday) || (taskFrequency==Frequency.Daily.Key.rawValue))
                        if(shouldReset){
                            taskDic![PlistFile.Task.FrequencyNumber.rawValue] = 0 as AnyObject
                            userDefaults.set(taskDic, forKey: task.taskId)
                        }
                    }
                }
                
            }
        } else {
            var updateDic = [String:Int]()
            updateDic[LastUpdated.Month.rawValue] = myCalendar.component(.month, from: date as Date)
            updateDic[LastUpdated.DayOfTheWeek.rawValue] = myCalendar.component(.weekday, from: date as Date)
            userDefaults.set(updateDic, forKey: LastUpdated.Key.rawValue)
        }
    }
}

///lastUpdate
    ///dayString -> didChangeWeek
    ///monthString -> monthly
