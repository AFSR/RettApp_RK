//
//  DetailGraphViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 12/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit

class DetailGraphViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var nbOfHourToShow = 7*24
    
    var taskId: String?
    var questionId: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var timeSelectSegment: UISegmentedControl!
    
    @IBAction func timeSelectedSegment(_ sender: Any) {
        switch timeSelectSegment.selectedSegmentIndex {
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
    
    fileprivate func colorFromDictionary(_ dict:NSDictionary) -> UIColor {
        
        let r = CGFloat(truncating: dict["red"] as! NSNumber)
        let g = CGFloat(truncating: dict["green"] as! NSNumber)
        let b = CGFloat(truncating: dict["blue"] as! NSNumber)
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
    }
    
    typealias GraphIdentifierType = (taskId: String, questionId: String)
    
    var graphIdentifiers = [GraphIdentifierType]()
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graphIdentifiers.count
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
        
        titleView.title = titleOfCell
        
        
        
        switch (graphType) {
        case GraphType.LineGraphChartView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineGraphCell", for: indexPath) as! LineTableViewCell
            
            cell.titleLabel.text = titleOfCell
            cell.subtitleLabel.text = subtitleOfCell
            
            cell.titleLabel.textColor = colorGraph
            cell.createGraph(color: colorGraph)
            
            cell.dataSource = LineGraphDataSource(taskID: graphId.taskId, questionID: graphId.questionId, nbOfHourToShow: nbOfHourToShow)
            cell.graphView.dataSource = cell.dataSource
            
            cell.toggleFullScreenButton.isHidden = true
            
            return cell
        case GraphType.DiscreteGraphChartView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscreteGraphCell", for: indexPath) as! DiscreteTableViewCell
            
            cell.titleLabel.text = titleOfCell
            cell.subtitleLabel.text = subtitleOfCell
            
            cell.titleLabel.textColor = colorGraph
            cell.createGraph(color: colorGraph)
            
            cell.dataSource = DiscreteGraphDataSource(taskID: graphId.taskId, questionID: graphId.questionId, nbOfHourToShow: nbOfHourToShow)
            cell.graphView.dataSource = cell.dataSource
            
            return cell
        case GraphType.TimeBased:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscreteGraphCell", for: indexPath) as! DiscreteTableViewCell
            
            cell.titleLabel.text = titleOfCell
            cell.subtitleLabel.text = subtitleOfCell
            
            cell.titleLabel.textColor = colorGraph
            cell.createGraph(color: colorGraph)
            
            cell.dataSource = DiscreteGraphDataSource(taskID: graphId.taskId, questionID: graphId.questionId, nbOfHourToShow: nbOfHourToShow)
            cell.graphView.dataSource = cell.dataSource
            
            return cell
        case GraphType.Circular:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CircularGraphCell", for: indexPath)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        //let height = tableView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        let cell = UIView()
        tableView.superview?.addSubview(cell)
        
        cell.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        
        if #available(iOS 12.0, *) {
            return tableView.visibleSize.height
        } else {
            // Fallback on earlier versions
            return UITableView.automaticDimension
        }

    }

    @IBOutlet weak var titleView: UINavigationItem!
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        
        return UIInterfaceOrientationMask.landscapeLeft
        
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

        timeSelectSegment.selectedSegmentIndex = 1
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 300
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
