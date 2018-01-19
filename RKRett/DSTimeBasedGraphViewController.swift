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
    fileprivate var timeUnit = TimeUnit.hour
    fileprivate var color = UIColor.black
    fileprivate var points = [(Any, Any)]()
    fileprivate var data:Results<DSTaskAnswerRealm>!
    fileprivate var yHighlightedLines = NSMutableArray()
    fileprivate var maxValue = 0.0
    fileprivate var minValue = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cell = (Bundle.main.loadNibNamed("TimeBasedGraphCell", owner: self, options: nil) as! NSArray).object(at: 0) as! TimeBasedGraphCell
        self.view = cell
    }
    
    func loadPlistData(){
        var dict:NSDictionary?
        if let path = Bundle.main.path(forResource: self.taskId, ofType: "plist") {
            dict = NSDictionary(contentsOfFile: path)
        }
        
        if let task = dict {
            if let questions = (task["questions"] as? NSArray) {
                for question in questions {
               /*     if question["questionId"] as! [String] == self.questionId  {
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
//                                if let xhl = (highlightedLines["x"] as? NSArray) {
//                                    yHighlightedLines.addObjectsFromArray(yhl as [AnyObject])
//                                }
                                if let yhl = (highlightedLines["y"] as? NSArray) {
                                    self.yHighlightedLines.addObjects(from: yhl as [AnyObject])
                                }
                            }
                        }*/
                }
            }
        }
    }
    
    
    fileprivate func colorFromDictionary(_ dict:NSDictionary) -> UIColor {
        
        let r = CGFloat(dict["red"] as! NSNumber)
        let g = CGFloat(dict["green"] as! NSNumber)
        let b = CGFloat(dict["blue"] as! NSNumber)
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
        
    }
    
    func loadLocalData(){
        
        do{
            let realm = try Realm()
//            dispatch_sync(kBgQueue) {
            self.data = realm.objects(DSTaskAnswerRealm.self).filter("taskName = '\(self.taskId)'")
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
            let jsonData = obj.json.data(using: String.Encoding.utf8)
            do {
                json = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
            }catch let error as NSError {
                print(error.localizedDescription)
            }
            
            if json != nil {
                /*if let results = json!["results"] as? [NSDictionary] {
                    if let result = results[self.questionId] as? NSDictionary{
                        if let value = result["result"] {
                            if let dateString = result["date"] as? String {
                                let date = NSDate().dateFromISOString(dateString)
                                unorderedPoints+=[(date as Any, value as Any)]
                            }
                        }
                    }
                }*/
            }
        }
        
//        unorderedPoints.sortInPlace { (obj1:(Any, Any), obj2:(Any, Any)) -> Bool in
//            return obj1.0.timeIntervalSinceDate(obj2.0) > 0
//        }
        
        print("\(self.taskId) - \(self.questionId)")
        
        unorderedPoints.sort(by: {($0.0 as! Date).timeIntervalSince($1.0 as! Date) < 0})
        
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
            let min = point.date as! Date
            let max = Date()
            cell.graphView.setXValuesRange((min, max))
//            print(xScale)
        }
    }
    
    func showTodayData(){
        
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
            print("deu ruim")
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
