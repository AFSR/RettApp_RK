//
//  DSJSONSerializer.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/16/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import ResearchKit

/**
`DSJSONSerializer` is used to serialize ORKResult into JSON data.
*/
class DSJSONSerializer: DSReflect {
    
    
    
    static func convertDateHKtoRK(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from: date)
    }
    
    /**
    Convert an `NSArray` of ORKResult objects into a serialized JSON and return its `NSData` object.
    
    -param results: `NSArray` of ORKResult. Usually the value from `ORKTaskViewController.result.results`.
    
    -returns: A `NSData` object containing the JSON serialized from the results.
    */
    static func taskResultToJsonData(_ taskResult: ORKTaskResult,_ taskID: String) -> Data?{
        // - FIXME: Verificar a possibilidade de fazer a funcao retornar a String do JSON ao inves da NSData pois o model esta recebendo String
        var jsonData: Data?
        if let results = taskResult.results{ // NSArray/*<ORKResult>*/
            let resultsArray = self.resultsArrayToDictionary(results as NSArray)
            if taskID == "RettGrossMotorScale"{
                
                print("Results")
                print(resultsArray)
                
                for result in resultsArray {
                    let value = result.value as! NSDictionary
                    print("Resultat pour",result.key,": ", value.value(forKey: "result"))
                    
                }
                
                //let sittingScale = taskResult.results["motorSittingFloorSurvey"]
                //let sittingScale = (resultsArray["motorSittingFloorSurvey"]?["result"] as! Int) + (resultsArray["motorSittingChairSurvey"]?["result"] as! Int) + (resultsArray["motorSittingStoolSurvey"]?["result"] as! Int)
                //print("Sitting Subscale: ",sittingScale,"/9")
                
            }
            let json = NSDictionary(dictionary: ["taskId" : taskResult.identifier, "results": resultsArray])
            print("---JSON---")
            print(resultsArray.description)
            print("----------")
            jsonData = self.JSONObjectToData(json)
        }
        return jsonData
    }
    
    /**
     Convert an `NSArray` of HKSampleQuery objects into a serialized JSON and return its `NSData` object.
     
     -param results: `NSArray` of HKSample. Usually the value from `HKSampleQuery`.
     
     -returns: A `NSData` object containing the JSON serialized from the results.
     */
    static func hkSampleQueryResultToJsonData(_ queryResult: [HKSample]?) -> Data?{
        var dict = NSMutableDictionary()
        var jsonData: Data?
        if let result = queryResult {
            for item in result {
                if let sample = item as? HKCategorySample {
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    //let startSate = dateFormatter.dateFromString(sample.startDate)!
                    //let endDate = dateFormatter.dateFromString(sample.endDate)!
                    
                    let formatter = DateComponentsFormatter()
                    formatter.allowedUnits = [.hour]
                    formatter.unitsStyle = .positional
                    formatter.allowedUnits = [ .hour]
                    let hoursAsleep = formatter.string(from: sample.startDate, to: sample.endDate)!

                    if hoursAsleep != "0" {
                        
                        var dictAnswer = NSDictionary(dictionary: ["result": "" , "date":convertDateHKtoRK(sample.startDate)])
                        
                        dict.setValue(dictAnswer, forKey: "DSSleepDescription")
                        
                        dictAnswer = NSDictionary(dictionary: ["result": hoursAsleep , "date":convertDateHKtoRK(sample.startDate)])
                        dict.setValue(dictAnswer, forKey: "hoursSleep")
                        
                        let json = NSDictionary(dictionary: ["taskId" : "DSSleepTask", "results": dict])
                        jsonData = JSONObjectToData(json)

                    }
                }
            }
        }
        return jsonData
    }
    
    fileprivate static func resultsArrayToJsonArray(_ results: NSArray/*<ORKResult>*/) -> [NSMutableDictionary]{
        var dictArray = [NSMutableDictionary]()
        for stepResultAux in results{
            let dict = NSMutableDictionary()
            if let stepResult = stepResultAux as? ORKStepResult{
                if let result = stepResult.results?.first{
                    let answerKey = getAnswerKeyForResult(result)
                    assert(result.responds(to: Selector.init(answerKey)), "Result '\(NSStringFromClass(result.classForCoder))' doesn't respond to selector '\(answerKey)'")
                    if let value = result.value(forKey: answerKey){
                        if let key = result.identifier as String?{
                            dict.setValue(value, forKey: key)
                        }
                    }else{
                        print("Error getting value for key '\(result)'")
                    }
                }
            }
            dictArray += [dict]
        }
        
        return dictArray
    }
    
    //MARK: - Private functions
    /**
    Convert the array of results into a dictionary.
    
    - parameter results: `NSArray` of `ORKStepResult`.
    
    - returns: `NSDictionary` containing the results argument passed.
    */
    fileprivate static func resultsArrayToDictionary(_ results: NSArray/*<ORKResult>*/) -> NSDictionary{
        let dict = NSMutableDictionary()
        for stepResultAux in results {
            if let stepResult = stepResultAux as? ORKStepResult{
                if let result = stepResult.results?.first{
                    let answerKey = getAnswerKeyForResult(result)
                    assert(result.responds(to: Selector.init(answerKey)), "Result '\(NSStringFromClass(result.classForCoder))' doesn't respond to selector '\(answerKey)'")
                    if let value = result.value(forKey: answerKey){
                        if let key = result.identifier as String?{
                            let valueToSave = extractValue(value as AnyObject, forKey: answerKey)
                            let dictAnswer = NSDictionary(dictionary: ["result":valueToSave, "date":result.startDate.ISOStringFromDate()])
                            dict.setValue(dictAnswer, forKey: key)
                        }
                    }else{
                        print("Error getting value for key '\(result)'")
                    }
                }
            }
        }
        return dict
    }
    
    // - FIXME: Verificar o tipo de question pra quem sabe salvar os timeofday como hh:mm:ss
    // Avaliar a possibilidade de criar os models pros results e/ou salvar o ORKResult inteiro pq senao vai ter que ir no plist ver o tipo da variavel pq é ambiguo uma data e um timeofday
    fileprivate static func extractValue(_ value:AnyObject, forKey key:String = "") -> AnyObject{
        var extractedValue:AnyObject
        // - FIXME: Verificar singleChoice vs multipleChoice
        if key == "choiceAnswers"{
            extractedValue = (value as! NSArray).firstObject! as AnyObject
        }else{
            switch(value){
            case is Date, is DateComponents:
                extractedValue = getValueFromDateClasses(value) as AnyObject
                break
                
            default:
                extractedValue = value
            }
        }
        
        return extractedValue
    }
    
    fileprivate static func getValueFromDateClasses(_ value:AnyObject) -> String{
        var stringValue = ""
        var date:Date!
        
        switch(value){
        case is Date:
            print("NSDate")
            date = value as! Date
            break
            
        case is DateComponents:
            print("NSDateComponents")
            date = Calendar.current.date(from: (value as! DateComponents))!
            break
            
        default:
            print("Class not expected! Class: \(NSStringFromClass(value.classForCoder))")
        }
        
        stringValue = date.ISOStringFromDate()
        return stringValue
    }
    
    
    /**
    Get the key that contains the answer based on the result passed as argument.
    
    - parameter result: `ORKResult`.
    
    - returns: `String` with the key that contains the answer.
    */
    fileprivate static func getAnswerKeyForResult(_ result:ORKResult) -> String{
        var answerKey = ""
        
        switch(result){
        case let x where x is ORKNumericQuestionResult:
            answerKey = "numericAnswer"
        case let x where x is ORKTextQuestionResult:
            answerKey = "textAnswer"
        case let x where x is ORKChoiceQuestionResult:
            answerKey = "choiceAnswers"
        case let x where x is ORKTimeOfDayQuestionResult:
            answerKey = "dateComponentsAnswer"
        case let x where x is ORKBooleanQuestionResult:
            answerKey = "booleanAnswer"
        default:
            answerKey = ""
        }
        return answerKey
    }
    
    /**
    Convert the results dictionary to a JSON object.
    
    - parameter dictionary: `NSDictionary` to be converted to JSON object.
    
    - returns: `AnyObject?` containing the JSON object created.
    */
    fileprivate static func dictionaryToJSONObject(_ dictionary:NSDictionary) -> AnyObject?{
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
            let json = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.mutableContainers]) as? [String:AnyObject]
            return json as? AnyObject
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    /**
    Convert a JSON object to a `NSData?` object.
    
    - parameter jsonObject: `AnyObject`, JSON object to be converted to `NSData?`.
    
    - returns: `NSData?` object that represent the JSON object passed as parameter.
    */
    fileprivate static func JSONObjectToData(_ jsonObject:AnyObject) -> Data?{
        let data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        } catch let error as NSError {
            print(error.localizedDescription)
            data = nil
        }
        return data
    }
    
}
