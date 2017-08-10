//
//  DSQuizTaskController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/21/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import ResearchKit

/**
The `DSQuisController` defines how the ORKTaskViewController used for quiz will be handled.
*/
class DSQuizController: NSObject {
    
    /***/
    var parentViewController: DSOnboardingViewController!
    
    /***/
    var quizViewController: ORKTaskViewController!
    
    /***/
    func createTaskParentViewController(parentViewController:DSOnboardingViewController, willShowTask showTask:Bool = true){
        self.quizViewController = ORKTaskViewController(task:DSQuizTask, taskRunUUID: nil)
        self.quizViewController.delegate = self
        self.parentViewController = parentViewController
        self.parentViewController.presentViewController(self.quizViewController, animated: true, completion: nil)
    }
}

// MARK: - ORKTaskViewControllerDelegate
/***/
extension DSQuizController: ORKTaskViewControllerDelegate{
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        switch(reason){
        case .Completed:
            if(self.isUserElegible(taskViewController)){
                self.quizViewController.dismissViewControllerAnimated(true, completion: nil)
                self.parentViewController.proceedToAuthorization()
            }else{
                self.quizViewController.dismissViewControllerAnimated(true, completion: nil)
                self.parentViewController.userFailedQuiz()
            }

        default:
            self.quizViewController.dismissViewControllerAnimated(true, completion: nil)
            self.parentViewController.userFailedQuiz()

        }
    }
    
    /**
    Checks if the user is eligible to the study according to previous answers
    
    - parameter taskViewController: The quiz ORKTaskViewController
    
    - returns: Bool value indicating if the user is eligible or not
    */
    func isUserElegible(taskViewController: ORKTaskViewController) -> (Bool){
        if let path = NSBundle.mainBundle().pathForResource(kDSQuizPlist, ofType: "plist") {
            if let plistDictionary = NSDictionary(contentsOfFile: path){
                if let questionsArray = plistDictionary.valueForKey("question") as? [AnyObject] {
                    for dictionary in questionsArray{
                        let questionDictionary = dictionary as! NSDictionary
                        let questionIdentifier = questionDictionary.valueForKey("identifier") as? String
                        let expectedAnswer = questionDictionary.valueForKey("expectedAnswer") as? String
                        
                        switch(dictionary.valueForKey("type") as! String){
                        case "Boolean":
                            if let stepResult = taskViewController.result.resultForIdentifier(questionIdentifier!) as? ORKStepResult{
                                if let booleanResult = stepResult.results?.first as? ORKBooleanQuestionResult{
                                    if(booleanResult.booleanAnswer != Int((expectedAnswer)!)){
                                        return false
                                    }
                                }
                            }
                        case "SingleChoice":
                            if let stepResult = taskViewController.result.resultForIdentifier(questionIdentifier!) as? ORKStepResult{
                                if let textResult = stepResult.results?.first as? ORKChoiceQuestionResult{
                                    if((textResult.choiceAnswers?.first as! String) != expectedAnswer){
                                        return false
                                    }
                                }
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
        return true
    }
}