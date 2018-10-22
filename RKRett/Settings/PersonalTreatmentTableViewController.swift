//
//  PersonalTreatmentTableViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 21/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import CoreData

class PersonalTreatmentTableViewController: UITableViewController {

    @IBOutlet weak var titleView: UINavigationItem!
    
    @IBAction func addTreatment(_ sender: Any) {
    }
    
    @IBAction func unwindToListTreatment(segue:UIStoryboardSegue) { }

    
    var personnalTreatment = [NSManagedObject]()
    
    func retrieveTreatment(){
        
       //Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Treatment")
        let predicate = NSPredicate(value: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let listOfTreatment = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try listOfTreatment.performFetch()
            if listOfTreatment.fetchedObjects?.count ?? 0 > 0 {
                personnalTreatment.removeAll()
                for treatment in listOfTreatment.fetchedObjects as! [NSManagedObject]{
                    personnalTreatment.append(treatment)
                }
            }
        }catch{
            print("Error retrieving treatment")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveTreatment()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleView.title = NSLocalizedString("Personal treatment", comment: "")
        
        retrieveTreatment()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return personnalTreatment.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "treatmentCell", for: indexPath)
        
        cell.textLabel?.text = (personnalTreatment[indexPath.row].value(forKey: "name") as! String) + " - " + (personnalTreatment[indexPath.row].value(forKey: "unit") as! String) + " " + (personnalTreatment[indexPath.row].value(forKey: "posology") as! Double).description + (personnalTreatment[indexPath.row].value(forKey: "frequency") as! String)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Treatment")
            let predicate = NSPredicate(value: true)
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            let listOfTreatment = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try listOfTreatment.performFetch()
                let tempList = listOfTreatment.fetchedObjects as! [NSManagedObject]
                context.delete(tempList[indexPath.row])
                personnalTreatment.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            }catch{
                print("Error retrieving treatment")
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
