//
//  DSSettingsDashboardConfTableViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 02/05/18.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit


class DSSettingsDashboardConfTableViewController: UIViewController {
    
    var dashboardList:[[(String,String,Bool)]] = [[]]
    var manualTaskList:[(String,String,Bool)] = []
    var healthAppTaskList:[(String,String,Bool)] = []
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    func changeStatus(_ section: Int, _ index: Int, _ status: Bool){
        if let taskPath = Bundle.main.path(forResource: (dashboardList[section][index].1), ofType: "plist") {
            if let taskFromPlist = NSMutableDictionary(contentsOfFile: taskPath){
                taskFromPlist.setValue(status, forKeyPath: "status")
                taskFromPlist.write(toFile: taskPath, atomically: true)
            }
        }
    }
    
    func getDashBoardList(){
        
        dashboardList.removeAll()
        manualTaskList.removeAll()
        healthAppTaskList.removeAll()
        
        if let path = Bundle.main.path(forResource: "DSTasks", ofType: "plist"){
            if let tasks = NSArray(contentsOfFile: path) {
                for taskId in tasks {
                    if let taskPath = Bundle.main.path(forResource: (taskId as! String), ofType: "plist") {
                        if let task = NSDictionary(contentsOfFile: taskPath) {
                            let status =  task["status"] as? Bool
                            if let title = task["name"] {
                                if task["type"] as? String == "Survey" {
                                    manualTaskList.append((title as! String, taskId as! String, status!))
                                }else{
                                    healthAppTaskList.append((title as! String, taskId as! String, status!))
                                }
                            }
                        }
                    }
                }
            }
        }
        dashboardList.append(manualTaskList)
        dashboardList.append(healthAppTaskList)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
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
            self.changeStatus(indexPath.section, indexPath.row, false)
            self.getDashBoardList()
            tableView.reloadData()
            print("Hide:",indexPath)
        }
        
        let share = UITableViewRowAction(style: .normal, title: "Show") { (action, indexPath) in
            //Set status to true to show the task
            self.changeStatus(indexPath.section, indexPath.row, true)
            self.getDashBoardList()
            tableView.reloadData()
            print("Hide:",indexPath)
        }
        
        share.backgroundColor = UIColor.green
        
        return [delete, share]
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {

    }

    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            //Set status to false to hide the task
            if let taskPath = Bundle.main.path(forResource: (dashboardList[indexPath.section][indexPath.row].1), ofType: "plist") {
                if let taskFromPlist = NSMutableDictionary(contentsOfFile: taskPath){
                    taskFromPlist.setValue(false, forKeyPath: "status")
                    taskFromPlist.write(toFile: taskPath, atomically: true)
                }
            }
            getDashBoardList()
            tableView.reloadData()
            print("Hide:",indexPath)
        }
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
        let cell = UITableViewCell(style:UITableViewCellStyle.subtitle, reuseIdentifier:"Cell")
        cell.textLabel?.text = dashboardList[indexPath.section][indexPath.row].0
        if indexPath.section == 0 {
            cell.detailTextLabel?.text = "Task"
        }else{
            cell.detailTextLabel?.text = "HealthApp"
        }
        if dashboardList[indexPath.section][indexPath.row].2 == false {
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
        
        let dashboardListPlistPath = Bundle.main.path(forResource: "DSTasks", ofType: "plist")
        let dashboardListFromPlist = NSMutableArray(contentsOfFile: dashboardListPlistPath!)
        
        let source = dashboardListFromPlist![sourceIndexPath.row]
        dashboardListFromPlist?.removeObject(at: sourceIndexPath.row)
        dashboardListFromPlist?.insert(source, at: destinationIndexPath.row)

        dashboardListFromPlist?.write(toFile: dashboardListPlistPath!, atomically: true)
        
        switch destinationIndexPath.section - sourceIndexPath.section {
        case 1:
            //From Manual to Health
            print("M->H",dashboardList[sourceIndexPath.section][sourceIndexPath.row].1)
            if let taskPath = Bundle.main.path(forResource: (dashboardList[sourceIndexPath.section][sourceIndexPath.row].1), ofType: "plist") {
                if let taskFromPlist = NSMutableDictionary(contentsOfFile: taskPath){
                    taskFromPlist.setValue("HealthKit", forKeyPath: "type")
                    taskFromPlist.write(toFile: taskPath, atomically: true)
                }
            }
        case -1:
            //From Health to  Manual
            print("H->M",dashboardList[destinationIndexPath.section][destinationIndexPath.row].1)
            if let taskPath = Bundle.main.path(forResource: (dashboardList[destinationIndexPath.section][destinationIndexPath.row].1), ofType: "plist") {
                if let taskFromPlist = NSMutableDictionary(contentsOfFile: taskPath){
                    taskFromPlist.setValue("Survey", forKeyPath: "type")
                    taskFromPlist.write(toFile: taskPath, atomically: true)
                }
            }
        default:
            //No Change
            print("No change")
            
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.appTasks = DSTaskController.loadTasks()
        
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
