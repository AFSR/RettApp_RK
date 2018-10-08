//
//  DSTaskAnswerListViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/24/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 10.0, *)
class DSTaskAnswerListViewController: UIViewController {
    var answers = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTaskAnswers()
    }
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @available(iOS 10.0, *)
    func loadTaskAnswers(){
        
            //Core Data
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer")
            // Configure the request's entity, and optionally its predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "taskName", ascending: true)]
            let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try controller.performFetch()
            } catch {
                fatalError("Failed to fetch entities: \(error)")
            }
            
            for object in controller.fetchedObjects as! [NSManagedObject]{
                self.answers.append(object)
            }
            
            self.tableView.reloadData()
        
    }
}

// MARK: - UITableViewDelegate
@available(iOS 10.0, *)
extension DSTaskAnswerListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.answers == nil) ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kReuseIdentifier = "TaskAnswerCell"
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: kReuseIdentifier)
        let taskAnswer = self.answers[indexPath.row]
        cell.textLabel?.text = taskAnswer.value(forKey: "taskName") as! String
        cell.detailTextLabel?.text = taskAnswer.value(forKey: "json") as! String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - UITableViewDataSource
@available(iOS 10.0, *)
extension DSTaskAnswerListViewController: UITableViewDataSource {
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return UIApplication.shared.statusBarFrame.size.height
        }else{
            return 0.5
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.answers == nil) ? 0 : self.answers.count
    }
    
}
