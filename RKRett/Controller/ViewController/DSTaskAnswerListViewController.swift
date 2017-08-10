//
//  DSTaskAnswerListViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/24/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class DSTaskAnswerListViewController: UIViewController {
    var taskAnswers:Results<DSTaskAnswerRealm>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTaskAnswers()
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func loadTaskAnswers(){
        do {
            let realm = try Realm()
            kBgQueue.sync() {
                self.taskAnswers = realm.objects(DSTaskAnswerRealm.self) // => Results<DSTaskAnswerRealm>
                //                results.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        //        if let query = DSTaskAnswer.query(false){
        //            do{
        //                taskAnswers = try query.findObjects() as! [DSTaskAnswer]
        //            }catch{
        //                print("erro no find")
        //            }
        //            tableView.delegate = self
        //            tableView.dataSource = self
        //            tableView.reloadData()
        //        }
    }
}

// MARK: - UITableViewDelegate
extension DSTaskAnswerListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.taskAnswers == nil) ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kReuseIdentifier = "TaskAnswerCell"
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: kReuseIdentifier)
        let taskAnswer = self.taskAnswers[indexPath.row]
        cell.textLabel?.text = taskAnswer.taskName
        cell.detailTextLabel?.text = taskAnswer.json
        print(taskAnswer.json)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - UITableViewDataSource
extension DSTaskAnswerListViewController: UITableViewDataSource {
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return UIApplication.shared.statusBarFrame.size.height
        }else{
            return 0.5
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (self.taskAnswers == nil) ? 0 : self.taskAnswers.count
    }
    
}
