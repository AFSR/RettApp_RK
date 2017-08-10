//
//  DSQuizTask.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/21/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import ResearchKit

public var DSQuizTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    if let path = NSBundle.mainBundle().pathForResource(kDSQuizPlist, ofType: "plist") {
        if let plistDictionary = NSDictionary(contentsOfFile: path){
            if let instructionDictionary = plistDictionary.valueForKey("instruction") as? NSDictionary{
                let detailText = instructionDictionary.valueForKey("detailText") as? String
                let instructionStep = ORKInstructionStep(identifier: kQuizIntroductionStepIdentifier)
                instructionStep.detailText = detailText
                steps += [instructionStep]
            }
            
            if let questionsArray = plistDictionary.valueForKey("question") as? [AnyObject] {
                for dictionary in questionsArray{
                    // - FIXME: Use guard, tem que ver a syntax dessa porra
                    if let questionDictionary = dictionary as? NSDictionary{
                        if let questionTitle = questionDictionary.valueForKey("title") as? String{
                            if let questionIdentifier = questionDictionary.valueForKey("identifier") as? String{
                                var questionStep = ORKQuestionStep(identifier: questionIdentifier)
                                
                                switch(dictionary.valueForKey("type") as! String){
                                case "Boolean":
                                    questionStep = ORKQuestionStep(identifier: questionIdentifier, title: questionTitle, answer: ORKAnswerFormat.booleanAnswerFormat())
                                    
                                case "SingleChoice":
                                    var questionTextChoices = [ORKTextChoice]()
                                    for choice in questionDictionary.valueForKey("choices") as! [AnyObject]{
                                        questionTextChoices.append(ORKTextChoice(text: choice as! String, value: choice as! String))
                                    }
                                    let questionAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(ORKChoiceAnswerStyle.SingleChoice, textChoices: questionTextChoices)
                                    questionStep = ORKQuestionStep(identifier: questionIdentifier, title: questionTitle, answer: questionAnswerFormat)
                                    
                                default:
                                    break
                                }
                                questionStep.optional = false
                                steps += [questionStep]
                            }
                        }
                    }
                }
            }
        }
        
        //    steps += [visualConsentStep, sharingConsentStep, reviewConsentStep]
    }
    return ORKOrderedTask(identifier: "QuizTask", steps: steps)
}