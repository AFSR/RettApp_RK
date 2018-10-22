//
//  DSTaskViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit
import ResearchKit
import CoreData
import CloudKit

/**
Create and manage a ORKTaskViewController and its results.
*/
@available(iOS 10.0, *)
class DSTaskController: NSObject, UICloudSharingControllerDelegate {
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Fail to share:",error)
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return NSLocalizedString("Tasks results", comment: "")
    }
    
    
    /**
    Holds the UIViewController parent of taskViewControllerInstance.
    */
    var parentViewController: UIViewController!
    
    /**
    Holds the instance of ORKTaskViewController created.
    */
    var taskViewControllerInstance: ORKTaskViewController!
    
    /**
    Holds the instance of DSTask that will be presented by the controller.
    */
    var task:DSTask!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    /**
    Create, and optionally shows, a task.
    
    :warning: Warning description.
    
    - parameter dictionary: `NSDictionary` that contains the data to create the task.
    - parameter parentViewController: `UIViewController` that will be ORKTarkViewController's parent.
    - parameter showTask: (optional) `Bool` that indicates that the task should be shown right after been created.
    
    - returns: `Void`
    */
    func createTaskWithDictionary(_ dictionary:NSDictionary, andParentViewController parentViewController:UIViewController, willShowTask showTask:Bool = false){
        self.parentViewController = parentViewController
        self.taskViewControllerInstance = ORKTaskViewController(task: DSTaskCreator(dictionary), taskRun: nil)
        self.taskViewControllerInstance.delegate = self
        if showTask{
            self.showTask()
        }else{
            print("Parameter 'showTask' is false, you must call showTask() to present the taskViewController")
        }
    }
    
    /**
    Show the task created.
    
    :warning: To use this method you MUST call createTaskWithDictionary(_:andParentViewController:willShowTask:) and the properties parentViewController and taskViewControllerInstance MUST have been initialized.
    
    - returns: `Void`.
    */
    func showTask(){
        let requiredProperties = ["parentViewController", "taskViewControllerInstance"]
        for prop in requiredProperties{
            if self.responds(to: NSSelectorFromString(prop)){
                assert(self.value(forKey: prop) != nil, "You shoud set the property '\(prop)' in DSTaskController in order to show the task")
            }
        }
        self.parentViewController.present(self.taskViewControllerInstance, animated: true, completion: nil)
    }
    
    
    /**
     Write the main plist for tasks in array.
     
     */
    static func writeTasks(tasksToWrite: [DSTask]){
       
        if let path = Bundle.main.path(forResource: kDSTasksListFileName, ofType: "plist") {
            if let taskArray = NSMutableArray(contentsOfFile: path){
                taskArray.removeAllObjects()
                var i = 0
                for task in tasksToWrite{
                    taskArray[i] = task.name
                    i+=1
                }
                taskArray.write(toFile: path, atomically: true)
                print("Tasks written")
            }
        }
    }
    
    
    /**
    Reads the main plist for tasks and creates the models from the tasks plists.
    
    :warning: This method should be called once everytime the app is opened and used to populate a global variable making all the tasks accessible.
    
    - returns: `[DSTask]`.
    */
    static func loadTasks() -> [DSTask]{
        var tasks = [DSTask]()
        //let dashboardListPlistPath = Bundle.main.path(forResource: "DSTasks", ofType: "plist")
        //let dashboardListFromPlist = NSMutableArray(contentsOfFile: dashboardListPlistPath!)
        
        
        if let path = Bundle.main.path(forResource: kDSTasksListFileName, ofType: "plist") {
            if let taskArray = NSArray(contentsOfFile: path){
                for task in taskArray as! [String]{
                    let dsTask = DSTask(plistFileName: task)
                    //if dsTask.type == "Survey"{
                        tasks += [dsTask]
                    //}
                }
            }
        }   
        return tasks
    }
}

//MARK: - ORKTaskViewControllerDelegate
@available(iOS 10.0, *)
extension DSTaskController: ORKTaskViewControllerDelegate {
    /**
     Tells the delegate that the task has finished.
     
     The task view controller calls this method when an unrecoverable error occurs,
     when the user has canceled the task (with or without saving), or when the user
     completes the last step in the task.
     
     In most circumstances, the receiver should dismiss the task view controller
     in response to this method, and may also need to collect and process the results
     of the task.
     
     @param taskViewController  The `ORKTaskViewController `instance that is returning the result.
     @param reason              An `ORKTaskViewControllerFinishReason` value indicating how the user chose to complete the task.
     @param error               If failure occurred, an `NSError` object indicating the reason for the failure. The value of this parameter is `nil` if `result` does not indicate failure.
     */

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        //code
        print("Out of a Task");
        switch(reason){
        case ORKTaskViewControllerFinishReason.completed:
            print("Completed")
            var jsonString = ""
            print(taskViewController.task?.identifier)
            if let data = DSJSONSerializer.taskResultToJsonData(taskViewController.result, taskViewController.task?.identifier as! String){
                jsonString = String(data: data as Data, encoding: String.Encoding.utf8)!
                DSUtils.updateUserDefaultsFor(self.task)
                if let taskListVC = self.parentViewController as? DSTaskListViewController{
                    taskListVC.tableView.reloadData()
                }
                let uuid = UserDefaults.standard.value(forKey: "Device_uuid") as! String
                
                let data = NSManagedObject(entity: NSEntityDescription.entity(forEntityName: "TaskAnswer", in: appDelegate.persistentContainer.viewContext)!, insertInto: appDelegate.persistentContainer.viewContext)
                
                data.setValue((taskViewController.task?.identifier)!, forKey: "taskName")
                data.setValue(jsonString, forKey: "json")
                data.setValue(Date(), forKey: "date")
                data.setValue(uuid, forKey: "uuid")
                
                do {
                    try data.validateForInsert()
                } catch {
                    print(error)
                }
                appDelegate.saveContext()
                
                //Saving process to Cloud Kit
                if (UserDefaults.standard.value(forKey: "zoneCreated") != nil) && (UserDefaults.standard.value(forKey: "zoneCreated") as! Bool){
                    let zone = CKRecordZone(zoneName: "records")
                    let modifyRecordZoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [zone], recordZoneIDsToDelete: nil)
                    modifyRecordZoneOperation.modifyRecordZonesCompletionBlock = { savedRecordZone, _, error in
                        if error != nil{
                            print(error)
                        }
                    }
                    appDelegate.privateDB.add(modifyRecordZoneOperation)
                }
                
                
                
                let ckRecordZoneID = CKRecordZone.ID(zoneName: "records", ownerName: CKCurrentUserDefaultName)
                let ckRecordID = CKRecord.ID(recordName: CKRecord(recordType: "TaskAnswer").recordID.recordName, zoneID: ckRecordZoneID)
                let taskRecord = CKRecord(recordType: "TaskAnswer", recordID: ckRecordID)
                
                print("Father reference:", UserDefaults.standard.value(forKey: "fatherRecordID"))
                print("Zone:", UserDefaults.standard.value(forKey: "zoneCreated"))
                
                if UserDefaults.standard.value(forKey: "fatherRecordID") == nil {
                    appDelegate.checkInitCKData()
                }
                
                let parentTaskName = UserDefaults.standard.value(forKey: "fatherRecordID") as! String
                let fatherRecordZoneID = CKRecordZone.ID(zoneName: "records", ownerName: CKCurrentUserDefaultName)
                let fatherRecordID = CKRecord.ID(recordName: parentTaskName, zoneID: fatherRecordZoneID)
                
                taskRecord.setParent(fatherRecordID)
                
                taskRecord["date"] = data.value(forKey: "date") as! Date
                taskRecord["taskName"] = data.value(forKey: "taskName") as! String
                taskRecord["json"] = data.value(forKey: "json") as! String
                taskRecord["uuid"] = data.value(forKey: "uuid") as! String
                
                let modifyRecordsOperation = CKModifyRecordsOperation(recordsToSave: [taskRecord], recordIDsToDelete: [])
                
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
                appDelegate.privateDB.add(modifyRecordsOperation)
                
            }
            self.taskViewControllerInstance.dismiss(animated: true, completion: nil)
            
        case ORKTaskViewControllerFinishReason.discarded:
            //            print("Discarded")
            self.taskViewControllerInstance.dismiss(animated: true, completion: nil)
            
        case ORKTaskViewControllerFinishReason.failed:
            //            print("Failed: \(error?.localizedDescription)")
            self.taskViewControllerInstance.dismiss(animated: true, completion: nil)
            
        case ORKTaskViewControllerFinishReason.saved:
            //            print("Saved")
            self.taskViewControllerInstance.dismiss(animated: true, completion: nil)
        }
    }
    
    private func taskViewController(_ taskViewController: ORKTaskViewController, recorder: ORKRecorder, didFailWithError error: NSError) {
        print("didFailWithError \(error.localizedDescription)")
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
}
