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
    func createTaskWithParentViewController(_ parentViewController:DSOnboardingViewController, willShowTask showTask:Bool = true){
        self.elegibilityViewController = ORKTaskViewController(task:DSElegibilityTask, taskRun: nil)
        self.elegibilityViewController.delegate = self
        self.parentViewController = parentViewController
        self.parentViewController.present(self.elegibilityViewController, animated: true, completion: nil)
    }
    
}

// MARK: - ORKTaskViewControllerDelegate
/***/
extension DSElegibilityController: ORKTaskViewControllerDelegate{
    /**
     Tells the delegate that the task has finished.
     
     The task view controller calls this method when an unrecoverable error occurs,
     when the user has canceled the task (with or without saving), or when the user
     completes the last step in the task.
     
     In most circumstances, the receiver should dismiss the task view controller
     in response to this method, and may also need to collect and process the results
     of the task.
     
     @param taskViewController  The `ORKTaskViewController `instance that is returning the result.
     @param reason              An `ORKTaskViewControllerFinishReason` value indicating how the user chose to complete the task.
     @param error               If failure occurred, an `NSError` object indicating the reason for the failure. The value of this parameter is `nil` if `result` does not indicate failure.
     */
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        // code
        
    }

    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: NSError?) {
        switch(reason){
        case .completed:
            if(self.isUserElegible(taskViewController)){
                self.elegibilityViewController.dismiss(animated: true, completion: nil)
                self.parentViewController.proceedToConsent()
            }else{
                self.elegibilityViewController.dismiss(animated: true, completion: nil)
                self.parentViewController.userFailedElegibility()
            }
            
        default:
            self.elegibilityViewController.dismiss(animated: true, completion: nil)
            self.parentViewController.userFailedElegibility()
        }
    }
        
        /**
        Checks if the user is eligible to the study according to previous answers
        
        - parameter taskViewController: The quiz ORKTaskViewController
        
        - returns: Bool value indicating if the user is eligible or not
        */
        func isUserElegible(_ taskViewController: ORKTaskViewController) -> Bool {
            if let path = Bundle.main.path(forResource: kDSElegibilityPlist, ofType: "plist") {
                if let plistDictionary = NSDictionary(contentsOfFile: path){
                    if let questionsArray = plistDictionary.value(forKey: "question") as? [AnyObject] {
                        for dictionary in questionsArray{
                            let questionDictionary = dictionary as! NSDictionary
                            let questionIdentifier = questionDictionary.value(forKey: "identifier") as? String
                            let expectedAnswer = questionDictionary.value(forKey: "expectedAnswer") as? String
                            
                            switch(dictionary.value(forKey: "type") as! String){
                            case "Boolean":
                                if let stepResult = taskViewController.result.result(forIdentifier: questionIdentifier!) as? ORKStepResult{
                                    if let booleanResult = stepResult.results?.first as? ORKBooleanQuestionResult{
                                        if(booleanResult.booleanAnswer as! Int != Int((expectedAnswer) as! Int)){
                                            return false
                                        }
                                    }
                                }
                            case "SingleChoice":
                                if let stepResult = taskViewController.result.result(forIdentifier: questionIdentifier!) as? ORKStepResult{
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
