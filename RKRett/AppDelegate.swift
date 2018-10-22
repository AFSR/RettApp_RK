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
import UserNotifications


//MARK: - AppDelegate
@UIApplicationMain
class AppDelegate: UIResponder, UNUserNotificationCenterDelegate, UICloudSharingControllerDelegate{
    
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        //
        print(error)
        
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return NSLocalizedString("Tasks results", comment: "")
    }
    
    
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
    
//    func createNotificationForDay(_ day: Int, hour: Int, minute: Int) -> UILocalNotification{
//        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//        var components = DateComponents()
//        components.day = day
//        components.month = Date().month
//        components.year = Date().year
//        components.hour = hour
//        components.minute = minute
//        components.second = 0
//        let date = calendar.date(from: components)
//        let localNotification = UILocalNotification()
//        localNotification.alertAction = NSLocalizedString("Reminder", comment: "")
//        localNotification.alertBody = NSLocalizedString("You have pending tasks, please check the tasks tab", comment: "")
//        localNotification.fireDate = date
//        localNotification.repeatInterval = NSCalendar.Unit.day
//        return localNotification
//    }
    
//    func configureNotifications(){
//        if !isAllTasksCompleted{
//            let notificationExist = (UIApplication.shared.scheduledLocalNotifications!.filter({ $0.fireDate!.isToday() }).count > 0)
//            if !notificationExist{
//                //Create notification for today if its not created
//                UIApplication.shared.scheduleLocalNotification(createNotificationForDay(Date().day, hour: 14, minute: 30))
//            }
//        }else{
//            //Create notification for tomorrow
//            UIApplication.shared.cancelAllLocalNotifications()
//            UIApplication.shared.scheduleLocalNotification(createNotificationForDay(Date().day + 1, hour: 14, minute: 30))
//        }
//
//    }
    
    
    
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
    
    
    
    func checkInitCKData(){
        
        if UserDefaults.standard.value(forKey: "fatherRecordID") == nil {
            
            //Add a fictious father record
            let ckRecordZoneID = CKRecordZone.ID(zoneName: "records", ownerName: CKCurrentUserDefaultName)
            let ckRecordID = CKRecord.ID(recordName: CKRecord(recordType: "TaskAnswer").recordID.recordName, zoneID: ckRecordZoneID)
            let recordToSave = CKRecord(recordType: "TaskAnswer", recordID: ckRecordID)
            
            recordToSave.setValue(Date(timeIntervalSince1970: 0), forKey: "date")
            let createRecord = CKModifyRecordsOperation(recordsToSave: [recordToSave], recordIDsToDelete: [])
            
            //Create records zone
            let zoneRecord = CKRecordZone(zoneName: "records")
            let createZone = CKModifyRecordZonesOperation(recordZonesToSave: [zoneRecord], recordZoneIDsToDelete: [])
            
            createZone.modifyRecordZonesCompletionBlock = { savedZone, _, error in
                if error != nil{
                    print(error)
                }else{
                    UserDefaults.standard.set(true, forKey: "zoneCreated")
                }
                
            }
            self.privateDB.add(createZone)
            
            createRecord.modifyRecordsCompletionBlock = { savedRecord, _, error in
                if error != nil{
                    print(error)
                }else{
                    UserDefaults.standard.set(savedRecord?.first!.recordID.recordName, forKey: "fatherRecordID")
                }
            }
            self.privateDB.add(createRecord)
            
        }
        
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
        
        getCloudKitUUID()
        
        //clearCoreDataRecords()
        
        //clearCloudKitRecords(recordType: "TaskAnswer")
        
        //syncDataCloudKitCoreData2()
        
        if UserDefaults.standard.value(forKey: "Device_uuid") == nil {
            UserDefaults.standard.set(UUID().uuidString, forKey: "Device_uuid")
        }
        
        print("UUID de l'appareil: ", UserDefaults.standard.value(forKey: "Device_uuid") as! String )
        
        checkInitCKData()
        
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
        
        let recordZone = CKRecordZone.init(zoneName: "records")
        
            self.privateDB.perform(query, inZoneWith: recordZone.zoneID, completionHandler: {
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
    
    
    func syncDataCloudKitCoreData2(){
        
        let syncOperationQueue: OperationQueue = OperationQueue()
        syncOperationQueue.maxConcurrentOperationCount = 1
        
        //Fetch last CoreData Record
        //Fetch UUID list from Core Data
        let context = self.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer")
        fetchRequest.predicate = NSPredicate(value: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        var controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        //Looking for record in CD without UUID (never synced)
        //Push CD data found to CK
        
        ///var predicate = NSPredicate(format: "uuid == nil")
        let uuid = UserDefaults.standard.value(forKey: "Device_uuid") as! String
        let predicate = NSPredicate(format: "NOT (%K CONTAINS %@)", "uuid", uuid)
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
            print("Nb of UUID from CD not in CK: ", controller.fetchedObjects?.count.description)
            if controller.fetchedObjects?.count ?? 0 > 0 {
                var tasksToSaveInCK = [CKRecord]()
                var tasksFromCD = [NSManagedObject]()
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
                        let uuid = UserDefaults.standard.value(forKey: "Device_uuid") as! String
                        taskResult.setValue(uuid, forKey: "uuid")
                    }else{
                        let uuid = (taskAnswer.value(forKey: "uuid") as! String) + (UserDefaults.standard.value(forKey: "Device_uuid") as! String)
                        taskResult.setValue(uuid, forKey: "uuid")
                    }
                    tasksFromCD.append(taskAnswer)
                    tasksToSaveInCK.append(taskResult)
                    
                    if tasksToSaveInCK.count > 398{
                        print("Tasks to save: ", tasksToSaveInCK.count)
                        
                        let modifyRecordsOperationIntermediate = CKModifyRecordsOperation(recordsToSave: tasksToSaveInCK, recordIDsToDelete: [])
                        let taskFromCDIntermediate = tasksFromCD
                        
                        modifyRecordsOperationIntermediate.modifyRecordsCompletionBlock = { savedRecordTemp, _, error in
                            if error != nil{
                                print(error)
                            }else{
                                let nbOfRecordSavedTemp = savedRecordTemp?.count as! Int
                                if nbOfRecordSavedTemp == 0 {
                                    print("No record saved")
                                }else{
                                    let uuid = UserDefaults.standard.value(forKey: "Device_uuid") as! String
                                    for i in 0..<nbOfRecordSavedTemp{
                                        print("Record saved ",i," ",savedRecordTemp?[i])
                                        if let uuidToSave = taskFromCDIntermediate[i].value(forKey: "uuid") as! String? {
                                            taskFromCDIntermediate[i].setValue(uuidToSave + uuid, forKey: "uuid")
                                        }else{
                                            taskFromCDIntermediate[i].setValue(uuid, forKey: "uuid")
                                        }
                                    }
                                    do {
                                        try context.save()
                                        print("Successfully updated ", nbOfRecordSavedTemp," in CoreData")
                                    } catch {
                                        // Replace this implementation with code to handle the error appropriately.
                                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                        let nserror = error as NSError
                                        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                    }
                                }
                            }
                            
                        }
                        self.privateDB.add(modifyRecordsOperationIntermediate)
                        tasksToSaveInCK.removeAll()
                        tasksFromCD.removeAll()
                    }
                    
                }
                
                print("Tasks to save: ", tasksToSaveInCK.count)
                
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
                                print("Record saved ",i," ",savedRecord?[i])
                            }
                        }
                    }
                    
                }
                self.privateDB.add(modifyRecordsOperation)
                
            }
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
        
        print("End of local to remote sync process")
    }
    
    
    func syncDataFromCK(){
        print("Data changed from remote server")
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
        
        UserDefaults.standard.set(nil, forKey: "fatherRecordID")
        UserDefaults.standard.set(nil, forKey: "zoneCreated")
        
        print("All remote data successfully deleted")
    }
    
    func clearCoreDataRecords(){
        
        // Code in this block will trigger when OK button tapped.
        //Delete all local data
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let deleteTaskAnswer = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer"))
        let deleteTreatment = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "Treatment"))
        
        do {
            try managedContext.execute(deleteTaskAnswer)
        }
        catch {
            print(error)
        }
        
        do {
            try managedContext.execute(deleteTreatment)
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
    
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
      
        let acceptShareOperation: CKAcceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        
        acceptShareOperation.qualityOfService = .userInteractive
        acceptShareOperation.perShareCompletionBlock = {meta, share,
            error in
            print("share was accepted")
        }
        acceptShareOperation.acceptSharesCompletionBlock = {
            error in
            /// Send your user to where they need to go in your app
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptShareOperation)
        
    }
    
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("Register for remote notifications")
        let subscription = CKQuerySubscription(recordType: "TaskAnswer", predicate: NSPredicate(format: "TRUEPREDICATE"), options: .firesOnRecordCreation)
        
        let info = CKSubscription.NotificationInfo()
        info.alertBody = "A new notification has been posted!"
        info.shouldBadge = true
        info.soundName = "default"
        
        subscription.notificationInfo = info
        
        privateDB.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                // Subscription saved successfully
            } else {
                // An error occurred
            }
        })
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configureAppearance()
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
            if authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        })
        
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
    

         }
    
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Whenever there's a remote notification, this gets called
        let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
        print("Notification: ",notification.subscriptionID?.description)
        print(notification.alertBody)
        
        
        if (notification.subscriptionID == (UserDefaults.standard.value(forKey: "subscriptionID") as! String) ) {
            // fetchChanges is a local function used for fetching the modified records from CloudKit
            if notification.notificationType == .query{
                let queryNotification = notification as? CKQueryNotification
                let recordID = queryNotification?.recordID
                
                if recordID != nil {
                    privateDB.fetch(withRecordID: recordID!, completionHandler: { (record, error) -> Void in
                        guard let record = record else {
                            print("Error fetching record: ", error)
                            return
                        }
                        
                        let context = self.persistentContainer.viewContext
                        
                        let data = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "TaskAnswer", in: context)!, insertInto: context)
                        
                        
                        data.setValue( (record.value(forKey: "taskName") as! String) , forKey: "taskName")
                        data.setValue( (record.value(forKey: "json") as! String), forKey: "json")
                        
                        var date = record.value(forKey: "date")
                        if date == nil {
                            date = Date() as NSDate
                        }
                        data.setValue( date as! NSDate, forKey: "date")
                        
                        if record.value(forKey: "uuid") == nil{
                            let uuid = UserDefaults.standard.value(forKey: "Device_uuid") as! String
                            data.setValue(uuid, forKey: "uuid")
                        }else{
                            let uuid = (record.value(forKey: "uuid") as! String) + (UserDefaults.standard.value(forKey: "Device_uuid") as! String)
                            data.setValue(uuid, forKey: "uuid")
                        }
                        
                        do {
                            try data.validateForInsert()
                        } catch {
                            print(error)
                        }
                        print(data.description)
                        
                        do {
                            try context.save()
                            print("Successfully saved record in CoreData")
                        } catch {
                            // Replace this implementation with code to handle the error appropriately.
                            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                            let nserror = error as NSError
                            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                        }
                        
                    })
                }
            }
        }
        completionHandler(UIBackgroundFetchResult.noData)
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
        syncDataCloudKitCoreData2()
    }

    func applicationSignificantTimeChange(_ application: UIApplication) {
        DSUtils.resetUserDefaults()
    }
}
