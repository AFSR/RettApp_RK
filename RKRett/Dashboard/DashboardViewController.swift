//
//  DashboardTableViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 11/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, DiscreteTableViewCellDelegate, UITableViewDelegate, UITableViewDataSource, LineTableViewCellDelegate, CircularTableViewCellDelegate  {
    
    
    func didTapShowGraph(_ sender: Any, taskID: String,questionID: String) {
        performSegue(withIdentifier: "toggleFullScreen", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("Prepare for segue")
        let destination : DetailGraphViewController = segue.destination as! DetailGraphViewController
        
        if segue.identifier == "toggleFullScreen"{
            print("Toggle to full screen")
            let senderButton = (sender as! UIButton)
            guard let cell = senderButton.superview?.superview as? GraphTableViewCell else {
                return // or fatalError() or whatever
            }
            destination.taskId = cell.taskId
            destination.questionId = cell.questionId
            let graphicId = DetailGraphViewController.GraphIdentifierType(cell.taskId!,cell.questionId!)
            destination.graphIdentifiers.append(graphicId)
            
            }
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewSegment: UISegmentedControl!
    
    
    @IBAction func viewSegment(_ sender: Any) {
        
        switch viewSegment.selectedSegmentIndex {
        case 0:
            self.nbOfHourToShow = 24
            self.tableView.reloadData()
        case 1:
            self.nbOfHourToShow = 7*24
            self.tableView.reloadData()
        case 2:
            self.nbOfHourToShow = 31*24
            self.tableView.reloadData()
        case 3:
            self.nbOfHourToShow = 365*24
            self.tableView.reloadData()
        default:
            self.nbOfHourToShow = 7*24
            self.tableView.reloadData()
        }
        
    }
    
    typealias GraphIdentifierType = (taskId: String, questionId: String)
    
    var graphIdentifiers = [GraphIdentifierType]()
    
    var nbOfHourToShow = 7*24
    
    var dateMaxVisual = Date() - 7 * 24 * 3600
    
    enum GraphType:String, CustomStringConvertible{
        case TimeBased = "timeBased", Circular = "circular", DiscreteGraphChartView = "DiscreteGraphChartView", LineGraphChartView = "LineGraphChartView"
        
        var description:String{
            return self.rawValue
        }
    }
    
    fileprivate func graphTypeForId(_ graphId:GraphIdentifierType) -> GraphType {
        if let path = Bundle.main.path(forResource: graphId.taskId, ofType: "plist"){
            if let plistFile = NSDictionary(contentsOfFile: path){
                if let questions = plistFile.object(forKey: PlistFile.Task.Question.Key.rawValue) as? [NSDictionary]{
                    for question in questions{
                        if let dashboard = question.object(forKey: PlistFile.Task.Question.Dashboard.Key.rawValue) as? NSDictionary{
                            if let graphType = dashboard.object(forKey: PlistFile.Task.Question.Dashboard.GraphType.rawValue) as? String{
                                return GraphType(rawValue: graphType)!
                            }
                        }
                    }
                }
            }
        }
        assertionFailure("Tipo invalido, olha o plist la o mané! \nTaskID: \(graphId.taskId) \nQuestionID: \(graphId.questionId)")
        return GraphType(rawValue: String())!
    }
    
    fileprivate func getGraphIds() -> [GraphIdentifierType]{
        var graphIds = [GraphIdentifierType]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        for task in appDelegate.appTasks{
            if task.status == true{
                if let questions = task.questions as? NSArray {
                    for question in questions {
                        if (question as! NSDictionary)["dashboard"] != nil {
                            if let questionId = (question as! NSDictionary)["questionId"] as? String {
                                graphIds += [(task.taskId, questionId)]
                            }
                        }
                    }
                }
            }
        }
        return graphIds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        tableView.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        viewSegment.selectedSegmentIndex = 1
        
        graphIdentifiers = getGraphIds()
        
        print("GraphIdentifiers:",graphIdentifiers.description)
        
        tableView.rowHeight = 200
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(graphIdentifiers.count.description)
        return graphIdentifiers.count
    }
    
    fileprivate func colorFromDictionary(_ dict:NSDictionary) -> UIColor {
        
        let r = CGFloat(truncating: dict["red"] as! NSNumber)
        let g = CGFloat(truncating: dict["green"] as! NSNumber)
        let b = CGFloat(truncating: dict["blue"] as! NSNumber)
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let graphId = graphIdentifiers[indexPath.row]
        let graphType = graphTypeForId(graphId)
        
        print("TaskId:",graphId.taskId,"-",graphType.description)
        
        
        var dict:NSDictionary?
        if let path = Bundle.main.path(forResource: graphId.taskId, ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        var colorGraph = UIColor()
        var titleOfCell = String()
        var subtitleOfCell = String()
        
        if let task = dict {
            if let questions = (task["questions"] as? NSArray) {
                
                for question in questions {
                    
                    let quest = question as? NSDictionary;
                    
                    if (quest!["questionId"] as? String) == graphId.questionId  {
                        
                        if let dashboard = (quest!["dashboard"] as? NSDictionary) {
                            
                            if let title = (dashboard["title"] as? String) {
                                titleOfCell = title
                            }
                            if let subtitle = (dashboard["subtitle"] as? String) {
                                subtitleOfCell = subtitle
                            }
                            if let color = (dashboard["color"] as? NSDictionary){
                                colorGraph = self.colorFromDictionary(color)
                            }
                        }
                    }
                }
            }
        }
        
        switch (graphType) {
        case GraphType.LineGraphChartView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineGraphCell", for: indexPath) as! LineTableViewCell
            
            cell.titleLabel.text = titleOfCell
            cell.subtitleLabel.text = subtitleOfCell
            
            cell.titleLabel.textColor = colorGraph
            cell.createGraph(color: colorGraph)
            
            cell.dataSource = LineGraphDataSource(taskID: graphId.taskId, questionID: graphId.questionId, nbOfHourToShow: nbOfHourToShow)
            cell.graphView.dataSource = cell.dataSource
            
            cell.taskId = graphId.taskId
            cell.questionId = graphId.questionId
            
            return cell
        case GraphType.DiscreteGraphChartView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscreteGraphCell", for: indexPath) as! DiscreteTableViewCell
            
            cell.titleLabel.text = titleOfCell
            cell.subtitleLabel.text = subtitleOfCell
            
            cell.titleLabel.textColor = colorGraph
            cell.createGraph(color: colorGraph)
            
            cell.dataSource = DiscreteGraphDataSource(taskID: graphId.taskId, questionID: graphId.questionId, nbOfHourToShow: nbOfHourToShow)
            cell.graphView.dataSource = cell.dataSource
            
            cell.taskId = graphId.taskId
            cell.questionId = graphId.questionId
            
            return cell
        case GraphType.TimeBased:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscreteGraphCell", for: indexPath) as! DiscreteTableViewCell
            
            cell.titleLabel.text = titleOfCell
            cell.subtitleLabel.text = subtitleOfCell
            
            cell.titleLabel.textColor = colorGraph
            cell.createGraph(color: colorGraph)
            
            cell.dataSource = DiscreteGraphDataSource(taskID: graphId.taskId, questionID: graphId.questionId, nbOfHourToShow: nbOfHourToShow)
            cell.graphView.dataSource = cell.dataSource
            
            cell.taskId = graphId.taskId
            cell.questionId = graphId.questionId
            
            return cell
        case GraphType.Circular:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CircularGraphCell", for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            if let taskPath = Bundle.main.path(forResource: graphIdentifiers[indexPath.row].taskId, ofType: "plist") {
                if let taskFromPlist = NSMutableDictionary(contentsOfFile: taskPath){
                    taskFromPlist.setValue(false, forKeyPath: "status")
                    taskFromPlist.write(toFile: taskPath, atomically: true)
                }
            }
            graphIdentifiers.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        print(sourceIndexPath,"->",destinationIndexPath)
        print(graphIdentifiers)
        let source = graphIdentifiers[sourceIndexPath.row]
        graphIdentifiers.remove(at: sourceIndexPath.row)
        graphIdentifiers.insert(source, at: destinationIndexPath.row)
        
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tableView.setEditing(true, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tableView.setEditing(false, animated: true)
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
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
