//
//  DSSettingsDashboardConfTableViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 02/05/18.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit


class DSSettingsDashboardConfTableViewController: UIViewController {
    
    var dashboardList:[String] = []
    
    func getDashBoardList(){
        
        if let path = Bundle.main.path(forResource: "DSTasks", ofType: "plist"){
            if let tasks = NSArray(contentsOfFile: path) {
                var itemNb = 0
                for taskId in tasks {
                    if let taskPath = Bundle.main.path(forResource: (taskId as! String), ofType: "plist") {
                        if let task = NSDictionary(contentsOfFile: taskPath) {
                            if let questions = task["questions"] as? NSArray {
                                for question in questions {
                                    if (question as! NSDictionary)["dashboard"] != nil {
                                        if let item = (question as! NSDictionary)["dashboard"] as? NSDictionary {
                                            dashboardList.append(item["title"] as! String)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    itemNb += 1
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        getDashBoardList()
    }
    
}

extension DSSettingsDashboardConfTableViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
}

extension DSSettingsDashboardConfTableViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dashboardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel?.text = dashboardList[indexPath.row]
        
        return cell
    }
    
}
