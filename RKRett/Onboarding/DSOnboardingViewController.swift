//
//  DSOnboardingViewController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/15/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit

class DSOnboardingViewController: UIViewController {
    
    var consentController:DSConsentController!
    var elegibilityController:DSElegibilityController!
    var quizController:DSQuizController!
    var passwordController:DSPasswordController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.proceedToElegibility()
        //        self.proceedToConsent()
        self.proceedToAuthorization()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    func proceedToElegibility(){
        elegibilityController = DSElegibilityController()
        self.elegibilityController.createTaskWithParentViewController(self)
    }
    
    func proceedToConsent(){
        self.consentController = DSConsentController()
        self.consentController.createTaskWithParentViewController(self)
    }
    
    func proceedToQuiz(){
        self.quizController = DSQuizController()
        self.quizController.createTaskParentViewController(self)
    }
    
    func proceedToAuthorization(){
        let authorizationVC = DSAuthorizationViewController()
        authorizationVC.parentController = self
        self.presentViewController(authorizationVC, animated: true, completion: nil)
    }
    
    func proceedToPassword(){
        self.passwordController = DSPasswordController()
        let sb = UIStoryboard(name: StoryboardName.Password.rawValue, bundle: nil)
        if let vc = sb.instantiateInitialViewController(){
            self.presentViewController(vc, animated: true , completion: nil)
        }
    }
    
    func goToRoot(){
        self.consentController.consentViewController.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func userFailedElegibility(){
        let alertTitle = NSLocalizedString("Sorry", comment: "")
        let alertMessage = NSLocalizedString("You are not elegible for this study, please uninstall the app.", comment: "")
        let alertController = UIAlertController(title: alertTitle , message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .Default, handler: { (action) -> Void in
            self.performSegueWithIdentifier("returnToStart", sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Try again",comment: ""), style:.Default, handler: { (action) -> Void in
            self.proceedToElegibility()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func userFailedConsent(){
        let alertTitle = NSLocalizedString("Sorry", comment: "")
        let alertMessage = NSLocalizedString("It is mandatory that you go through and accept the consent.", comment: "")
        let alertController = UIAlertController(title: alertTitle , message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Leave", comment: ""), style: .Default, handler: { (action) -> Void in
            self.performSegueWithIdentifier("returnToStart", sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Try again",comment: ""), style:.Default, handler: { (action) -> Void in
            self.proceedToConsent()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func userFailedQuiz(){
        let alertTitle = NSLocalizedString("Sorry", comment: "")
        let alertMessage = NSLocalizedString("It seems that you did not understand the purpose of this study.", comment: "")
        let alertController = UIAlertController(title: alertTitle , message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Review consent", comment: ""), style: .Default, handler: { (action) -> Void in
            self.proceedToConsent()
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Try again",comment: ""), style:.Default, handler: { (action) -> Void in
            self.proceedToQuiz()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}