//
//  DSTaskViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit
import ResearchKit
//import Parse
//import Realm
import RealmSwift

/**
Create and manage a ORKTaskViewController and its results.
*/
class DSTaskController: NSObject {
    
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
    Reads the main plist for tasks and creates the models from the tasks plists.
    
    :warning: This method should be called once everytime the app is opened and used to populate a global variable making all the tasks accessible.
    
    - returns: `[DSTask]`.
    */
    static func loadTasks() -> [DSTask]{
        var tasks = [DSTask]()
        if let path = Bundle.main.path(forResource: kDSTasksListFileName, ofType: "plist") {
            if let surveysArray = NSArray(contentsOfFile: path){
                for survey in surveysArray as! [String]{
                    let dsTask = DSTask(plistFileName: survey)
                    tasks += [dsTask]
                }
            }
        }   
        return tasks
    }
}

//MARK: - ORKTaskViewControllerDelegate
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
        switch(reason){
        case ORKTaskViewControllerFinishReason.completed:
            print("Completed")
            var jsonString = ""
            if let data = DSJSONSerializer.taskResultToJsonData(taskViewController.result){
                jsonString = String(data: data as Data, encoding: String.Encoding.utf8)!
                let answer = DSTaskAnswerRealm()
                answer.taskName = (taskViewController.task?.identifier)!
                DSUtils.updateUserDefaultsFor(self.task)
                if let taskListVC = self.parentViewController as? DSTaskListViewController{
                    taskListVC.tableView.reloadData()
                }
                answer.json = jsonString
                do{
                    let realm = try Realm()
                    try realm.write{
                        realm.add(answer)
                        self.taskViewControllerInstance.dismiss(animated: true, completion: nil)
                    }
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
            
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

  
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        switch(reason){
        case ORKTaskViewControllerFinishReason.completed:
            print("Completed")
            var jsonString = ""
            if let data = DSJSONSerializer.taskResultToJsonData(taskViewController.result){
                jsonString = String(data: data as Data, encoding: String.Encoding.utf8)!
                let answer = DSTaskAnswerRealm()
                answer.taskName = (taskViewController.task?.identifier)!
                DSUtils.updateUserDefaultsFor(self.task)
                if let taskListVC = self.parentViewController as? DSTaskListViewController{
                    taskListVC.tableView.reloadData()
                }
                answer.json = jsonString
                do{
                    let realm = try Realm()
                    try realm.write{
                        realm.add(answer)
                        self.taskViewControllerInstance.dismiss(animated: true, completion: nil)
                    }
                }catch let error as NSError{
                    print(error.localizedDescription)
                }
            }
            
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
    
    func taskViewController(_ taskViewController: ORKTaskViewController, recorder: ORKRecorder, didFailWithError error: NSError) {
        print("didFailWithError \(error.localizedDescription)")
        taskViewController.dismiss(animated: true, completion: nil)
    }
    
}
