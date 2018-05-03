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
import RealmSwift
import Parse

//MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder {
    
    var window: UIWindow?
    let kTagForViewDidEnterBackground = 99
    
    let appTasks : [DSTask] = DSTaskController.loadTasks()
    var healthManager = HealthManager()
    let healthStore = HKHealthStore()
    
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
            populateDashboardWithHealthData()
        } else {
            gotoStoryboard(StoryboardName.Consent.rawValue)
            KeychainWrapper.standard.removeObject(forKey: kDSPasswordKey)
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
    
    func populateDashboardWithHealthData(){
        
        print("Populate Dashboard with Health Data in Progress")
        //Recheck HealthStore Access
        self.healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if error == nil {
                print("HealthKit authorization received.")
                if(!alreadyParticipating){
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.healthManager.showHealthKitAlert()
                    })
                }
            }else{
                print("HealthKit authorization denied!")
                print(error?.description ?? "No error")
            }
        }
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: nil, limit: 100, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                if error != nil {
                    // something happened
                    return
                }
                if let result = tmpResult {
                    // do something with my data
                    if let data = DSJSONSerializer.hkSampleQueryResultToJsonData(result){
                        
                        var jsonString = String(data: data as Data, encoding: String.Encoding.utf8)!
                        let answer = DSTaskAnswerRealm()
                        answer.taskName = "DSSleepTask"
                        answer.json = jsonString
                        do{
                            let realm = try Realm()
                            try realm.write{
                                realm.add(answer)
                            }
                        }catch let error as NSError{
                            print(error.localizedDescription)
                        }
                        print("--")
                        print(jsonString)
                        print("Conversion in progress")
                    }
                    for item in result {
                        
                        if let sample = item as? HKCategorySample {
                            let value = (sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue) ? "InBed" : "Asleep"
                            //print("Healthkit sleep: \(sample.startDate) \(sample.endDate) - value: \(value)")
                            //print("Task Ready")
                            
                        }
                    }
                }
                
                
//                var jsonString = ""
//                if let data = DSJSONSerializer.taskResultToJsonData(taskViewController.result){
//                    jsonString = String(data: data as Data, encoding: String.Encoding.utf8)!
//                    let answer = DSTaskAnswerRealm()
//                    answer.taskName = (taskViewController.task?.identifier)!
//                    DSUtils.updateUserDefaultsFor(self.task)
//                    if let taskListVC = self.parentViewController as? DSTaskListViewController{
//                        taskListVC.tableView.reloadData()
//                    }
//                    answer.json = jsonString
//                    do{
//                        let realm = try Realm()
//                        try realm.write{
//                            realm.add(answer)
//                            self.taskViewControllerInstance.dismiss(animated: true, completion: nil)
//                        }
//                    }catch let error as NSError{
//                        print(error.localizedDescription)
//                    }
//                }
                
             }
            
            // finally, we execute our query
            healthStore.execute(query)
        }
        
    }
    
    //Should be called on the first viewController that appear
    func configureTabBar(){
        //use this array to add news selectedIamges whem you add a new tab.
        if let tabBarController = self.window?.rootViewController as? UITabBarController{
            let tab = tabBarController.tabBar
            let tabBarImages = [
                0:["activities", "tabSelectedActivities"],
                1:["dashboard", "tabSelectedDash"],
                2:["learn", "tabSelectedLearn"],
                3:["settings", "tabSelectedSettings"]
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
            print((tab.selectedViewController as! UINavigationController).topViewController as Any)
            if let vc = ((tab.selectedViewController as! UINavigationController).topViewController) as? DSTaskListViewController{
                vc.restoreUserActivityState(userActivity)
                return true
            }
        }
        return false
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        print(notification.userInfo?.description ?? "Notification msg")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureAppearance()
        initApp()
        
        //---Grab Keys from Keys.plist
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            
            let parseApplicationId = dict["parseApplicationId"] as? String
            let parseClientKey = dict["parseClientKey"] as? String
            let bugLifeApplicationId = dict["BuglifeAPIKey"] as? String
            let parseURL = dict ["parseURL"] as? String
  
            //----Buglife setup
            Buglife.shared().start(withAPIKey: bugLifeApplicationId!)
            //Buglife.shared().invocationOptions = .floatingButton
            Buglife.shared().invocationOptions = .screenshot
            //----end Buglife setup
            
            //---AWS Parse Server
            let configuration = ParseClientConfiguration {
                $0.applicationId = parseApplicationId
                $0.clientKey = parseClientKey
                $0.server = parseURL!
            }
            Parse.initialize(with: configuration)
            //---end AWS Parse Server

         }

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
