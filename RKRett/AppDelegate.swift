//
//  AppDelegate.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/19/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

// How to document:
// http://nshipster.com/swift-documentation/

//import Parse
import SVProgressHUD
import UIKit

//MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder {
    
    var window: UIWindow?
    let kTagForViewDidEnterBackground = 99
    
    let appTasks : [DSTask] = DSTaskController.loadTasks()
    
    func createNotificationForDay(day: Int, hour: Int, minute: Int) -> UILocalNotification{
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let components = NSDateComponents()
        components.day = day
        components.month = NSDate().month
        components.year = NSDate().year
        components.hour = hour
        components.minute = minute
        components.second = 0
        let date = calendar?.dateFromComponents(components)
        let localNotification = UILocalNotification()
        localNotification.alertAction = NSLocalizedString("Reminder", comment: "")
        localNotification.alertBody = NSLocalizedString("You have pending tasks, please check the tasks tab", comment: "")
        localNotification.fireDate = date
        localNotification.repeatInterval = NSCalendarUnit.Day
        return localNotification
    }
    
    func configureNotifications(){
        if !isAllTasksCompleted{
            let notificationExist = (UIApplication.sharedApplication().scheduledLocalNotifications!.filter({ $0.fireDate!.isToday() }).count > 0)
            if !notificationExist{
                //Create notification for today if its not created
                UIApplication.sharedApplication().scheduleLocalNotification(createNotificationForDay(NSDate().day, hour: 14, minute: 30))
            }
        }else{
            //Create notification for tomorrow
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            UIApplication.sharedApplication().scheduleLocalNotification(createNotificationForDay(NSDate().day + 1, hour: 14, minute: 30))
        }
        
    }
    
    func initApp(){
        if(alreadyParticipating){
            gotoStoryboard(StoryboardName.Password.rawValue)
        } else {
            gotoStoryboard(StoryboardName.Consent.rawValue)
            KeychainWrapper.removeObjectForKey(kDSPasswordKey)
        }
    }
    
    func gotoStoryboard(initialStoryboard:String){
        let sb = UIStoryboard(name: initialStoryboard, bundle: nil)
        let vc = sb.instantiateInitialViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func configureAppearance(){
        SVProgressHUD.setForegroundColor(.purpleColor())
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.Black)
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
        UINavigationBar.appearance().tintColor = .purpleColor()
        UINavigationBar.appearance().barStyle = UIBarStyle.Default
        UINavigationBar.appearance().translucent = true
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.purpleColor()]
        
        UILabel.appearance().tintColor = .purpleColor()
        UIButton.appearance().tintColor = .purpleColor()
        UITabBar.appearance().tintColor = .purpleColor()
    }
    
    //Should be called on the first viewController that appear
    func configureTabBar(){
        //use this array to add news selectedIamges whem you add a new tab.
        if let tabBarController = self.window?.rootViewController as? UITabBarController{
            let tab = tabBarController.tabBar
            let tabBarImages = [
                0:["activities", "tabSelectedActivities"],
                1:["dashboard", "tabSelectedDash"],
                2:["learn", "tabSelectedLearn"]
            ]
            
            for (i, item) in tab.items!.enumerate(){
                if let imgsName = tabBarImages[i]{
                    let img = UIImage(named: imgsName[0])?.imageWithRenderingMode(.AlwaysOriginal)
                    let selectedImg = UIImage(named: imgsName[1])?.imageWithRenderingMode(.AlwaysOriginal)
                    item.image = img
                    item.selectedImage = selectedImg
                }
            }
        }
        
//        let imageNames = ["tabSelectedActivities", "tabSelectedDash", "tabSelectedLearn"]
//        
//        if let tabBarController = self.window?.rootViewController as? UITabBarController{
//            let tab = tabBarController.tabBar
//            for (i, item) in tab.items!.enumerate(){
//                if let imageName = imageNames[safe : i]{
//                    let img = UIImage(named: imageName)?.imageWithRenderingMode(.AlwaysOriginal)
//                    item.image = img
//                    item.selectedImage = img
//                }
//            }
//        }
    }
}

//MARK: UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate{
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if let tab = window?.rootViewController as? UITabBarController{
            tab.selectedIndex = TabBarItemIndexes.Tasks.rawValue
            print((tab.selectedViewController as! UINavigationController).topViewController)
            if let vc = ((tab.selectedViewController as! UINavigationController).topViewController) as? DSTaskListViewController{
                vc.restoreUserActivityState(userActivity)
                return true
            }
        }
        return false
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print(notification.userInfo)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        configureAppearance()
        initApp()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        let whiteView = UIView(frame: (self.window?.frame)!)
        whiteView.backgroundColor = UIColor.whiteColor()
        whiteView.tag = kTagForViewDidEnterBackground
        UIApplication.sharedApplication().delegate?.window??.addSubview(whiteView)
        
        let ribbon = UIImage(named: "RettLogo")
        let ribbonView = UIImageView(image: ribbon)
        ribbonView.frame = CGRectMake((whiteView.frame.width/2) - 50, (whiteView.frame.height/2) - 100, 100, 200)
        ribbonView.contentMode = .ScaleAspectFit
        
        whiteView.addSubview(ribbonView)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        for view in (window?.subviews)!{
            if(view.tag == kTagForViewDidEnterBackground){
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    view.alpha = 0
                    }, completion: { (success) -> Void in
                        view.removeFromSuperview()
                })
                break
            }
        }
    }
    
    func applicationSignificantTimeChange(application: UIApplication) {
        DSUtils.resetUserDefaults()
    }
}