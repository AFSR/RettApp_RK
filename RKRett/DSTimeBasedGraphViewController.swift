//
//  DSTimeBasedGraphViewController.swift
//  RKRett
//
//  Created by Mateus Reckziegel on 9/16/15.
//  Updated by Julien Fieschi on 9/16/18
//  Copyright © 2015 DarkShine. All rights reserved.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import CoreData


class DSTimeBasedGraphViewController: UIViewController {
    
    var taskId = ""
    var questionId = ""
    var graphTitle = ""
    var graphSubtitle = ""
    var timeUnit = TimeUnit.hour
    fileprivate var color = UIColor.black
    fileprivate var correlateTask = [Any]()
    fileprivate var points = [(Any, Any)]()
    
    //CoreData
    fileprivate var dataCore = [NSManagedObject]()
    
    fileprivate var yHighlightedLines = NSMutableArray()
    fileprivate var maxValue = 0.0
    fileprivate var minValue = 0.0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cell = (Bundle.main.loadNibNamed("TimeBasedGraphCell", owner: self, options: nil) as! NSArray).object(at: 0) as! TimeBasedGraphCell
        self.view = cell
        
        if self.view is TimeBasedGraphCell  {
            let cell = self.view as! TimeBasedGraphCell
            cell.graphView.setXValuesRange((((Date() - 3600 * 24) as Date),Date()))
            cell.graphView.timeUnit = .hour
            self.view.setNeedsDisplay()
        }
        
        print(points.description)
    }
    
    
    
    func loadPlistData(){
        var dict:NSDictionary?
        if let path = Bundle.main.path(forResource: self.taskId, ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let task = dict {
            if let questions = (task["questions"] as? NSArray) {
                
                for question in questions {
                    
                    let quest = question as? NSDictionary;
                    
                    if (quest!["questionId"] as? String) == self.questionId  {
                        if let answerRange = (quest!["answerRange"] as? NSDictionary) {
                            if let max = answerRange["maximum"] as? Double {
                                self.maxValue = max
                            }
                            if let min = answerRange["minimun"] as? Double {
                                self.minValue = min
                            }
                        }
                        if let dashboard = (quest!["dashboard"] as? NSDictionary) {
                            if let timeUnit = (dashboard["timeUnit"] as? String) {
                                switch (timeUnit) {
                                case "Second" :
                                    self.timeUnit = .second
                                case "Minute" :
                                    self.timeUnit = .minute
                                case "Hour" :
                                    self.timeUnit = .hour
                                case "Day" :
                                    self.timeUnit = .day
                                case "Week" :
                                    self.timeUnit = .week
                                case "Month" :
                                    self.timeUnit = .month
                                case "Year" :
                                    self.timeUnit = .year
                                default:
                                    break
                                }
                            }
                            if let title = (dashboard["title"] as? String) {
                                self.graphTitle = title
                            }
                            if let subtitle = (dashboard["subtitle"] as? String) {
                                self.graphSubtitle = subtitle
                            }
                            if let color = (dashboard["color"] as? NSDictionary){
                                self.color = self.colorFromDictionary(color)
                            }
                            if let highlightedLines = (dashboard["highlightedLines"] as? NSDictionary) {
                                if let xhl = (highlightedLines["x"] as? NSArray) {
                                    self.yHighlightedLines.addObjects(from: xhl as [AnyObject])
                                }
                                if let yhl = (highlightedLines["y"] as? NSArray) {
                                    self.yHighlightedLines.addObjects(from: yhl as [AnyObject])
                                }
                            }
                        }
                    }
                        //
                }
            }
        }
    }
    
    
    fileprivate func colorFromDictionary(_ dict:NSDictionary) -> UIColor {
        
        let r = CGFloat(truncating: dict["red"] as! NSNumber)
        let g = CGFloat(truncating: dict["green"] as! NSNumber)
        let b = CGFloat(truncating: dict["blue"] as! NSNumber)
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
    }
    
    func loadLocalData(){
        
        do{
            
            //Core Data
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskAnswer")
            fetchRequest.predicate = NSPredicate(format: "taskName = '\(self.taskId)'", argumentArray:nil)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "taskName", ascending: true)]
            
            let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            do {
                try controller.performFetch()
            } catch {
                fatalError("Failed to fetch entities: \(error)")
            }
            
            var json = [String : Any]()
            var unorderedPoints = [(Any, Any)]()
            
            for object in controller.fetchedObjects as! [NSManagedObject]{
                
                let jsonData = (object.value(forKey: "json") as! String).data(using: String.Encoding.utf8)
                
                do {
                    json = (try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any])!
                }catch let error as NSError {
                    print(error.localizedDescription)
                }

                if json != nil {
                    if let results = json["results"] as? [String : Any] {
                        if let result = results[self.questionId] as? [String : Any] {
                            if let value = result["result"] as? NSNumber {
                                if let dateString = result["date"] as? String {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    guard let date = dateFormatter.date(from: dateString) else {
                                        fatalError("ERROR: Date conversion failed due to mismatched format.")
                                    }
                                    if self.taskId == "RettGrossMotorScale"{
                                        
                                        switch self.questionId{
                                        case "motorSittingFloorSurvey": //Global score - Sum all the Gross Motor survey results
                                            var summedValue = 0
                                            print(results)
                                            for (motorId, motorResults) in results as! [String : Any] {
                                                let motorResult = motorResults as? NSDictionary
                                                summedValue = summedValue + Int(motorResult?.value(forKey: "result") as! NSNumber)
                                            }
                                            let summedMotorValue = summedValue as NSNumber
                                            unorderedPoints+=[(date as Any, summedMotorValue as Any)]
                                        case "motorSittingChairSurvey":
                                            var summedValue = 0
                                            for (motorId, motorResults) in results as! [String : Any] {
                                                if motorId == "motorSittingFloorSurvey" || motorId == "motorSittingChairSurvey" || motorId == "motorSittingStoolSurvey"{
                                                    let motorResult = motorResults as? NSDictionary
                                                    summedValue = summedValue + Int(motorResult?.value(forKey: "result") as! NSNumber)
                                                }
                                            }
                                            let summedMotorValue = summedValue as NSNumber
                                            unorderedPoints+=[(date as Any, summedMotorValue as Any)]
                                        case "motorSittingStoolSurvey":
                                            var summedValue = 0
                                            for (motorId, motorResults) in results as! [String : Any] {
                                                if motorId == "motorSittingStandSurvey" || motorId == "motorStanding3Survey" || motorId == "motorStanding10Survey" || motorId == "motorStanding20Survey" || motorId == "motorTurnsSurvey" || motorId == "motorWalkSlopeSurvey" || motorId == "motorWalkObstacleSurvey" || motorId == "motorStandUpSurvey" || motorId == "motorBendingSurvey"{
                                                    let motorResult = motorResults as? NSDictionary
                                                    summedValue = summedValue + Int(motorResult?.value(forKey: "result") as! NSNumber)
                                                }
                                            }
                                            let summedMotorValue = summedValue as NSNumber
                                            unorderedPoints+=[(date as Any, summedMotorValue as Any)]
                                        case "motorSittingChairSurvey":
                                            var summedValue = 0
                                            for (motorId, motorResults) in results as! [String : Any] {
                                                if motorId == "motorWalk10Survey" || motorId == "motorSideStepSurvey" || motorId == "motorRunsSurvey"{
                                                    let motorResult = motorResults as? NSDictionary
                                                    summedValue = summedValue + Int(motorResult?.value(forKey: "result") as! NSNumber)
                                                }
                                            }
                                            let summedMotorValue = summedValue as NSNumber
                                            unorderedPoints+=[(date as Any, summedMotorValue as Any)]
                                        default:
                                            unorderedPoints+=[(date as Any, value as Any)]
                                        }
                                    }else{
                                        unorderedPoints+=[(date as Any, value as Any)]
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            
            print("\(self.taskId) - \(self.questionId)")
            
            unorderedPoints.sort(by: {($0.0 as! Date).timeIntervalSince($1.0 as! Date) < 0})
            
            self.points = unorderedPoints

            self.updatePoints()
            
        }catch let error as NSError{
            
            print(error.localizedDescription)
            return
            
        }
        
//        unorderedPoints.sortInPlace { (obj1:(Any, Any), obj2:(Any, Any)) -> Bool in
//            return obj1.0.timeIntervalSinceDate(obj2.0) > 0
        
    
    }
    
    func showAllData(){
        if self.view is TimeBasedGraphCell && self.points.count >= 2 {
            let cell = self.view as! TimeBasedGraphCell
            let xScale:CGFloat
            let graphWidth = cell.graphView.frame.width - (cell.graphView.edgeInsets.left + cell.graphView.edgeInsets.right)
            print(graphWidth)
            let firstDate = self.points.first!.0 as! NSDate
            let lastDate = self.points.last!.0 as! NSDate
            //let totalTime = CGFloat(lastDate.timeIntervalSinceDate(firstDate as Date)/cell.graphView.getTimeMultiplier())
            let totalTime = CGFloat(lastDate.timeIntervalSince(firstDate as Date)/lastDate.timeIntervalSince(lastDate as Date))
            xScale = graphWidth/totalTime
            let point = self.points[0] as (date:Any, value:Any)
            let min = point.date as! Date
            let max = Date()
            cell.graphView.setXValuesRange((min, max))
        }
    }
    
    func showTodayData(){
        if self.view is TimeBasedGraphCell  {
            let cell = self.view as! TimeBasedGraphCell
            cell.graphView.setXValuesRange((((Date() - 3600 * 24 - 3600) as Date),Date()))
            cell.graphView.timeUnit = .hour
            self.view.setNeedsDisplay()
        }
        
    }
    
    func showWeekData(){
        if self.view is TimeBasedGraphCell {
            let cell = self.view as! TimeBasedGraphCell
            cell.graphView.setXValuesRange((((Date() - 3600 * 24 * 7 - 3600 * 24) as Date),Date()))
            cell.graphView.timeUnit = .day
            self.view.setNeedsDisplay()
        }
    }
    
    func showMonthData(){
        if self.view is TimeBasedGraphCell {
            let cell = self.view as! TimeBasedGraphCell
            cell.graphView.setXValuesRange((((Date() - 3600 * 24 * 31 - 3600 * 24 * 7) as Date),Date()))
            cell.graphView.timeUnit = .week
            self.view.setNeedsDisplay()
        }
    }
    
    func showYearData(){
        if self.view is TimeBasedGraphCell {
            let cell = self.view as! TimeBasedGraphCell
            cell.graphView.setXValuesRange((((Date() - 3600 * 24 * 365 - 3600 * 24 * 31) as Date),Date()))
            cell.graphView.timeUnit = .month
            self.view.setNeedsDisplay()
        }
    }
    
    func showAllDataInGraph(){
        if self.view is TimeBasedGraphCell {
            let cell = self.view as! TimeBasedGraphCell
            let datePoints = cell.graphView.points
            if datePoints.count > 0 {
                var minDate = datePoints[0].0 as! Date
                for point in points{
                    if minDate > (point.0 as! Date){
                        minDate = (point.0 as! Date)
                    }
                }
                cell.graphView.setXValuesRange((minDate,Date()))
//                if (DateInterval(start: minDate, end: Date())) > DateInterval(start: <#T##Date#>, duration: <#T##TimeInterval#>) 3600 * 24 {
//                    cell.graphView.timeUnit = .day
//                }else{
//                    cell.graphView.timeUnit = .day
//                }
//                if (DateInterval(start: minDate, end: Date()) as! Double) > 3600 * 24 * 31 {
//                    cell.graphView.timeUnit = .week
//                }
//                if (DateInterval(start: minDate, end: Date()) as! Double) > 3600 * 24 * 31 * 6 {
//                    cell.graphView.timeUnit = .month
//                }
                cell.graphView.timeUnit = .month
            }else{
                cell.graphView.setXValuesRange((((Date() - 3600 * 24 * 365 - 3600 * 24 * 31) as Date),Date()))
                cell.graphView.timeUnit = .month
            }
            self.view.setNeedsDisplay()
        }
    }
    
    func showDataFrom(_ initialDate:Date ,toDate finalDate:Date){
        
    }
    
    func updateView() {
        if self.view.isKind(of: TimeBasedGraphCell.self) {
            let cell = (self.view as! TimeBasedGraphCell)
            cell.lblTitle.text = self.graphTitle
            cell.lblSubtitle.text = self.graphSubtitle
            cell.lblTitle.textColor = self.color
            cell.graphView.timeUnit = self.timeUnit
            cell.graphView.lineColor = self.color
            cell.graphView.setYValuesRange((self.minValue, self.maxValue))
            for line in self.yHighlightedLines {
                cell.graphView.addYHighlightedLine(CGFloat(line as! Double))
            }
        } else {
            //print("deu ruim")
        }
    }
    
    func resetValues() {
        points.removeAll()
        if self.view is TimeBasedGraphCell  {
            let cell = self.view as! TimeBasedGraphCell
            cell.graphView.clearGraph()
            self.view.setNeedsDisplay()
        }
    }
    
    func updatePoints() {
        if self.view.isKind(of: TimeBasedGraphCell.self) {
            let cell = (self.view as! TimeBasedGraphCell)
            cell.graphView.setPoints(self.points)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
