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
    
    if let path = Bundle.main.path(forResource: kDSElegibilityPlist, ofType: "plist") {
        if let plistDictionary = NSDictionary(contentsOfFile: path){
            if let instructionDictionary = plistDictionary.value(forKey: "instruction") as? NSDictionary{
                let detailText = instructionDictionary.value(forKey: "detailText") as? String
                let instructionStep = ORKInstructionStep(identifier: kQuizIntroductionStepIdentifier)
                instructionStep.detailText = detailText
                steps += [instructionStep]
            }
            if let questionsArray = plistDictionary.value(forKey: "question") as? Array<AnyObject> {
                for dictionary in questionsArray{
                    let questionDictionary = dictionary as! NSDictionary
                    let questionIdentifier = questionDictionary.value(forKey: "identifier") as? String
                    let questionTitle = questionDictionary.value(forKey: "title") as? String
                    
                    var questionStep = ORKQuestionStep()
                    
                    switch(dictionary.value(forKey: "type") as! String){
                    case "Boolean":
                        questionStep = ORKQuestionStep(identifier: questionIdentifier!, title: questionTitle, answer: ORKAnswerFormat.booleanAnswerFormat())
                        
                    case "SingleChoice":
                        var questionTextChoices = [String]()
                        for choice in questionDictionary.value(forKey: "choices") as! Array<AnyObject>{
                            questionTextChoices.append(choice as! String)
                        }
                        let questionAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: ORKChoiceAnswerStyle.singleChoice, textChoices: questionTextChoices!)
                        questionStep = ORKQuestionStep(identifier: questionIdentifier!, title: questionTitle, answer: questionAnswerFormat)

                        
                    default:
                        break
                    }
                    questionStep.isOptional = false
                    steps += [questionStep]
                }
            }
        }
    }
    
    return ORKOrderedTask(identifier: "ElegibilityTask", steps: steps)
}
