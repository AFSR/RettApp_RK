//
//  DSGlobals.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/23/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import Foundation

var alreadyParticipating:Bool {
    get{
        return NSUserDefaults.standardUserDefaults().boolForKey(kUserHasConsentedKey)
    }
    set{
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kUserHasConsentedKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

var useTouchId:Bool{
    get{
        return NSUserDefaults.standardUserDefaults().boolForKey(Constants.PasswordUseTouchId)
    }
    set{
        NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Constants.PasswordUseTouchId)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

var tasks : [DSTask] {
    get{
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.appTasks
    }
}

var isAllTasksCompleted:Bool{
    get{
        for a in tasks where !a.isComplete(){
            return false
        }
        return true
    }
}

func createSideViewForCell(cell: UITableViewCell, withColor color:UIColor){
    let frame = CGRectMake(0, 0, 4, cell.frame.height)
    let leftView = UIView(frame: frame)
    leftView.backgroundColor = color
    leftView.translatesAutoresizingMaskIntoConstraints = false
    leftView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
    cell.contentView.addSubview(leftView)
}

var dateDidEnterBackground:NSDate?{
    get{
        return NSUserDefaults.standardUserDefaults().objectForKey(kDateDidEnterBackgroundKey) as? NSDate
    }
    set{
        NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kDateDidEnterBackgroundKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}

var bundleId:String{
    return NSBundle.mainBundle().bundleIdentifier ?? "No bundle identifier!"
}