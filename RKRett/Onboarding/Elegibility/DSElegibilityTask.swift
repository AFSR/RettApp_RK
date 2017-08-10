//
//  DSElegibilityTask.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/15/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//
import ResearchKit
public var DSElegibilityTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    if let path = NSBundle.mainBundle().pathForResource(kDSElegibilityPlist, ofType: "plist") {
        if let plistDictionary = NSDictionary(contentsOfFile: path){
            if let instructionDictionary = plistDictionary.valueForKey("instruction") as? NSDictionary{
                let detailText = instructionDictionary.valueForKey("detailText") as? String
                let instructionStep = ORKInstructionStep(identifier: kQuizIntroductionStepIdentifier)
                instructionStep.detailText = detailText
                steps += [instructionStep]
            }
            if let questionsArray = plistDictionary.valueForKey("question") as? Array<AnyObject> {
                for dictionary in questionsArray{
                    let questionDictionary = dictionary as! NSDictionary
                    let questionIdentifier = questionDictionary.valueForKey("identifier") as? String
                    let questionTitle = questionDictionary.valueForKey("title") as? String
                    
                    var questionStep = ORKQuestionStep()
                    
                    switch(dictionary.valueForKey("type") as! String){
                    case "Boolean":
                        questionStep = ORKQuestionStep(identifier: questionIdentifier!, title: questionTitle, answer: ORKAnswerFormat.booleanAnswerFormat())
                        
                    case "SingleChoice":
                        var questionTextChoices = [String]()
                        for choice in questionDictionary.valueForKey("choices") as! Array<AnyObject>{
                            questionTextChoices.append(choice as! String)
                        }
                        let questionAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(ORKChoiceAnswerStyle.SingleChoice, textChoices: questionTextChoices)
                        questionStep = ORKQuestionStep(identifier: questionIdentifier!, title: questionTitle, answer: questionAnswerFormat)

                        
                    default:
                        break
                    }
                    questionStep.optional = false
                    steps += [questionStep]
                }
            }
        }
    }
    
    return ORKOrderedTask(identifier: "ElegibilityTask", steps: steps)
}