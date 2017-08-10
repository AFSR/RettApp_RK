//
//  DSPasswordController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/15/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import LocalAuthentication
import SVProgressHUD

class DSPasswordController:UIViewController{
    
    @IBOutlet var circles: [DSCircularView]!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var labelCreatePasscode: UILabel!
    
    private var password:String!
    let kPasswordUseTouchId = "kPasswordUseTouchId"
    
    var isTouchIdEnrolled: Bool{
        let context = LAContext()
        var error:NSError?
        return context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    var touchIdAuthenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.addTarget(self, action: Selector("passwordDidChange:"), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        labelCreatePasscode.alpha = 0.0
        useTouchId = isTouchIdEnrolled
        if (alreadyParticipating){
            if !isTouchIdEnrolled{
                if useTouchId{
                    useTouchId = false // usuario desabilitou e depois habilitou
                }
            }
        }
        setupTouchId()
    }
    
    
    func setupTouchId(){
        if alreadyParticipating {
            if useTouchId && isTouchIdEnrolled{
                authenticateUser()
            }else{
                passwordField.becomeFirstResponder()
            }
        }else{
            if isTouchIdEnrolled{
                showTouchIdAlert()
            }else{
                showLabel()
                passwordField.becomeFirstResponder()
            }
        }
    }
    
    func showLabel(){
        UIView.animateWithDuration(0.5) {
            self.labelCreatePasscode.alpha = 1.0
        }
    }
    
    func authenticateUser() {
        // - FIXME: TA DANDO UMA RUIM MT TENSA. DEVE SER COM MOSTRAR A LABEL OU SETAR O FIRSTRESPONDER
        
        // Check if the device can evaluate the policy.
        let context = LAContext()
        let reasonString = NSLocalizedString("Authentication is needed to access the app.", comment:"")
        
        context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
            dispatch_sync(dispatch_get_main_queue()){
                self.touchIdAuthenticated = success
                if !alreadyParticipating{
                    useTouchId = false // if the user is new and the authentication failed then he cant use touchid
                }
                if success {
                    if alreadyParticipating{
                        self.gotoMainStoryboard()
                    }else{
                        self.showLabel()
                        self.passwordField.becomeFirstResponder()
                    }
                }else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("disappearHUDWithError"), name: SVProgressHUDDidDisappearNotification, object: nil)
                    SVProgressHUD.showErrorWithStatus(NSLocalizedString("Ops, an error occurred...", comment:""), maskType: SVProgressHUDMaskType.Gradient)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by the system")
                        
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by the user")
                        
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password")
                        
                    default:
                        print("Authentication failed")
                    }
                }
            }
        })
    }
    
    func disappearHUDWithError(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SVProgressHUDDidDisappearNotification, object: nil)
        self.passwordField.becomeFirstResponder()
    }
    
    func passwordDidChange(sender: UITextField!){
        if let passwordLenght = sender.text?.characters.count{
            if (passwordLenght <= kDSOpenPasswordMaxSize){
                password = sender.text
                for (index, circle) in circles.enumerate(){
                    circle.backgroundColor = (index <= passwordLenght-1) ? UIColor.purpleColor() : UIColor.whiteColor()
                }
                if (passwordLenght == kDSOpenPasswordMaxSize){
                    validatePassword()
                }
            }
        }
    }
    
    func validatePassword(){
        if let keyChainPassword = (KeychainWrapper.stringForKey(kDSPasswordKey)) {
            (password == keyChainPassword) ? gotoMainStoryboard() : wrongPassword()
        } else {
            KeychainWrapper.setString(password, forKey: kDSPasswordKey)
            alreadyParticipating = true
            gotoMainStoryboard()
        }
    }
    
    func animateViews(block: (Bool)->()){
        for (index,circle) in circles.enumerate(){
            let timeForCircle = 0.027
            UIView.animateKeyframesWithDuration(timeForCircle*Double(self.circles.count), delay: Double(index)*timeForCircle, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                circle.backgroundColor = .purpleColor()
                }, completion: block)
        }
    }
    
    func gotoMainStoryboard(){
        passwordField.resignFirstResponder()
        animateViews { (suc) -> () in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.gotoStoryboard(StoryboardName.Main.rawValue)
        }
    }
    
    func wrongPassword(){
        self.passwordField.text = ""
        for (index,circle) in self.circles.enumerate(){
            UIView.animateKeyframesWithDuration(0.1, delay: Double(index)*0.05, options: UIViewKeyframeAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                circle.center.y -= 10
                }, completion: { (suc) -> Void in
                    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                        circle.center.y += 10
                        circle.backgroundColor =
                            .whiteColor()
                        }, completion:{ (suc: Bool) -> Void in
                            self.passwordField.becomeFirstResponder()
                    })
            })
        }
    }
    
    func showTouchIdAlert(){
        let alertController = UIAlertController(title: "RKRett Touch ID", message: "Would you like to use Touch ID to access the app?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            useTouchId = false
            self.showLabel()
            self.passwordField.becomeFirstResponder()
        }))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            useTouchId = true
            self.authenticateUser()
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

