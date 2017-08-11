//
//  DSTaskScheduler.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/8/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

/**
The `DSTaskScheduler` handles all the task scheduling and management
*/
class DSTaskScheduler: NSObject {
    
    /**
    Singleton instance
    */
    static let sharedInstance:DSTaskScheduler = DSTaskScheduler()
    
    /**
    Register and trigger a task according to frequency
    
    :warning: Warning description
    
    - parameter id: A unique id used to identify a task registered
    - parameter frequencyNumber:
    - parameter frequencyType:
    
    - returns: `Bool` that represent if the registering succeded or not
    */
    func registerTaskForScheduleWithId(_ id:String, frequencyNumber:NSNumber){
        
    }
    
    func registerTaskForScheduleWithId(_ id:String, onWeekDays weekDays:[Int]){
        let kNotificationsDictionary = "kNotificationsDictionary"
        var dates = [Date]()
        for weekDay in weekDays{
            dates += [nextDateForWeekday(weekDay, fromDate: Date())]
        }
        UserDefaults.standard.set(["taskId":id, "dates":dates], forKey: kNotificationsDictionary)
    }
    
    func nextDateForWeekday(_ desiredWeekday: Int, fromDate: Date) -> Date {
        let weekdayFromDate = fromDate.weekDay
        let difference = desiredWeekday-weekdayFromDate
        let daysToDay = (difference == 0 && Date().timeIntervalSinceNow < fromDate.timeIntervalSinceNow) ? 0 : (difference > 0 ? difference : difference+7)
        
        self.registerTaskForScheduleWithId("", frequencyNumber: 2)
        
        return fromDate.dateByAddingTimeInterval((60 * 60 * 24 * Double(daysToDay)) as NSTimeInterval);
    }
   
}

