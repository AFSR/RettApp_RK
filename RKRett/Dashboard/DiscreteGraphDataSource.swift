//
//  LineGraph.swift
//  RKRett
//
//  Created by Julien Fieschi on 11/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import ResearchKit
import CoreData

class DiscreteGraphDataSource: NSObject, ORKGraphChartViewDataSource, ORKValueRangeGraphChartViewDataSource {
    // MARK: Properties
    
    let taskId : String
    let questionId : String
    
    var points = [(Any, Any)]()
    
    var nbOfDayToShow = Int()
    
    var nbOfHourToShow = Int()
    
    //var plotPoints = [[ORKValueRange]]()
    
    var plotPoints =
                [
                        ORKValueRange(value: 10),
            ]
    
    var pointsIndex = [String]()
    
    func loadLocalData(){
        
        do{
            
            //Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
            
            
        }catch let error as NSError{
            
            print(error.localizedDescription)
            return
            
        }
        
        plotPoints.removeAll()
        
        var stepIndex = 1
        
        switch nbOfHourToShow {
        case 24:
            stepIndex = 2
         case 168: //Week
            stepIndex = 24
        case 744: //Month
            stepIndex = 24*7
        case 8760: //Year
            stepIndex = 24*31
        default:
            stepIndex = 24
        }
        
        var dateIndex = [Date]()
        
        for i in stride(from: nbOfHourToShow, through: 0, by: -stepIndex){
            var minValue = 0.0
            var maxValue = 0.0
            let dateOfIndex = Date() - TimeInterval(i * 3600)
            let dateOfNextIndex = dateOfIndex + TimeInterval( stepIndex * 3600)
            for point in points{
                if (dateOfIndex...dateOfNextIndex).contains(point.0 as! Date){
                    if (point.1 as! Double) <= minValue{
                        if (minValue == maxValue) && minValue == 0 {
                            maxValue = (point.1 as! Double)
                        }
                        minValue = (point.1 as! Double)
                    }
                    if (point.1 as! Double) >= maxValue{
                        if (minValue == maxValue) && minValue == 0 {
                            minValue = (point.1 as! Double)
                        }
                        maxValue = (point.1 as! Double)
                    }
                }
            }
            dateIndex.append(dateOfIndex)
            if (minValue == maxValue) && (minValue == 0.0) {
                plotPoints.append(ORKValueRange())
            }else{
                plotPoints.append(ORKValueRange(minimumValue: minValue, maximumValue: maxValue))
            }
        }
        for date in dateIndex{
            switch nbOfHourToShow {
            case 24:
                pointsIndex.append(date.hour.description + "h")
            case 168: //Week
                pointsIndex.append(date.day.description + "/" + date.month.description)
            case 744: //Month
                pointsIndex.append(date.day.description + "/" + date.month.description)
            case 8760: //Year
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "LLL"
                pointsIndex.append(dateFormatter.string(from: date))
            default:
                pointsIndex.append(date.day.description + "/" + date.month.description)
            }
        }
        print(dateIndex)
        print("Nb de points:",plotPoints.count.description)
        
    }
    
    
    // MARK: ORKGraphChartViewDataSource
    
    func numberOfPlots(in graphChartView: ORKGraphChartView) -> Int {
        return 1
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, dataPointForPointIndex pointIndex: Int, plotIndex: Int) -> ORKValueRange {
        //return plotPoints[plotIndex][pointIndex]
        print("PointIndex:",pointIndex,"Valeur:",plotPoints[pointIndex])
        return plotPoints[pointIndex]
    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, numberOfDataPointsForPlotIndex plotIndex: Int) -> Int {
        //return plotPoints[plotIndex].count
        return plotPoints.count
    }
    
    func maximumValue(for graphChartView: ORKGraphChartView) -> Double {
        var maxValue = 0.0
        for point in plotPoints{
            if !point.isUnset && point.maximumValue >= maxValue{
                maxValue = point.maximumValue
            }
        }
        print("MaxValue:",maxValue)
        return maxValue
    }
    
    func minimumValue(for graphChartView: ORKGraphChartView) -> Double {
        var minValue = 0.0
        for point in plotPoints{
            if !point.isUnset && point.minimumValue <= minValue{
                minValue = point.minimumValue
            }
        }
        print("MinValue:",minValue)
        return minValue
    }
    
//    func numberOfDivisionsInXAxis(for graphChartView: ORKGraphChartView) -> Int {
//        var stepIndex = 1
//        switch nbOfDayToShow {
//        case 1:
//            stepIndex = 24
//        case 7:
//            stepIndex = 8
//        case 31:
//            stepIndex = 4
//        case 365:
//            stepIndex = 12
//        default:
//            stepIndex = 8
//        }
//        return stepIndex
//    }
    
    func graphChartView(_ graphChartView: ORKGraphChartView, titleForXAxisAtPointIndex pointIndex: Int) -> String? {
        return pointsIndex[pointIndex]
    }
    
    required init?(taskID: String, questionID: String, nbOfHourToShow: Int) {
        self.taskId = taskID
        self.questionId = questionID
        self.nbOfHourToShow = nbOfHourToShow
        
        super.init()
        
        self.loadLocalData()
    }
}
