//
//  DSTaskListViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit
import Parse
import CoreData
import CloudKit

@available(iOS 10.0, *)
class DSTaskListViewController: UIViewController{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var tableView: UITableView!
    let taskController:DSTaskController = DSTaskController()
    var sectionLabel = UILabel()
    var completedTasks = [DSTask]()
    var uncompletedTasks = [DSTask]()
    var ondemandTasks = [DSTask]()
    var healthKitTasks = [DSTask]()
    var hideTasks = [DSTask]()
    var tasksCount = 0
    
//    private func fetchUserRecord(recordID: CKRecordID) {
//        // Fetch Default Container
//        let defaultContainer = CKContainer.default()
//
//        // Fetch Private Database
//        let privateDatabase = defaultContainer.privateCloudDatabase
//
//        // Fetch User Record
//        privateDatabase.fetch(withRecordID: recordID) { (record, error) -> Void in
//            if let responseError = error {
//                print(responseError)
//
//            } else if let userRecord = record {
//                print(userRecord)
//            }
//        }
//    }
//
//    private func fetchUserRecordID() {
//        // Fetch Default Container
//        let defaultContainer = CKContainer.default()
//
//        // Fetch User Record
//        defaultContainer.fetchUserRecordID { (recordID, error) -> Void in
//            if let responseError = error {
//                print(responseError)
//
//            } else if let userRecordID = recordID {
//                DispatchQueue.main.sync {
//                    self.fetchUserRecord(recordID: userRecordID)
//                }
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        UIApplication.shared.statusBarStyle = .default
        
        // Fetch User Record ID
        //fetchUserRecordID()
        
        
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTasksStatus()
        
        if let tab = self.tabBarController{
            tab.tabBar.items![0].badgeValue = (uncompletedTasks.count == 0 ?  nil : String(uncompletedTasks.count))
        }
    }
    
    func updateTasksStatus(){
        //tasksCount = tasks.filter({$2 != -1}).count
        completedTasks.removeAll()
        uncompletedTasks.removeAll()
        ondemandTasks.removeAll()
        hideTasks.removeAll()
        for task in tasks{
            if task.status == true{
                if task.type == "Survey"{
                    if task.isComplete(){
                        if (task.frequencyNumber.intValue == 0){
                            ondemandTasks += [task]
                        }else{
                            completedTasks += [task]
                        }
                    }else{
                        uncompletedTasks += [task]
                    }
                }else{
                    healthKitTasks += [task]
                }
            }else{
                hideTasks += [task]
            }
            
        }
        tasksCount = ondemandTasks.count + completedTasks.count + uncompletedTasks.count
        
        self.tableView.reloadData()
    }
    
    func configureCellForTask(task: DSTask, cell:UITableViewCell){
        cell.textLabel?.text = task.name
        //print("Configure Task ",task.name," with Id: ",task.taskId)
        let userDefaults = UserDefaults.standard
        var numberOfTasksCompletedes: Any? = nil
        
        var tasksCompleted = 0
        
        if let taskDic = userDefaults.object(forKey: task.taskId) as? [String:AnyObject] {
            numberOfTasksCompletedes = taskDic[PlistFile.Task.FrequencyNumber.rawValue] as! Int
            if numberOfTasksCompletedes as! Int  == 0 {
                numberOfTasksCompletedes = nil
            }else{
                numberOfTasksCompletedes = taskDic[PlistFile.Task.FrequencyNumber.rawValue]?.description
            }
        }
        
        //Core Data Check Number of Activity for the Frequency
        do{
            //Core Data
            let context = self.appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer")
            let nameOfTaskPredicate = NSPredicate(format: "taskName = %@", task.taskId)
            
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.local
            
            
            switch(task.frequencyType){
            case Frequency.Daily.Key.rawValue:
                let dateFrom = calendar.startOfDay(for: Date())
                let numberOfTaskToday = NSPredicate(format: "date >= %@", dateFrom as NSDate)
                fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [nameOfTaskPredicate,numberOfTaskToday])
            case Frequency.Weekly.Key.rawValue:
                let dateFrom = calendar.startOfDay(for: Date(timeIntervalSinceNow: 3600*24*7))
                let numberOfTaskToday = NSPredicate(format: "date >= %@", dateFrom as NSDate)
                fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [nameOfTaskPredicate,numberOfTaskToday])
            case Frequency.Monthly.Key.rawValue:
                let dateFrom = calendar.startOfDay(for: Date(timeIntervalSinceNow: 3600*24*31))
                let numberOfTaskToday = NSPredicate(format: "date >= %@", dateFrom as NSDate)
                fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [nameOfTaskPredicate,numberOfTaskToday])
            default:
                fetchRequest.predicate = NSPredicate(format: "date > %@", Date() as NSDate)
            }
            
            do {
                let resultsOfDuration = try context.fetch(fetchRequest)
                //print("NB of Tasks today: ", resultsOfDuration.count)
                    if resultsOfDuration.count as! Int  == 0 {
                        numberOfTasksCompletedes = nil
                    }else{
                        numberOfTasksCompletedes = resultsOfDuration.count.description
                    }
                }catch{
                print("Error counting Predicate")
                }
            
            }catch let error as NSError{
            
            print(error.localizedDescription)
            return
            
        }
        //---
        
        //let nbTasksCompleted = tasksCompleted as! String ?? NSLocalizedString("No tasks", comment: "")
        let nbTasksCompleted = numberOfTasksCompletedes ?? NSLocalizedString("No tasks", comment: "")
        var detailLabel:String!
        
            switch(task.frequencyType){
            case Frequency.Daily.Key.rawValue:
                detailLabel = (nbTasksCompleted as! String) + " " + NSLocalizedString("of", comment: "") + " " + (task.frequencyNumber.description) + " " + NSLocalizedString("for today", comment: "")
            case Frequency.Weekly.Key.rawValue:
                detailLabel = (nbTasksCompleted as! String) + NSLocalizedString("of", comment: "") + (task.frequencyNumber.stringValue) + NSLocalizedString("for this week", comment: "")
            case Frequency.Monthly.Key.rawValue:
                detailLabel = (nbTasksCompleted as! String) + NSLocalizedString("of", comment: "") + (task.frequencyNumber.stringValue) + NSLocalizedString("for this month", comment: "")
            default:
                detailLabel = NSLocalizedString("Fill this in as needed", comment: "")
            }
        
        cell.detailTextLabel?.text = detailLabel
        
        var color:UIColor!
        if (numberOfTasksCompletedes != nil && ((numberOfTasksCompletedes as AnyObject).integerValue)! >= task.frequencyNumber.intValue) && (task.frequencyType != Frequency.OnDemand.rawValue) {
            color = .greenColorDarker()
            cell.imageView?.image = UIImage(named: "OvalChecked")
        } else {
            color = .purple
            if (task.frequencyNumber.intValue == 0){
                cell.imageView?.image = nil
                color = .lightOrangeColor()
            }else{
                cell.imageView?.image = UIImage(named: "OvalNotSelected")
            }
        }
        
        createSideViewForCell(cell, withColor: color)
    }
    
    func moveSubviews(view:UIView, x:CGFloat, y:CGFloat){
        view.subviews.forEach { (element) -> () in
            if element.subviews.count > 0{
                moveSubviews(view: element, x: x, y: y)
            } else {
                element.center = CGPoint(x: element.center.x + x, y: element.center.y + y)
            }
        }
    }
}

// MARK: - TableViewDataSource
@available(iOS 10.0, *)
extension DSTaskListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasksCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == 0) ? sectionLabel : nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if(section == tableView.numberOfSections - 1 - ondemandTasks.count){
            return NSLocalizedString("On Demand", comment: "")
        }else if (section == tableView.numberOfSections - 1  - ondemandTasks.count - completedTasks.count){
            return NSLocalizedString("Complete", comment: "")
        }else{
            return nil
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd")
            dateFormatter.locale = Locale.current
            
            let now = Date()
            let stringDate = dateFormatter.string(from: now)
            sectionLabel.text = "\(NSLocalizedString("Today", comment: "")), \(now.weekDayString) \(stringDate)\n\(NSLocalizedString("To start an activity tap below", comment: ""))"

            sectionLabel.numberOfLines = 0
            sectionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            sectionLabel.textAlignment = NSTextAlignment.center
            sectionLabel.textColor = UIColor.gray
            //Arrumar a fonte
            sectionLabel.sizeToFit()
            
            return sectionLabel.frame.size.height + 10
            
//        case (tableView.numberOfSections - 1 - completedTasks.count - ondemandTasks.count):
//            return 20
//            
//        case (tableView.numberOfSections - 1 - ondemandTasks.count):
//            return 20

        default:
            return 0.5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kTaskCellReuseIdentifier = "TaskCell"
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: kTaskCellReuseIdentifier)
        if indexPath.section < uncompletedTasks.count{
            configureCellForTask(task: uncompletedTasks[indexPath.section], cell: cell)
        }else if(indexPath.section < completedTasks.count + uncompletedTasks.count){
            configureCellForTask(task: completedTasks[indexPath.section - uncompletedTasks.count], cell: cell)
        }else if(indexPath.section < tasksCount){
            configureCellForTask(task: ondemandTasks[indexPath.section - uncompletedTasks.count - completedTasks.count], cell: cell)
        }else{
            //            cell.textLabel?.text = "Sensor Data Query"
            //            cell.detailTextLabel?.text = "This task is used to retrive data from watch"
            //            createSideViewForCell(cell, withColor: .lightOrangeColor())
        }
        return cell
    }
}

// MARK: - TableViewDelegate
@available(iOS 10.0, *)
extension DSTaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        var task: DSTask? = nil
        if indexPath.section < uncompletedTasks.count{
            task = uncompletedTasks[indexPath.section]
        }else if(indexPath.section < completedTasks.count + uncompletedTasks.count){
            task = completedTasks[indexPath.section - uncompletedTasks.count]
        }else if(indexPath.section < tasksCount){
            task = ondemandTasks[indexPath.section - uncompletedTasks.count - completedTasks.count]
        }else{
            //            let storyboard = UIStoryboard(name: "SensorDataTask", bundle: NSBundle.mainBundle())
            //            let viewController = storyboard.instantiateInitialViewController()
            //            self.presentViewController(viewController!, animated: true, completion: nil)
        }
        if task != nil{
            if let path = Bundle.main.path(forResource: task!.file, ofType: "plist") {
                if let taskDict = NSDictionary(contentsOfFile: path){
                    self.taskController.task = task
                    self.taskController.createTaskWithDictionary(taskDict, andParentViewController: self, willShowTask: true)
                }
            }
        }
    }
}
