//
//  DSTimeBasedGraphViewController.swift
//  RKRett
//
//  Created by Mateus Reckziegel on 9/16/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class DSTimeBasedGraphViewController: UIViewController {
    
    var taskId = ""
    var questionId = ""
    var graphTitle = ""
    var graphSubtitle = ""
    private var timeUnit = TimeUnit.Hour
    private var color = UIColor.blackColor()
    private var points = [(Any, Any)]()
    private var data:Results<DSTaskAnswerRealm>!
    private var yHighlightedLines = NSMutableArray()
    private var maxValue = 0.0
    private var minValue = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cell = (NSBundle.mainBundle().loadNibNamed("TimeBasedGraphCell", owner: self, options: nil) as NSArray).objectAtIndex(0) as! TimeBasedGraphCell
        self.view = cell
    }
    
    func loadPlistData(){
        var dict:NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource(self.taskId, ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let task = dict {
            if let questions = (task["questions"] as? NSArray) {
                for question in questions {
                    if question["questionId"] as! String == self.questionId {
                        if let answerRange = question["answerRange"] as? NSDictionary {
                            if let max = answerRange["maximum"] as? Double {
                                self.maxValue = max
                            }
                            if let min = answerRange["minimun"] as? Double {
                                self.minValue = min
                            }
                        }
                        if let dashboard = (question["dashboard"] as? NSDictionary) {
                            if let timeUnit = (dashboard["timeUnit"] as? String) {
                                switch (timeUnit) {
                                case "Second" :
                                    self.timeUnit = .Second
                                case "Minute" :
                                    self.timeUnit = .Minute
                                case "Hour" :
                                    self.timeUnit = .Hour
                                case "Day" :
                                    self.timeUnit = .Day
                                case "Week" :
                                    self.timeUnit = .Week
                                case "Month" :
                                    self.timeUnit = .Month
                                case "Year" :
                                    self.timeUnit = .Year
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
//                                if let xhl = (highlightedLines["x"] as? NSArray) {
//                                    yHighlightedLines.addObjectsFromArray(yhl as [AnyObject])
//                                }
                                if let yhl = (highlightedLines["y"] as? NSArray) {
                                    self.yHighlightedLines.addObjectsFromArray(yhl as [AnyObject])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func colorFromDictionary(dict:NSDictionary) -> UIColor {
        
        let r = CGFloat(dict["red"] as! NSNumber)
        let g = CGFloat(dict["green"] as! NSNumber)
        let b = CGFloat(dict["blue"] as! NSNumber)
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
    }
    
    func loadLocalData(){
        
        do{
            let realm = try Realm()
//            dispatch_sync(kBgQueue) {
                self.data = realm.objects(DSTaskAnswerRealm).filter("taskName = '\(self.taskId)'")
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.updatePoints(true)
//                })
//            }
        }catch let error as NSError{
            print(error.localizedDescription)
            return
        }
        var json: AnyObject?
        var unorderedPoints = [(Any, Any)]()
        
        for obj in data {
            let jsonData = obj.json.dataUsingEncoding(NSUTF8StringEncoding)
            do {
                json = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments)
            }catch let error as NSError {
                print(error.localizedDescription)
            }
            
            if json != nil {
                if let results = json!["results"] as? NSDictionary {
                    if let result = results[self.questionId] as? NSDictionary{
                        if let value = result["result"] {
                            if let dateString = result["date"] as? String {
                                let date = NSDate().dateFromISOString(dateString)
                                unorderedPoints+=[(date as Any, value as Any)]
                            }
                        }
                    }
                }
            }
        }
        
//        unorderedPoints.sortInPlace { (obj1:(Any, Any), obj2:(Any, Any)) -> Bool in
//            return obj1.0.timeIntervalSinceDate(obj2.0) > 0
//        }
        
        print("\(self.taskId) - \(self.questionId)")
        
        unorderedPoints.sortInPlace({($0.0 as! NSDate).timeIntervalSinceDate($1.0 as! NSDate) < 0})
        
        self.points = unorderedPoints
    
    }
    
    func showAllData(){
        if self.view is TimeBasedGraphCell && self.points.count >= 2 {
            let cell = self.view as! TimeBasedGraphCell
//            let xScale:CGFloat
//            let graphWidth = cell.graphView.frame.width - (cell.graphView.edgeInsets.left + cell.graphView.edgeInsets.right)
//            print(graphWidth)
//            let firstDate = self.points.first!.0 as! NSDate
//            let lastDate = self.points.last!.0 as! NSDate
//            let totalTime = CGFloat(lastDate.timeIntervalSinceDate(firstDate)/cell.graphView.getTimeMultiplier())
//            xScale = graphWidth/totalTime
            let point = self.points[0] as (date:Any, value:Any)
            let min = point.date as! NSDate
            let max = NSDate()
            cell.graphView.setXValuesRange((min, max))
//            print(xScale)
        }
    }
    
    func showTodayData(){
        
    }
    
    func showDataFrom(initialDate:NSDate ,toDate finalDate:NSDate){
        
    }
    
    func updateView() {
        if self.view.isKindOfClass(TimeBasedGraphCell) {
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
            print("deu ruim")
        }
    }
    
    func updatePoints() {
        if self.view.isKindOfClass(TimeBasedGraphCell) {
            let cell = (self.view as! TimeBasedGraphCell)
            cell.graphView.setPoints(self.points)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
