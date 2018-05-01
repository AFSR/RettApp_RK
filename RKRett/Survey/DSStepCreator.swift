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
    static var defaultStep:ORKQuestionStep = ORKQuestionStep(identifier: DSStepCreator.kDefaultStepIdentifier, title: DSStepCreator.kDefaultStepTitle, answer: ORKNumericAnswerFormat(style: ORKNumericAnswerStyle.decimal, unit: DSStepCreator.kDefaultStepAnswerUnit))
    
    
    //MARK: - Crate Question Step from Dictionary
    static func createQuestionStepUsingDictionary(_ dictionary:NSDictionary) -> ORKStep{
        var step:ORKStep
        
        let answerType:String = dictionary.value(forKey: PlistFile.Task.Question.AnswerType.rawValue) as! String
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
        
        if let optional = dictionary.object(forKey: PlistFile.Task.Question.Optional.rawValue) as? Bool{
            step.isOptional = optional
        } else {
            step.isOptional = false
        }
        
        
        return step
    }
    
    
    //MARK: - Query Step - acho que vai sair
    fileprivate static func createQueryStepUsingDictionary(_ dictionary:NSDictionary) -> ORKQuestionStep{
        let step:ORKQuestionStep = ORKQuestionStep(identifier: "Query Step Identifier", title: "Query Step Title", answer: ORKBooleanAnswerFormat())
        return step
    }
    
    //MARK: - Numeric Step - used for blood pressure, temperature
    fileprivate static func createNumericQuestionStepUsingDictionary(_ dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        if let answerUnit = dictionary.object(forKey: PlistFile.Task.Question.AnswerUnit.rawValue) as? String{
            let answerFormat:ORKNumericAnswerFormat = ORKNumericAnswerFormat(style: ORKNumericAnswerStyle.decimal, unit: answerUnit)
            
            
            if let answerRangeDic = dictionary.object(forKey: PlistFile.Task.Question.AnswerRange.Key.rawValue) as? NSDictionary,
                let minimum = answerRangeDic.value(forKey: PlistFile.Task.Question.AnswerRange.Minimum.rawValue) as? NSNumber,
                let maximum = answerRangeDic.value(forKey: PlistFile.Task.Question.AnswerRange.Maximum.rawValue) as? NSNumber{
                    answerFormat.minimum = minimum
                    answerFormat.maximum = maximum
                    print("Erro ao pegar o maximo")
            }else{
                assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createQueryStepUsingDictionary")
            }
            let questionIdentifier = dictionary.object(forKey: PlistFile.Task.Question.QuestionID.rawValue) as! String
            let prompt = dictionary.object(forKey: PlistFile.Task.Question.Prompt.rawValue) as! String
            step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createQueryStepUsingDictionary")
            step = ORKQuestionStep(identifier: "Numeric Question Step Identifier")
        }
        
        return step
    }
    
    //MARK: - Text Step - used to collect subjective input
    fileprivate static func createTextQuestionStepUsingDictionary(_ dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        if let questionIdentifier = dictionary.object(forKey: PlistFile.Task.Question.QuestionID.rawValue) as? String,
            let prompt = dictionary.object(forKey: PlistFile.Task.Question.Prompt.rawValue) as? String{
                
                let answerFormat = ORKTextAnswerFormat(maximumLength: kTextAnswerMaxLength)
                step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createImageChoiceStepUsingDictionary")
            step = ORKQuestionStep(identifier: "Text Question Step Identifier")
        }
        
        return step
    }
    
    //MARK: - Introduction Step - used to give instructions before presenting the step itself
    fileprivate static func createIntroductionStepUsingDictionary(_ dictionary:NSDictionary) -> ORKInstructionStep{
        var step:ORKInstructionStep
        if let detailText = dictionary.object(forKey: PlistFile.Task.Question.Prompt.rawValue) as? String,
            let questionIdentifier = dictionary.object(forKey: PlistFile.Task.Question.QuestionID.rawValue) as? String{
                
                step = ORKInstructionStep(identifier: questionIdentifier)
                step.detailText = detailText
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createImageChoiceStepUsingDictionary")
            step = ORKInstructionStep(identifier: "Text Question Step Identifier")
        }
        return step
    }
    
    //MARK: - Image Choice Step - the user must choose between images representing a value(NSNumber)
    fileprivate static func createImageChoiceStepUsingDictionary(_ dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        var imageChoices = [ORKImageChoice]()
        
//        let answerUnit = dictionary.objectForKey(PlistFile.Task.Question.AnswerType.rawValue) as! String
        
        if let imageChoiceArray = dictionary.object(forKey: PlistFile.Task.Question.ImageChoice.Key.rawValue) as? [NSDictionary]{
            var imageChoice:ORKImageChoice
            for imageChoiceDic in imageChoiceArray{
                if let normalImageName = imageChoiceDic.object(forKey: PlistFile.Task.Question.ImageChoice.NormalImage.rawValue) as? String,
                    let normalImage = UIImage(named: normalImageName),
                    let selectedImageName = imageChoiceDic.object(forKey: PlistFile.Task.Question.ImageChoice.SelectedImage.rawValue) as? String,
                    let selectedImage = UIImage(named: selectedImageName),
                    let imageText = imageChoiceDic.object(forKey: PlistFile.Task.Question.ImageChoice.Text.rawValue) as? String,
                    let imageValue = imageChoiceDic.object(forKey: PlistFile.Task.Question.ImageChoice.Value.rawValue) as? NSNumber{
                        
                        imageChoice = ORKImageChoice(normalImage: normalImage, selectedImage: selectedImage, text: imageText, value: imageValue)
                        imageChoices.append(imageChoice)
                }else{
                    assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createImageChoiceStepUsingDictionary")
                }
            }
        }
        
        let answerFormat = ORKImageChoiceAnswerFormat(imageChoices: imageChoices)
        
        let questionIdentifier = dictionary.object(forKey: PlistFile.Task.Question.QuestionID.rawValue) as! String
        let prompt = dictionary.object(forKey: PlistFile.Task.Question.Prompt.rawValue) as! String
        
        step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        
        return step
    }
    
    //MARK: - Text Choice Step - the user must choose between multiple choices represented by a title and a detailed explanation
    fileprivate static func createTextChoiceStepUsingDictionary(_ dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        var textChoices = [ORKTextChoice]()
        
//        let answerUnit = dictionary.objectForKey(PlistFile.Task.Question.AnswerType.rawValue) as! String
        
        if let textChoiceArray = dictionary.object(forKey: PlistFile.Task.Question.TextChoice.Key.rawValue) as? [NSDictionary]{
            var textChoice:ORKTextChoice
            for textChoiceDic in textChoiceArray{
                if let text = textChoiceDic.object(forKey: PlistFile.Task.Question.TextChoice.Text.rawValue) as? String,
                    let detailText = textChoiceDic.object(forKey: PlistFile.Task.Question.TextChoice.DetailText.rawValue) as? String,
                    let value = textChoiceDic.object(forKey: PlistFile.Task.Question.TextChoice.Value.rawValue) as? NSNumber{
                    // - FIXME: Criar nova coluna de exclusividade
//                    let isExclusive = textChoiceDic.objectForKey(PlistFile.Task.Question.TextChoice.Value.rawValue) as? Bool{
                
                        textChoice = ORKTextChoice(text: text , value: value/*, exclusive: isExclusive*/)
                        textChoices.append(textChoice)
                }else{
                    assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createTextChoiceStepUsingDictionary")
                }
            }
        }
        let answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)
        
        let questionIdentifier = dictionary.object(forKey: PlistFile.Task.Question.QuestionID.rawValue) as! String
        let prompt = dictionary.object(forKey: PlistFile.Task.Question.Prompt.rawValue) as! String
        
        step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        
        return step
    }
    
    //MARK: - Text Choice Step - the user must choose between multiple choices represented by a title and a detailed explanation
    fileprivate static func createTimeOfDayStepUsingDictionary(_ dictionary:NSDictionary) -> ORKQuestionStep{
        var step:ORKQuestionStep
        
        if let questionIdentifier = dictionary.object(forKey: PlistFile.Task.Question.QuestionID.rawValue) as? String,
            let prompt = dictionary.object(forKey: PlistFile.Task.Question.Prompt.rawValue) as? String{
                
            let answerFormat = ORKTimeOfDayAnswerFormat(defaultComponents: nil)
                step = ORKQuestionStep(identifier: questionIdentifier, title: prompt, answer: answerFormat)
        }else{
            assertionFailure("Some value couldn't be unwrapped in DSStepCreator.createTimeOfDayStepUsingDictionary")
            step = ORKQuestionStep(identifier: "Time Of Day Step Identifier")
        }
        
        return step
    }
}
