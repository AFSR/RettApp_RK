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
        return UserDefaults.standard.bool(forKey: kUserHasConsentedKey)
    }
    set{
        UserDefaults.standard.set(newValue, forKey: kUserHasConsentedKey)
        UserDefaults.standard.synchronize()
    }
}

var useTouchId:Bool{
    get{
        return UserDefaults.standard.bool(forKey: Constants.PasswordUseTouchId)
    }
    set{
        UserDefaults.standard.set(newValue, forKey: Constants.PasswordUseTouchId)
        UserDefaults.standard.synchronize()
    }
}

var lastHKSyncDate : Date{
    get{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.lastHKSync
    }
    set{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.lastHKSync = newValue
        UserDefaults.standard.set(newValue, forKey: "lastHKSync")
    }
}

var tasks : [DSTask] {
    get{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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

func createSideViewForCell(_ cell: UITableViewCell, withColor color:UIColor){
    let frame = CGRect(x: 0,y: 0,width: 4,height: cell.frame.height)
    let leftView = UIView(frame: frame)
    leftView.backgroundColor = color
    leftView.translatesAutoresizingMaskIntoConstraints = false
    leftView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
    cell.contentView.addSubview(leftView)
}

var dateDidEnterBackground:Date?{
    get{
        return (UserDefaults.standard.object(forKey: kDateDidEnterBackgroundKey) as! Date)
    }
    set{
        UserDefaults.standard.set(newValue, forKey: kDateDidEnterBackgroundKey)
        UserDefaults.standard.synchronize()
    }
}

var bundleId:String{
    return Bundle.main.bundleIdentifier ?? "No bundle identifier!"
}
