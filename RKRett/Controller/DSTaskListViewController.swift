//
//  DSTaskListViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

class DSTaskListViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    let taskController:DSTaskController = DSTaskController()
    var sectionLabel = UILabel()
    var completedTasks = [DSTask]()
    var uncompletedTasks = [DSTask]()
    var ondemandTasks = [DSTask]()
    var tasksCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -69, 0)
        UIApplication.sharedApplication().statusBarStyle = .Default
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateTasksStatus()
        if let tab = self.tabBarController{
            tab.tabBar.items![0].badgeValue = (uncompletedTasks.count == 0 ?  nil : String(uncompletedTasks.count))
        }
    }
    
    func updateTasksStatus(){
        tasksCount = tasks.count
        completedTasks.removeAll()
        uncompletedTasks.removeAll()
        ondemandTasks.removeAll()
        for task in tasks{
            if task.isComplete(){
                if (task.frequencyNumber.integerValue == 0){
                    ondemandTasks += [task]
                }else{
                    completedTasks += [task]
                }
            }else{
                uncompletedTasks += [task]
            }
        }
        self.tableView.reloadData()
    }
    
    func configureCellForTask(task: DSTask, cell:UITableViewCell){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var numberOfTasksCompletedes:AnyObject!
        cell.textLabel?.text = task.name
        
        if let taskDic = userDefaults.objectForKey(task.taskId) as? [String:AnyObject]{
            numberOfTasksCompletedes = (taskDic[PlistFile.Task.FrequencyNumber.rawValue] as! Int == 0) ? nil : taskDic[PlistFile.Task.FrequencyNumber.rawValue]
        } else {
            numberOfTasksCompletedes = nil
        }
        
        if let tasksCompleted = (numberOfTasksCompletedes != nil) ? numberOfTasksCompletedes : NSLocalizedString("No tasks", comment: ""){
            var detailLabel:String!
            switch(task.frequencyType){
            case Frequency.Daily.Key.rawValue:
                detailLabel = "\(tasksCompleted) " + NSLocalizedString("of", comment:"") + " \(task.frequencyNumber) " + NSLocalizedString("for today", comment:"")
                
            case Frequency.Weekly.Key.rawValue:
                detailLabel = (tasksCompleted as! String) + NSLocalizedString("of", comment: "") + (task.frequencyNumber.stringValue) + NSLocalizedString("for this week", comment: "")
                
            case Frequency.Monthly.Key.rawValue:
                detailLabel = (tasksCompleted as! String) + NSLocalizedString("of", comment: "") + (task.frequencyNumber.stringValue) + NSLocalizedString("for this month", comment: "")
                
            default:
                detailLabel = NSLocalizedString("Fill this in as needed", comment: "")
            }
            
            cell.detailTextLabel?.text = detailLabel
            
            var color:UIColor!
            if(numberOfTasksCompletedes?.integerValue >= task.frequencyNumber.integerValue) && (task.frequencyType != Frequency.OnDemand.rawValue){
                color = .greenColorDarker()
                cell.imageView?.image = UIImage(named: "OvalChecked")
            }else{
                color = .purpleColor()
                if (task.frequencyNumber.integerValue == 0){
                    cell.imageView?.image = nil
                    color = .lightOrangeColor()
                }else{
                    cell.imageView?.image = UIImage(named: "OvalNotSelected")
                }
            }
            createSideViewForCell(cell, withColor: color)
        } else {
            print("TASK: \(task.name) completed: \(numberOfTasksCompletedes)")
        }
    }
    
    func moveSubviews(view:UIView, x:CGFloat, y:CGFloat){
        view.subviews.forEach { (element) -> () in
            if element.subviews.count > 0{
                moveSubviews(element, x: x, y: y)
            }else{
                element.center = CGPointMake(element.center.x + x, element.center.y + y)
            }
        }
    }
}

// MARK: - TableViewDataSource
extension DSTaskListViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tasksCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return (section == 0) ? sectionLabel : nil
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == tableView.numberOfSections - ondemandTasks.count){
            return NSLocalizedString("On Demand", comment: "")
        }else if (section == tableView.numberOfSections - ondemandTasks.count - completedTasks.count){
            return NSLocalizedString("Complete", comment: "")
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section{
        case 0:
            let now = NSDate()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM dd")
            dateFormatter.locale = NSLocale.currentLocale()
            let stringDate = dateFormatter.stringFromDate(now)
            
            sectionLabel.text = NSLocalizedString("Today", comment: "") + ", \(now.weekDayString), \(stringDate)\n" + NSLocalizedString("To start an activity tap below", comment: "")
            sectionLabel.numberOfLines = 0
            sectionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            sectionLabel.textAlignment = NSTextAlignment.Center
            sectionLabel.textColor = UIColor.grayColor()
            //Arrumar a fonte
            sectionLabel.sizeToFit()
            
            return sectionLabel.frame.size.height+10
        case (tableView.numberOfSections - completedTasks.count - ondemandTasks.count):
            return 20
        case (tableView.numberOfSections - ondemandTasks.count):
            return 20
        default:
            return 0.5
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let kTaskCellReuseIdentifier = "TaskCell"
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: kTaskCellReuseIdentifier)
        if indexPath.section < uncompletedTasks.count{
            configureCellForTask(uncompletedTasks[indexPath.section], cell: cell)
        }else if(indexPath.section < completedTasks.count + uncompletedTasks.count){
            configureCellForTask(completedTasks[indexPath.section - uncompletedTasks.count], cell: cell)
        }else if(indexPath.section < tasksCount){
            configureCellForTask(ondemandTasks[indexPath.section - uncompletedTasks.count - completedTasks.count], cell: cell)
        }else{
//            cell.textLabel?.text = "Sensor Data Query"
//            cell.detailTextLabel?.text = "This task is used to retrive data from watch"
//            createSideViewForCell(cell, withColor: .lightOrangeColor())
        }
        return cell
    }
}

// MARK: - TableViewDelegate
extension DSTaskListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            if let path = NSBundle.mainBundle().pathForResource(task!.file, ofType: "plist") {
                if let taskDict = NSDictionary(contentsOfFile: path){
                    self.taskController.task = task
                    self.taskController.createTaskWithDictionary(taskDict, andParentViewController: self, willShowTask: true)
                }
            }
        }
    }
}