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
    
    /**
    Convert an `NSArray` of ORKResult objects into a serialized JSON and return its `NSData` object.
    
    -param results: `NSArray` of ORKResult. Usually the value from `ORKTaskViewController.result.results`.
    
    -returns: A `NSData` object containing the JSON serialized from the results.
    */
    static func taskResultToJsonData(taskResult: ORKTaskResult) -> NSData?{
        // - FIXME: Verificar a possibilidade de fazer a funcao retornar a String do JSON ao inves da NSData pois o model esta recebendo String
        var jsonData: NSData?
        if let results = taskResult.results{ // NSArray/*<ORKResult>*/
            let resultsArray = self.resultsArrayToDictionary(results)
            let json = NSDictionary(dictionary: ["taskId" : taskResult.identifier, "results": resultsArray])
            jsonData = self.JSONObjectToData(json)
        }
        return jsonData
    }
    
    private static func resultsArrayToJsonArray(results: NSArray/*<ORKResult>*/) -> [NSMutableDictionary]{
        var dictArray = [NSMutableDictionary]()
        for stepResultAux in results{
            let dict = NSMutableDictionary()
            if let stepResult = stepResultAux as? ORKStepResult{
                if let result: AnyObject = stepResult.results?.first{
                    let answerKey = getAnswerKeyForResult(result as! ORKResult)
                    assert(result.respondsToSelector(NSSelectorFromString(answerKey)), "Result '\(NSStringFromClass(result.classForCoder))' doesn't respond to selector '\(answerKey)'")
                    if let value: AnyObject = result.valueForKey(answerKey){
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
    private static func resultsArrayToDictionary(results: NSArray/*<ORKResult>*/) -> NSDictionary{
        let dict = NSMutableDictionary()
        for stepResultAux in results {
            if let stepResult = stepResultAux as? ORKStepResult{
                if let result: AnyObject = stepResult.results?.first{
                    let answerKey = getAnswerKeyForResult(result as! ORKResult)
                    assert(result.respondsToSelector(NSSelectorFromString(answerKey)), "Result '\(NSStringFromClass(result.classForCoder))' doesn't respond to selector '\(answerKey)'")
                    if let value: AnyObject = result.valueForKey(answerKey){
                        if let key = result.identifier as String?{
                            let valueToSave = extractValue(value, forKey: answerKey)
                            let dictAnswer = NSDictionary(dictionary: ["result":valueToSave, "date":result.startDate!!.ISOStringFromDate()])
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
    private static func extractValue(value:AnyObject, forKey key:String = "") -> AnyObject{
        var extractedValue:AnyObject
        // - FIXME: Verificar singleChoice vs multipleChoice
        if key == "choiceAnswers"{
            extractedValue = (value as! NSArray).firstObject!
        }else{
            switch(value){
            case is NSDate, is NSDateComponents:
                extractedValue = getValueFromDateClasses(value)
                break
                
            default:
                extractedValue = value
            }
        }
        
        return extractedValue
    }
    
    private static func getValueFromDateClasses(value:AnyObject) -> String{
        var stringValue = ""
        var date:NSDate!
        
        switch(value){
        case is NSDate:
            print("NSDate")
            date = value as! NSDate
            break
            
        case is NSDateComponents:
            print("NSDateComponents")
            date = NSCalendar.currentCalendar().dateFromComponents((value as! NSDateComponents))!
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
    private static func getAnswerKeyForResult(result:ORKResult) -> String{
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
    private static func dictionaryToJSONObject(dictionary:NSDictionary) -> AnyObject?{
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted)
            let json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableContainers])
            return json
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
    private static func JSONObjectToData(jsonObject:AnyObject) -> NSData?{
        let data: NSData?
        do {
            data = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: [])
        } catch let error as NSError {
            print(error.localizedDescription)
            data = nil
        }
        return data
    }
    
}
