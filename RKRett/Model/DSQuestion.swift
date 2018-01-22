//
//  DSQuestion.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/27/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

@objcMembers class DSQuestion: DSReflect {

    
    //        <dict>
    //            <key>answerUnit</key>
    //            <key>answerRange</key>
    //            <dict>
    //                <key>minimum</key>
    //                <key>maximum</key>
    //            </dict>
    //            <key>answerType</key>
    //            <key>prompt</key>
    //            <key>questionId</key>
    //            <key>dashboard</key>
    //            <dict>
    //                <key>graphicType</key>
    //                <key>xAxisColName</key>
    //                <key>yAxisColName</key>
    //            </dict>
    //        </dict>
    
    var answerUnit:String?
    var answerRange:NSDictionary?
    var answerType:String?
    var prompt:String?
    var questionId:String?
    var dashboard:NSDictionary?
    
    init(questionDictionary:NSDictionary){
        super.init()
        let properties = self.properties()
        for property in properties{
            let value = questionDictionary.object(forKey: property)
            switch(property){
            case "answerRange":
                // value tera um dictionary
                if let valueDictionary = value as? NSDictionary{
                    answerRange?.setValue(valueDictionary.object(forKey: "minimum"), forKey: "minimum")
                    answerRange?.setValue(valueDictionary.object(forKey: "maximum"), forKey: "maximum")
                    continue
                }
            case "dashboard":
                // value tera um dictionary
                if let valueDictionary = value as? NSDictionary{
                    dashboard?.setValue(valueDictionary.object(forKey: "graphicType"), forKey: "graphicType")
                    dashboard?.setValue(valueDictionary.object(forKey: "xAxisColName"), forKey: "xAxisColName")
                    dashboard?.setValue(valueDictionary.object(forKey: "yAxisColName"), forKey: "yAxisColName")
                    continue
                }
                print(property)
                
            default:
                print(property)
                
            }
            self.setValue(value, forKey: property)
        }
    }
    
}
