//
//  DSNotification.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/8/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

class DSNotification: NSObject {
    
    /**
    The notification that will be shown
    */
    var notification:UILocalNotification!
    
    /**
    Week days that the notification should be triggered.
    0-Sunday, 1-Monday, 2-Tuesday, 3-Wednesday, 4-Thursday, 5-Friday, 6-Saturday
    */
    var weekDays:[NSNumber]!
    
    /**
    Time of the day in seconds from 00:00
    */
    var time:NSNumber!
    
    func test(){
        let not = UILocalNotification()
        let frequencyStr = "daily"
        if let frequency = DSFrequencyType(rawValue: frequencyStr){
            let interval = getIntervalForFrequency(frequency)
            not.repeatInterval = interval
//            let fireDate = getNextFireDate()
            not.fireDate = Date()
        }
    }
    
    enum DSFrequencyType:String{
        case None = "none", Daily = "daily", Weekly = "weekly", Monthly = "monthly"
        
        var description:String{
            return self.rawValue
        }
    }
    
    func getIntervalForFrequency(_ frequency:DSFrequencyType) -> Calendar.Component{
        var repeatInterval = NSCalendar.Unit()
        switch(frequency){
        case .None:
            print("None")
            break
            
        case .Daily:
            repeatInterval = NSCalendar.Unit.day
            print("Daily")
            break

        case .Weekly:
            repeatInterval = NSCalendar.Unit.weekday
            print("Weekly")
            break
        
        case .Monthly:
            repeatInterval = NSCalendar.Unit.month
            print("Monthly")
            break
        }
        
//        var interval = 0
//        switch(frequency){
//        case NSCalendarUnit.CalendarUnitHour:
//            interval = 60 * 60
//            break
//            
//        case NSCalendarUnit.CalendarUnitWeekday:
//            interval = 60 * 60 * 24 * 7
//            break
//            
//        case NSCalendarUnit.DayCalendarUnit:
//            interval = 60 * 60
//            break
//            
//        default:
//            interval = 1
//        }
        return repeatInterval
    }
    
    func nextDateForWeekday(_ desiredWeekday: Int, fromDate: Date) -> Date {
        let weekdayFromDate = fromDate.weekDay
        let difference = desiredWeekday-weekdayFromDate
        let daysToDay = (difference == 0 && Date().timeIntervalSinceNow < fromDate.timeIntervalSinceNow) ? 0 : (difference > 0 ? difference : difference+7)
        
        return fromDate.dateByAddingTimeInterval((60 * 60 * 24 * Double(daysToDay)) as NSTimeInterval);
    }
    
    func rescheduleAlerts(_ includingReminders: Bool = false) {
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
            
//            for notification in (UIApplication.sharedApplication().scheduledLocalNotifications){
//                //                notification.
//                //                if !(n.alertBody!.hasPrefix(NSLocalizedString("REMINDER", comment: ""))) || includingReminders {
//                //                    UIApplication.sharedApplication().cancelLocalNotification(n)
//                //                }
//            }
            
            //            if NSUserDefaults.standardUserDefaults().objectForKey(ALERT_SETTING_KEY) as! Bool {
            //
            //                let todayComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: NSDate())
            //
            //                for med in self.medicines {
            //                    for (weekday, should) in med.peridiocity.componentsSeparatedByString("|")[0...6].enumerate() {
            //                        for time in med.timetablesArr {
            //                            let dateForWeekday = DSNotification.nextDateForWeekday(weekday+1, fromDate: ReMedMeUtils.todayWithTimeFromDate(time))
            //
            //                            if should == "1" {
            //                                let localNotification = UILocalNotification()
            //
            //                                if NSUserDefaults.standardUserDefaults().objectForKey(HIDE_NAME_SETTING_KEY) as! Bool == true {
            //                                    localNotification.alertBody = String(format: NSLocalizedString("NOTIFICATION_NAME_HIDDEN", comment: ""), self._formatter.stringFromDate(time))
            //                                } else {
            //                                    let unit = NSLocalizedString("UNIT_\(med.unit!)", comment: "")
            //                                    localNotification.alertBody = String(format: NSLocalizedString("NOTIFICATION_REGULAR", comment: ""), med.drugName!, med.amount!.floatValue, unit, self._formatter.stringFromDate(time))
            //                                }
            //
            //                                print("Scheduled for \(dateForWeekday): \(localNotification.alertBody!)")
            //
            //                                if dateForWeekday.timeIntervalSince1970 <= dateForWeekday.timeIntervalSince1970 {
            //                                    continue
            //                                }
            //
            //                                localNotification.soundName = UILocalNotificationDefaultSoundName
            //                                localNotification.fireDate = dateForWeekday
            //                                if NSUserDefaults.standardUserDefaults().objectForKey(REPEAT_ALERT_SETTING_KEY) as! Bool == true {
            //                                    if #available(iOS 8.0, *) {
            //                                        localNotification.category = MEDICINE_NOTIFICATION_CATEGORY
            //                                    }
            //                                }
            //                                localNotification.repeatInterval = .Weekday
            //                                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            //                            }
            //                        }
            //                    }
            //                }
            //            }
            
            print("Amount of notifications scheduled: \(UIApplication.shared.scheduledLocalNotifications!.count)", terminator: "")
            
        });
    }
    
}
