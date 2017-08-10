//
//  DSStepCreator.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit
import ResearchKit

/**
The `DSStepCreator` is used to create a step for a task based on a Dictionary.
*/
class DSStepCreator: NSObject {
    
    static let kDefaultStepIdentifier = "kDefaultStepIdentifier"
    static let kDefaultStepTitle = "kDefaultStepTitle"
    static let kDefaultStepAnswerUnit = "kDefaultStepAnswerUnit"
    static var defaultStep:ORKQuestionStep = ORKQuestionStep(identifier: DSStepCreator.kDefaultStepIdentifier, title: DSStepCreator.kDefaultStepTitle, answer: ORKNumericAnswerFormat(style: ORKNumericAnswerStyle.Decimal, unit: DSStepCreator.kDefaultStepAnswerUnit))
    
    
    //MARK: - Crate Question Step from Dictionary
    static func createQuestionStepUsingDictionary(dictionary:NSDictionary) -> ORKStep{
        var step:ORKStep
        
        let answerType:String = dictionary.valueForKey(PlistFile.Task.Question.AnswerType.rawValue) as! String
        switch(answerType){
        case DSTaskTypes.Number.rawValue:
            step = DSStepCreator.createNumericQuestionStepUsingDictionary(dictionary)
            
        case DSTaskTypes.Text.rawValue:
            step = DSStepCreator.createTextQuestionStepUsingDictionary(dictionary)
            
        case DSTaskTypes.Query.rawValue:
            step = DSStepCreator.createQueryStepUsingDictionary(dictionary)
            
        case DSTaskTypes.Introduction.rawValue:
            step = DSStepCreator.createIntroductionStepUsingDictionary(dictionary)
            
        case DSTaskTypes.ImageChoice.rawValue:
            step = DSStepCreator.createImageChoiceStepUsingDictionary(dictionary)
            
        case DSTaskTypes.TextChoice.rawValue:
            step = DSStepCreator.createTextChoiceStepUsingDictionary(dictionary)
            
        case DSTaskTypes.TimeOfDay.rawValue:
            step = DSStepCreator.createTimeOfDayStepUsingDictionary(dictionary)
            
        default:
            step = DSStepCreator.defaultStep
        }
        
        if let optional = dictionary.objectForKey(PlistFile.Task.Question.Optional.rawValue) as? Bool{
            step.optional = optional
        } else {
            step.optional = false
        }
        
        
        return step
    }
    
    
    //MARK: - Query Step - acho que vai sair
    private static func createQueryStepUsingDictionary(dictionary:NSDictionary) -> ORKQuestionStep{
        let step:ORKQuestionStep = ORKQuestionStep(identifier: "Query Step Identifier", title: "Query Step Title", answer: ORKBooleanAnswerFormat())
        return step
    }
    
    //MARK: - Numeric Step - used for blood pressure, temperature
    private static func createNumericQuestionStepUsingDictionary(dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        if let answerUnit = dictionary.objectForKey(PlistFile.Task.Question.AnswerUnit.rawValue) as? String{
            let answerFormat:ORKNumericAnswerFormat = ORKNumericAnswerFormat(style: ORKNumericAnswerStyle.Decimal, unit: answerUnit)
            
            
            if let answerRangeDic = dictionary.objectForKey(PlistFile.Task.Question.AnswerRange.Key.rawValue) as? NSDictionary,
                let minimum = answerRangeDic.valueForKey(PlistFile.Task.Question.AnswerRange.Minimum.rawValue) as? NSNumber,
                let maximum = answerRangeDic.valueForKey(PlistFile.Task.Question.AnswerRange.Maximum.rawValue) as? NSNumber{
                    answerFormat.minimum = minimum
                    answerFormat.maximum = maximum
                    print("Erro ao pegar o maximo")
            }else{
                assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createQueryStepUsingDictionary")
            }
            let questionIdentifier = dictionary.objectForKey(PlistFile.Task.Question.QuestionID.rawValue) as! String
            let prompt = dictionary.objectForKey(PlistFile.Task.Question.Prompt.rawValue) as! String
            step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createQueryStepUsingDictionary")
            step = ORKQuestionStep(identifier: "Numeric Question Step Identifier")
        }
        
        return step
    }
    
    //MARK: - Text Step - used to collect subjective input
    private static func createTextQuestionStepUsingDictionary(dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        if let questionIdentifier = dictionary.objectForKey(PlistFile.Task.Question.QuestionID.rawValue) as? String,
            let prompt = dictionary.objectForKey(PlistFile.Task.Question.Prompt.rawValue) as? String{
                
                let answerFormat = ORKTextAnswerFormat(maximumLength: kTextAnswerMaxLength)
                step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createImageChoiceStepUsingDictionary")
            step = ORKQuestionStep(identifier: "Text Question Step Identifier")
        }
        
        return step
    }
    
    //MARK: - Introduction Step - used to give instructions before presenting the step itself
    private static func createIntroductionStepUsingDictionary(dictionary:NSDictionary) -> ORKInstructionStep{
        var step:ORKInstructionStep
        if let detailText = dictionary.objectForKey(PlistFile.Task.Question.Prompt.rawValue) as? String,
            let questionIdentifier = dictionary.objectForKey(PlistFile.Task.Question.QuestionID.rawValue) as? String{
                
                step = ORKInstructionStep(identifier: questionIdentifier)
                step.detailText = detailText
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createImageChoiceStepUsingDictionary")
            step = ORKInstructionStep(identifier: "Text Question Step Identifier")
        }
        return step
    }
    
    //MARK: - Image Choice Step - the user must choose between images representing a value(NSNumber)
    private static func createImageChoiceStepUsingDictionary(dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        var imageChoices = [ORKImageChoice]()
        
//        let answerUnit = dictionary.objectForKey(PlistFile.Task.Question.AnswerType.rawValue) as! String
        
        if let imageChoiceArray = dictionary.objectForKey(PlistFile.Task.Question.ImageChoice.Key.rawValue) as? [NSDictionary]{
            var imageChoice:ORKImageChoice
            for imageChoiceDic in imageChoiceArray{
                if let normalImageName = imageChoiceDic.objectForKey(PlistFile.Task.Question.ImageChoice.NormalImage.rawValue) as? String,
                    let normalImage = UIImage(named: normalImageName),
                    let selectedImageName = imageChoiceDic.objectForKey(PlistFile.Task.Question.ImageChoice.SelectedImage.rawValue) as? String,
                    let selectedImage = UIImage(named: selectedImageName),
                    let imageText = imageChoiceDic.objectForKey(PlistFile.Task.Question.ImageChoice.Text.rawValue) as? String,
                    let imageValue = imageChoiceDic.objectForKey(PlistFile.Task.Question.ImageChoice.Value.rawValue) as? NSNumber{
                        
                        imageChoice = ORKImageChoice(normalImage: normalImage, selectedImage: selectedImage, text: imageText, value: imageValue)
                        imageChoices.append(imageChoice)
                }else{
                    assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createImageChoiceStepUsingDictionary")
                }
            }
        }
        
        let answerFormat = ORKImageChoiceAnswerFormat(imageChoices: imageChoices)
        
        let questionIdentifier = dictionary.objectForKey(PlistFile.Task.Question.QuestionID.rawValue) as! String
        let prompt = dictionary.objectForKey(PlistFile.Task.Question.Prompt.rawValue) as! String
        
        step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        
        return step
    }
    
    //MARK: - Text Choice Step - the user must choose between multiple choices represented by a title and a detailed explanation
    private static func createTextChoiceStepUsingDictionary(dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        var textChoices = [ORKTextChoice]()
        
//        let answerUnit = dictionary.objectForKey(PlistFile.Task.Question.AnswerType.rawValue) as! String
        
        if let textChoiceArray = dictionary.objectForKey(PlistFile.Task.Question.TextChoice.Key.rawValue) as? [NSDictionary]{
            var textChoice:ORKTextChoice
            for textChoiceDic in textChoiceArray{
                if let text = textChoiceDic.objectForKey(PlistFile.Task.Question.TextChoice.Text.rawValue) as? String,
                    let detailText = textChoiceDic.objectForKey(PlistFile.Task.Question.TextChoice.DetailText.rawValue) as? String,
                    let value = textChoiceDic.objectForKey(PlistFile.Task.Question.TextChoice.Value.rawValue) as? NSNumber{
                    // - FIXME: Criar nova coluna de exclusividade
//                    let isExclusive = textChoiceDic.objectForKey(PlistFile.Task.Question.TextChoice.Value.rawValue) as? Bool{
                
                        textChoice = ORKTextChoice(text: text, detailText: detailText, value: value/*, exclusive: isExclusive*/)
                        textChoices.append(textChoice)
                }else{
                    assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createTextChoiceStepUsingDictionary")
                }
            }
        }
        let answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.SingleChoice, textChoices: textChoices)
        
        let questionIdentifier = dictionary.objectForKey(PlistFile.Task.Question.QuestionID.rawValue) as! String
        let prompt = dictionary.objectForKey(PlistFile.Task.Question.Prompt.rawValue) as! String
        
        step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        
        return step
    }
    
    //MARK: - Text Choice Step - the user must choose between multiple choices represented by a title and a detailed explanation
    private static func createTimeOfDayStepUsingDictionary(dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        
        if let questionIdentifier = dictionary.objectForKey(PlistFile.Task.Question.QuestionID.rawValue) as? String,
            let prompt = dictionary.objectForKey(PlistFile.Task.Question.Prompt.rawValue) as? String{
                
                let answerFormat = ORKTimeOfDayAnswerFormat(defaultComponents: NSDateComponents())
                step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createTimeOfDayStepUsingDictionary")
            step = ORKQuestionStep(identifier: "Time Of Day Step Identifier")
        }
        
        return step
    }
}