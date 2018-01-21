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
import Buglife

//MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder {
    
    var window: UIWindow?
    let kTagForViewDidEnterBackground = 99
    
    let appTasks : [DSTask] = DSTaskController.loadTasks()
    
    func createNotificationForDay(_ day: Int, hour: Int, minute: Int) -> UILocalNotification{
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var components = DateComponents()
        components.day = day
        components.month = Date().month
        components.year = Date().year
        components.hour = hour
        components.minute = minute
        components.second = 0
        let date = calendar.date(from: components)
        let localNotification = UILocalNotification()
        localNotification.alertAction = NSLocalizedString("Reminder", comment: "")
        localNotification.alertBody = NSLocalizedString("You have pending tasks, please check the tasks tab", comment: "")
        localNotification.fireDate = date
        localNotification.repeatInterval = NSCalendar.Unit.day
        return localNotification
    }
    
    func configureNotifications(){
        if !isAllTasksCompleted{
            let notificationExist = (UIApplication.shared.scheduledLocalNotifications!.filter({ $0.fireDate!.isToday() }).count > 0)
            if !notificationExist{
                //Create notification for today if its not created
                UIApplication.shared.scheduleLocalNotification(createNotificationForDay(Date().day, hour: 14, minute: 30))
            }
        }else{
            //Create notification for tomorrow
            UIApplication.shared.cancelAllLocalNotifications()
            UIApplication.shared.scheduleLocalNotification(createNotificationForDay(Date().day + 1, hour: 14, minute: 30))
        }
        
    }
    
    func initApp(){
        if(alreadyParticipating){
            gotoStoryboard(StoryboardName.Password.rawValue)
        } else {
            gotoStoryboard(StoryboardName.Consent.rawValue)
            //KeychainWrapper.removeObject(forKey: kDSPasswordKey as! String)
        }
    }
    
    func gotoStoryboard(_ initialStoryboard:String){
        let sb = UIStoryboard(name: initialStoryboard, bundle: nil)
        let vc = sb.instantiateInitialViewController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
    
    func configureAppearance(){
        SVProgressHUD.setForegroundColor(.purple)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        
        UIApplication.shared.statusBarStyle = .default
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = .purple
        UINavigationBar.appearance().barStyle = UIBarStyle.default
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.purple]
        
        UILabel.appearance().tintColor = .purple
        UIButton.appearance().tintColor = .purple
        UITabBar.appearance().tintColor = .purple
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
            
            for (i, item) in tab.items!.enumerated(){
                if let imgsName = tabBarImages[i]{
                    let img = UIImage(named: imgsName[0])?.withRenderingMode(.alwaysOriginal)
                    let selectedImg = UIImage(named: imgsName[1])?.withRenderingMode(.alwaysOriginal)
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
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let tab = window?.rootViewController as? UITabBarController{
            tab.selectedIndex = TabBarItemIndexes.tasks.rawValue
            print((tab.selectedViewController as! UINavigationController).topViewController)
            if let vc = ((tab.selectedViewController as! UINavigationController).topViewController) as? DSTaskListViewController{
                vc.restoreUserActivityState(userActivity)
                return true
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print(notification.userInfo)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureAppearance()
        initApp()
        
        
        //Buglife setup
        print("Buglife Setup")
        Buglife.shared().start(withAPIKey: "aqXSsXuIBBCd4BAu9tdcVwtt")
        //Buglife.shared().invocationOptions = .floatingButton
        Buglife.shared().invocationOptions = .screenshot

        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        let whiteView = UIView(frame: (self.window?.frame)!)
        whiteView.backgroundColor = UIColor.white
        whiteView.tag = kTagForViewDidEnterBackground
        UIApplication.shared.delegate?.window??.addSubview(whiteView)
        
        let ribbon = UIImage(named: "RettLogo")
        let ribbonView = UIImageView(image: ribbon)
        ribbonView.frame = CGRect(x: (whiteView.frame.width/2) - 50, y: (whiteView.frame.height/2) - 100, width: 100, height: 200)
        ribbonView.contentMode = .scaleAspectFit
        
        whiteView.addSubview(ribbonView)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        for view in (window?.subviews)!{
            if(view.tag == kTagForViewDidEnterBackground){
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    view.alpha = 0
                    }, completion: { (success) -> Void in
                        view.removeFromSuperview()
                })
                break
            }
        }
    }

    func applicationSignificantTimeChange(_ application: UIApplication) {
        DSUtils.resetUserDefaults()
    }
}
