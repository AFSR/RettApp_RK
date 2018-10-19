//
//  AppDelegate.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/19/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

// How to document:
// http://nshipster.com/swift-documentation/


import SVProgressHUD
import UIKit
import Buglife
import CoreData
import DeviceCheck
import CloudKit


//MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder {
    
    var window: UIWindow?
    let kTagForViewDidEnterBackground = 99
    
    var appTasks : [DSTask] = DSTaskController.loadTasks()
    
    var appTasksGlobalList:[[DSTask]] = [[]]
    
    let olderHKSyncDate:Date = Date(timeIntervalSince1970: 1.0)
    var lastHKSync:Date = Date()
    
    var healthManager = HealthManager()
    let healthStore = HKHealthStore()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //CoreData
    let moc = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    
    func getTask(taskID:String)->DSTask{
        for task in appTasks{
            if task.taskId == taskID {
                //print(taskID)
                return task
            }
        }
        return DSTask(plistFileName: "DSMoodTask")
    }
    
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
    
    
    
    func getCloudKitUUID(){
        
        var uuidListCK = [String]()
        
        var predicate = NSPredicate()
        predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "TaskAnswer", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var queryOperation = CKQueryOperation(query: query)
        
        let networkQueue = DispatchQueue(label: "NetworkQueue", qos: .userInitiated)
        
        queryOperation.recordFetchedBlock = { record in
            if let uuid = record.value(forKey: "uuid") {
                uuidListCK.append(uuid as! String)
            }
        }
        
        queryOperation.queryCompletionBlock = { [weak self] (cursor, error) in
            if cursor != nil{
                let newOperation = CKQueryOperation(cursor: cursor!)
                newOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                newOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                newOperation.qualityOfService = .userInitiated
                queryOperation = newOperation
                
                self?.privateDB.add(queryOperation)
            }else{
                print("Cursor=nil")
            }
        }
        
        queryOperation.qualityOfService = .userInitiated
        
        networkQueue.sync {
            self.privateDB.add(queryOperation)
        }
        
        print("UUID[CK]:",uuidListCK)
        
    }
    
    
    
    func initApp(){
        if(alreadyParticipating){
            gotoStoryboard(StoryboardName.Password.rawValue)
            populateDashboardWithHealthData()
        } else {
            gotoStoryboard(StoryboardName.Consent.rawValue)
            do{
                try ORKKeychainWrapper.removeObject(forKey: kDSPasswordKey)
            }catch{
                print("Error:",error)
            }
            
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        getCloudKitUUID()
        
        //clearCoreDataRecords()
        
        //clearCloudKitRecords(recordType: "TaskAnswer")
        
        //syncDataCloudKitCoreData()
        
        
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
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
        
        UILabel.appearance().tintColor = .purple
        UIButton.appearance().tintColor = .purple
        UITabBar.appearance().tintColor = .purple
    }
    
    func syncDataCloudKitCoreData(){
        
        let syncOperationQueue: OperationQueue = OperationQueue()
        syncOperationQueue.maxConcurrentOperationCount = 1
        
        //General Vars
        var nbRecordsCloudKit = 0
        var nbRecordsCoreData = 0
        
        //Fetch last CoreData Record
        //Fetch UUID list from Core Data
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer")
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var uuidListCD : [String] = []
        var uuidListCK : [String] = []
        
        var controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try controller.performFetch()
            nbRecordsCoreData = controller.fetchedObjects?.count ?? 0
            if controller.fetchedObjects?.count ?? 0 > 0 {
                for record in controller.fetchedObjects as! [NSManagedObject]{
                    if record.value(forKey: "uuid") != nil{
                        let uuid = (record.value(forKey: "uuid") as! String) ?? ""
                        uuidListCD.append(uuid)
                    }
                }
                print("[CDUUID]",nbRecordsCoreData.description,":",uuidListCD)
            }
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
            
        
        //Fetch UUID List from CloudKit
        var predicate = NSPredicate()
        predicate = NSPredicate(value: true)
    
        var query = CKQuery(recordType: "TaskAnswer", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        syncOperationQueue.addOperation {
            
            var queryOperation = CKQueryOperation(query: query)
            queryOperation.resultsLimit = 100
            
            queryOperation.recordFetchedBlock = { record in
                if let uuid = record.value(forKey: "uuid") {
                    uuidListCK.append(uuid as! String)
                }
            }
            
            queryOperation.queryCompletionBlock = { [weak self] (cursor, error) in
                if cursor != nil{
                    let newOperation = CKQueryOperation(cursor: cursor!)
                    newOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
                    newOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                    newOperation.resultsLimit = queryOperation.resultsLimit
                    
                    queryOperation = newOperation
                    
                    self?.privateDB.add(queryOperation)
                }
            }
            
            self.privateDB.add(queryOperation)
            
        }
        
        syncOperationQueue.addOperation {
            nbRecordsCloudKit = uuidListCK.count
            print("[CKUUID]",nbRecordsCloudKit.description,":",uuidListCK)
        }
    
        
        //Looking for UUID from CD which are not in CK
        //Push CD data found to CK
        if uuidListCK == []{
            predicate = NSPredicate(value: true)
        }else{
            predicate = NSPredicate(format: "NOT (uuid IN %@)", uuidListCK)
        }
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
            nbRecordsCoreData = controller.fetchedObjects?.count ?? 0
            print("Nb of UUID from CD not in CK: ",controller.fetchedObjects?.count.description)
            if controller.fetchedObjects?.count ?? 0 > 0 {
                var tasksToSaveInCK = [CKRecord]()
                for taskAnswer in controller.fetchedObjects as! [NSManagedObject]{
                    
                    let taskResult = CKRecord(recordType: "TaskAnswer")
                    var date = taskAnswer.value(forKey: "date")
                    if date == nil {
                        date = Date() as NSDate
                    }
                    taskResult.setValue( date as! NSDate, forKey: "date")
                    taskResult.setValue((taskAnswer.value(forKey: "json") as! String), forKey: "json")
                    taskResult.setValue((taskAnswer.value(forKey: "taskName") as! String), forKey: "taskName")
                    if taskAnswer.value(forKey: "uuid") == nil{
                        let uuid = UUID().uuidString
                        taskResult.setValue(uuid, forKey: "uuid")
                    }else{
                        taskResult.setValue((taskAnswer.value(forKey: "uuid") as! String), forKey: "uuid")
                    }
                    
                    tasksToSaveInCK.append(taskResult)
                    
                }
                
                print("Tasks to save:", tasksToSaveInCK)
                
                
                syncOperationQueue.addOperation {
                    let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: tasksToSaveInCK, recordIDsToDelete: [])
                    
                    modifyRecordsOperation.modifyRecordsCompletionBlock = { savedRecord, _, error in
                        if error != nil{
                            print(error)
                        }else{
                            let nbOfRecordSaved = savedRecord?.count as! Int
                            if nbOfRecordSaved == 0 {
                                print("No record saved")
                            }else{
                                for i in 0..<nbOfRecordSaved{
                                    print("Record ",i," ",savedRecord?[i])
                                }
                            }
                        }
                        
                    }
                    self.privateDB.add(modifyRecordsOperation)
                }
                
            }
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
            
            //Looking for UUID from CK which are not in CD
            //Pulling data found from CK to CD
            if uuidListCK == []{
                predicate = NSPredicate(value: true)
            }else{
                predicate = NSPredicate(format: "NOT (uuid IN %@)", uuidListCD)
            }
            predicate = NSPredicate(format: "NOT (uuid IN %@)", uuidListCD)
            query = CKQuery(recordType: "TaskAnswer", predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            self.privateDB.perform(query, inZoneWith: nil, completionHandler: {
                (records, error) -> Void in
                guard let records = records else {
                    print("Error querying records: ", error ?? "Error")
                    return
                }
                print("[CKUUID]",uuidListCK.count,":",uuidListCK)
                print("Nb of UUID from CK not in CD: ",records.count.description)
                for taskAnswer in records{
                    let data = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "TaskAnswer", in: context)!, insertInto: context)
                    
                    data.setValue( (taskAnswer.value(forKey: "taskName") as! String) , forKey: "taskName")
                    data.setValue( (taskAnswer.value(forKey: "json") as! String), forKey: "json")
                    var date = taskAnswer.value(forKey: "date")
                    if date == nil {
                        date = Date() as NSDate
                    }
                    data.setValue( date as! NSDate, forKey: "date")
                    if taskAnswer.value(forKey: "uuid") == nil{
                        let uuid = UUID().uuidString
                        data.setValue(uuid, forKey: "uuid")
                    }else{
                        data.setValue((taskAnswer.value(forKey: "uuid") as! String), forKey: "uuid")
                    }
                    do {
                        try data.validateForInsert()
                    } catch {
                        print(error)
                    }
                    print(data.description)
                    do {
                        try context.save()
                        print("Successfully saved record: ", records.count.description," in CoreData")
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nserror = error as NSError
                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                    }
                    
                }
                
            })
//        })

        print("End of sync process")
    }
    
    func clearCloudKitRecords(recordType: String){
        
        var recordIDsArray = [CKRecord.ID]()
        
        var queryOperation = CKQueryOperation(query: CKQuery(recordType: recordType, predicate: NSPredicate(value: true)))

        queryOperation.recordFetchedBlock = { record in
            recordIDsArray.append(record.recordID)
        }

        queryOperation.queryCompletionBlock = { (cursor, error) in
            print("New Operation Completion Block:",cursor?.description)
            if cursor != nil{
                let nextOperation = CKQueryOperation(cursor: cursor!)
                nextOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
                nextOperation.queryCompletionBlock = queryOperation.queryCompletionBlock

                queryOperation = nextOperation

                self.privateDB.add(queryOperation)
                print("New Operation")
            }
        }
        
        OperationQueue.main.addOperation {
            self.privateDB.add(queryOperation)
        }
        
        
        let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDsArray)
        
        modifyRecordsOperation.addDependency(queryOperation)
        
        modifyRecordsOperation.modifyRecordsCompletionBlock = { _, deletedRecord, error in
            if error != nil{
                print(error)
            }else{
                let nbOfRecordDeleted = deletedRecord?.count as! Int
                if nbOfRecordDeleted == 0 {
                    print("No record deleted")
                }else{
                    for i in 0..<nbOfRecordDeleted{
                        print("Record ",i," deleted",deletedRecord?[i])
                    }
                }
            }
            
        }
        OperationQueue.main.addOperation {
            self.privateDB.add(modifyRecordsOperation)
        }
        
//        var queryOperation = CKQueryOperation(query: CKQuery(recordType: recordType, predicate: NSPredicate(value: true)))
//
//        queryOperation.recordFetchedBlock = { record in
//            self.privateDB.delete(withRecordID: record.recordID, completionHandler: {
//                (deletedRecord, error) -> Void in
//                guard let deletedRecord = deletedRecord else{
//                    print("Error querying records: ", error ?? "Error")
//                    return
//                }
//                print("Record deleted",record.recordID)
//            })
//        }
//
//        queryOperation.queryCompletionBlock = { (cursor, error) in
//            print("New Operation Completion Block:",cursor?.description)
//            if cursor != nil{
//                let nextOperation = CKQueryOperation(cursor: cursor!)
//                nextOperation.recordFetchedBlock = queryOperation.recordFetchedBlock
//                nextOperation.queryCompletionBlock = queryOperation.queryCompletionBlock
//
//                queryOperation = nextOperation
//
//                self.privateDB.add(queryOperation)
//                print("New Operation")
//            }
//        }
//
//        self.privateDB.add(queryOperation)
//
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: recordType, predicate: predicate)
//        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//
//        self.privateDB.perform(query, inZoneWith: nil, completionHandler: {
//            (records, error) -> Void in
//            guard let records = records else {
//                print("Error querying records: ", error ?? "Error")
//                return
//            }
//            for record in records{
//                self.privateDB.delete(withRecordID: record.recordID, completionHandler: {
//                    (deletedRecord, error) -> Void in
//                    guard let deletedRecord = deletedRecord else{
//                        print("Error querying records: ", error ?? "Error")
//                        return
//                    }
//                })
//            }
//        })
        print("All remote data successfully deleted")
    }
    
    func clearCoreDataRecords(){
        
        // Code in this block will trigger when OK button tapped.
        //Delete all local data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer"))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
        UserDefaults.standard.set(true, forKey: "localDataDeleted")
        print("All local data successfully deleted")
        
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
                        
                        let data = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "TaskAnswer", in: self.persistentContainer.viewContext)!, insertInto: self.persistentContainer.viewContext)
                        
                        data.setValue("DSSleepTask", forKey: "taskName")
                        data.setValue(jsonString, forKey: "json")
                        do {
                            try data.validateForInsert()
                        } catch {
                            print(error)
                        }
                        self.saveContext()
                        
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
                
             }
            
            // finally, we execute our query
            healthStore.execute(query)
        }
        
    }
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TaskAnswer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        configureAppearance()
        initApp()
        
        persistentContainer.newBackgroundContext()

        //---Grab Keys from Keys.plist
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
  
            //----Buglife setup
            let bugLifeApplicationId = dict["BuglifeAPIKey"] as? String
            Buglife.shared().start(withAPIKey: bugLifeApplicationId!)
            //Buglife.shared().invocationOptions = .floatingButton
            Buglife.shared().invocationOptions = .screenshot
            //----end Buglife setup
            
            //---AWS Parse Server
            //let parseApplicationId = dict["parseApplicationId"] as? String
            //let parseClientKey = dict["parseClientKey"] as? String
            //let parseURL = dict ["parseURL"] as? String
//            let configuration = ParseClientConfiguration {
//                $0.applicationId = parseApplicationId
//                $0.clientKey = parseClientKey
//                $0.server = parseURL!
//            }
            //Parse.initialize(with: configuration)
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
        if UserDefaults.standard.object(forKey: "lastHKSync") != nil{
            //lastHKSync = UserDefaults.standard.object(forKey: "lastHKSync") as! Date
            lastHKSync = olderHKSyncDate
        }else{
            lastHKSync = olderHKSyncDate
        }
        print("Dernière synchronisation avec HK:",lastHKSync)
        healthManager.syncWithHK()
        print("Dernière synchronisation avec HK (upd):",lastHKSync)
    }

    func applicationSignificantTimeChange(_ application: UIApplication) {
        DSUtils.resetUserDefaults()
    }
}
