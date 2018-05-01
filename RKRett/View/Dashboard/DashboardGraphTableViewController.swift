//
//  DashboardGraphTableViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 01/05/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit

class DashboardGraphTableViewController: UITableViewController {

  
    @IBOutlet weak var titleViewController: UINavigationItem!
    
    var originCell = TimeBasedGraphCell()
 
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return UIInterfaceOrientationMask.landscapeLeft
    }
    
    override var shouldAutorotate: Bool{
        return false
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = tableView.systemLayoutSizeFitting(UILayoutFittingExpandedSize).height
        return height
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

        self.tableView.estimatedRowHeight = 300;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let cell = originCell as UITableViewCell

        let vc:DSTimeBasedGraphViewController

        vc = DSTimeBasedGraphViewController()
        vc.taskId = originCell.taskId
        vc.questionId = originCell.questionId
        vc.loadPlistData()
        vc.loadLocalData()
        vc.updateView()
        vc.updatePoints()
        vc.showAllData()
        
        titleViewController.title = vc.graphTitle
        
        let returnedCell = vc.view as! TimeBasedGraphCell
        returnedCell.taskId = vc.taskId
        returnedCell.questionId = vc.questionId
        returnedCell.wideButton.isHidden = true
        // Configure the cell...

        
        
        return returnedCell
        //return UITableViewCell()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


