//
//  DSElegibilityController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/15/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import ResearchKit
import SVProgressHUD
/**
The `DSElegibilityController
` defines how the ORKTaskViewController used for quiz will be handled.
*/
class DSElegibilityController: NSObject {
    
    /***/
    var parentViewController: DSOnboardingViewController!
    
    /***/
    var elegibilityViewController: ORKTaskViewController!
    
    /***/
    func createTaskWithParentViewController(parentViewController:DSOnboardingViewController, willShowTask showTask:Bool = true){
        self.elegibilityViewController = ORKTaskViewController(task:DSElegibilityTask, taskRunUUID: nil)
        self.elegibilityViewController.delegate = self
        self.parentViewController = parentViewController
        self.parentViewController.presentViewController(self.elegibilityViewController, animated: true, completion: nil)
    }
    
}

// MARK: - ORKTaskViewControllerDelegate
/***/
extension DSElegibilityController: ORKTaskViewControllerDelegate{
    
    func taskViewController(taskViewController: ORKTaskViewController, didFinishWithReason reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        switch(reason){
        case .Completed:
            if(self.isUserElegible(taskViewController)){
                self.elegibilityViewController.dismissViewControllerAnimated(true, completion: nil)
                self.parentViewController.proceedToConsent()
            }else{
                self.elegibilityViewController.dismissViewControllerAnimated(true, completion: nil)
                self.parentViewController.userFailedElegibility()
            }
            
        default:
            self.elegibilityViewController.dismissViewControllerAnimated(true, completion: nil)
            self.parentViewController.userFailedElegibility()
        }
    }
        
        /**
        Checks if the user is eligible to the study according to previous answers
        
        - parameter taskViewController: The quiz ORKTaskViewController
        
        - returns: Bool value indicating if the user is eligible or not
        */
        func isUserElegible(taskViewController: ORKTaskViewController) -> Bool {
            if let path = NSBundle.mainBundle().pathForResource(kDSElegibilityPlist, ofType: "plist") {
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