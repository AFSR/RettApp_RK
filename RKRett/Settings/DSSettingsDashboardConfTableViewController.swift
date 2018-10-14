//
//  DSSettingsDashboardConfTableViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 02/05/18.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit


class DSSettingsDashboardConfTableViewController: UIViewController {
    
    var dashboardList:[[(String,String,Bool,DSTask)]] = [[]]
    var manualTaskList:[(String,String,Bool,DSTask)] = []
    var healthAppTaskList:[(String,String,Bool,DSTask)] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func changeStatus(_ section: Int, _ index: Int, _ status: Bool){
        dashboardList[section][index].3.status = status
        dashboardList[section][index].3.writeProperties()
    }
    
    func getDashBoardList(){
        
        dashboardList.removeAll()
        manualTaskList.removeAll()
        healthAppTaskList.removeAll()
        
        for task in appDelegate.appTasks{
            if task.type == "Survey" {
                manualTaskList.append((task.name, task.taskId, task.status, task))
            }else{
                healthAppTaskList.append((task.name, task.taskId, task.status, task))
            }
        }
        
        dashboardList.append(manualTaskList)
        dashboardList.append(healthAppTaskList)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getDashBoardList()
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
}

extension DSSettingsDashboardConfTableViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Hide") { (action, indexPath) in
            //Set status to false to hide the task
            //self.changeStatus(indexPath.section, indexPath.row, false)
            self.dashboardList[indexPath.section][indexPath.row].3.status = false
            self.dashboardList[indexPath.section][indexPath.row].3.writeProperties()
            self.getDashBoardList()
            tableView.reloadData()
            print("Hide index:",indexPath)
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Show") { (action, indexPath) in
            //Set status to true to show the task
            self.changeStatus(indexPath.section, indexPath.row, true)
            self.getDashBoardList()
            tableView.reloadData()
            print("Show:",indexPath)
        }
        
        share.backgroundColor = UIColor.greenColorDarker()
        
        return [delete, share]
    }
    
}

extension DSSettingsDashboardConfTableViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dashboardList[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Manual Task"
        }else{
            return "Health App"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier:"Cell")
        cell.textLabel?.text = dashboardList[indexPath.section][indexPath.row].3.name
        if indexPath.section == 0 {
            cell.detailTextLabel?.text = "Task"
        }else{
            cell.detailTextLabel?.text = "HealthApp"
        }
        if dashboardList[indexPath.section][indexPath.row].3.status == false {
            cell.textLabel?.isEnabled = false
            cell.detailTextLabel?.isEnabled = false
        }else{
            cell.textLabel?.isEnabled = true
            cell.detailTextLabel?.isEnabled = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print(sourceIndexPath,"->",destinationIndexPath)
        
//        let dashboardListPlistPath = Bundle.main.path(forResource: kDSTasksListFileName, ofType: "plist")
//        let dashboardListFromPlist = NSMutableArray(contentsOfFile: dashboardListPlistPath!)
//
//        for task in appDelegate.appTasks{
//            if task.type == "Survey" {
//                manualTaskList.append((task.name, task.taskId, task.status, task))
//            }else{
//                healthAppTaskList.append((task.name, task.taskId, task.status, task))
//            }
//        }
//
//        let source = dashboardListFromPlist![sourceIndexPath.row]
//        dashboardListFromPlist?.removeObject(at: sourceIndexPath.row)
//        dashboardListFromPlist?.insert(source, at: destinationIndexPath.row)
//
//        dashboardListFromPlist?.write(toFile: dashboardListPlistPath!, atomically: true)
//
        let source = appDelegate.appTasks[sourceIndexPath.row]
        appDelegate.appTasks.remove(at: sourceIndexPath.row)
        appDelegate.appTasks.insert(source, at: destinationIndexPath.row)
        
        DSTaskController.writeTasks(tasksToWrite: appDelegate.appTasks)
        switch destinationIndexPath.section - sourceIndexPath.section {
            
        case 1:
            //From Manual to Health
            print("M->H",dashboardList[sourceIndexPath.section][sourceIndexPath.row].1)
            dashboardList[sourceIndexPath.section][sourceIndexPath.row].3.type = "HealthKit"
            dashboardList[sourceIndexPath.section][sourceIndexPath.row].3.writeProperties()

        case -1:
            //From Health to  Manual
            print("H->M",dashboardList[destinationIndexPath.section][destinationIndexPath.row].1)
            dashboardList[sourceIndexPath.section][sourceIndexPath.row].3.type = "Survey"
            dashboardList[sourceIndexPath.section][sourceIndexPath.row].3.writeProperties()

        default:
            //No Change
            print("No change in section")
        }
        
        //appDelegate.appTasks = DSTaskController.loadTasks()
        getDashBoardList()
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.setEditing(true, animated: true)

    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableView.setEditing(false, animated: true)
    }
    
}
