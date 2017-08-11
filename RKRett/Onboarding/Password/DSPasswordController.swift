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

class DSPasswordController:UIViewController {
    
    @IBOutlet var circles: [DSCircularView]!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var labelCreatePasscode: UILabel!
    
    fileprivate var password:String!
    let kPasswordUseTouchId = "kPasswordUseTouchId"
    
    var isTouchIdEnrolled: Bool{
        let context = LAContext()
        var error:NSError?
        return context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    var touchIdAuthenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.addTarget(self, action: #selector(passwordDidChange(sender:)), for: UIControlEvents.editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        labelCreatePasscode.alpha = 0.0
        useTouchId = isTouchIdEnrolled
        if (alreadyParticipating) {
            if !isTouchIdEnrolled {
                if useTouchId {
                    useTouchId = false // user disabled and the reenabled
                }
            }
        }
        setupTouchId()
    }
    
    
    func setupTouchId() {
        if alreadyParticipating {
            if useTouchId && isTouchIdEnrolled{
                authenticateUser()
            } else {
                passwordField.becomeFirstResponder()
            }
        } else {
            if isTouchIdEnrolled {
                showTouchIdAlert()
            } else {
                showLabel()
                passwordField.becomeFirstResponder()
            }
        }
    }
    
    func showLabel(){
        UIView.animate(withDuration: 0.5) {
            self.labelCreatePasscode.alpha = 1.0
        }
    }
    
    func authenticateUser() {
        // - FIXME: TA DANDO UMA RUIM MT TENSA. DEVE SER COM MOSTRAR A LABEL OU SETAR O FIRSTRESPONDER
        
        // Check if the device can evaluate the policy.
        let context = LAContext()
        let reasonString = NSLocalizedString("Authentication is needed to access the app.", comment:"")
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { (success: Bool, evalPolicyError: Error?) in
            DispatchQueue.main.sync() {
                self.touchIdAuthenticated = success
                if !alreadyParticipating {
                    useTouchId = false // if the user is new and the authentication failed then he cant use touchid
                }
                
                if success {
                    if alreadyParticipating {
                        self.gotoMainStoryboard()
                    } else {
                        self.showLabel()
                        self.passwordField.becomeFirstResponder()
                    }
                } else {
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.disappearHUDWithError), name: NSNotification.Name.SVProgressHUDDidDisappear, object: nil)
                    SVProgressHUD.setDefaultMaskType(.gradient)
                    SVProgressHUD.showError(withStatus: NSLocalizedString("Ops, an error occurred...", comment:""))
                    
                    if let error = evalPolicyError {
                        switch (error as NSError).code {
                        case LAError.systemCancel.rawValue:
                            print("Authentication was cancelled by the system")
                            
                        case LAError.userCancel.rawValue:
                            print("Authentication was cancelled by the user")
                            
                        case LAError.userFallback.rawValue:
                            print("User selected to enter custom password")
                            
                        default:
                            print("Authentication failed")
                        }
                    }
                }
            }
        }
    }
    
    func disappearHUDWithError(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.SVProgressHUDDidDisappear, object: nil)
        self.passwordField.becomeFirstResponder()
    }
    
    func passwordDidChange(sender: UITextField!){
        if let passwordLenght = sender.text?.characters.count{
            if (passwordLenght <= kDSOpenPasswordMaxSize){
                password = sender.text
                for (index, circle) in circles.enumerated(){
                    circle.backgroundColor = (index <= passwordLenght-1) ? UIColor.purple : UIColor.white
                }
                if (passwordLenght == kDSOpenPasswordMaxSize){
                    validatePassword()
                }
            }
        }
    }
    
    func validatePassword(){
        if let keyChainPassword = (KeychainWrapper.standard.string(forKey: kDSPasswordKey)) {
            (password == keyChainPassword) ? gotoMainStoryboard() : wrongPassword()
        } else {
            KeychainWrapper.standard.set(password, forKey: kDSPasswordKey)
            alreadyParticipating = true
            gotoMainStoryboard()
        }
    }
    
    func animateViews(block: @escaping (Bool)->()) {
        for (index,circle) in circles.enumerated() {
            let timeForCircle = 0.027
            UIView.animateKeyframes(withDuration: timeForCircle*Double(self.circles.count), delay: Double(index)*timeForCircle, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                circle.backgroundColor = .purple
            }, completion: block)
        }
    }
    
    func gotoMainStoryboard(){
        passwordField.resignFirstResponder()
        animateViews { (suc) -> () in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.gotoStoryboard(StoryboardName.Main.rawValue)
        }
    }
    
    func wrongPassword(){
        self.passwordField.text = ""
        for (index,circle) in self.circles.enumerated(){
            UIView.animateKeyframes(withDuration: 0.1, delay: Double(index)*0.05, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                circle.center.y -= 10
            }, completion: { (suc) -> Void in
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                    circle.center.y += 10
                    circle.backgroundColor =
                        .white
                }, completion:{ (suc: Bool) -> Void in
                    self.passwordField.becomeFirstResponder()
                })
            })
        }
    }
    
    func showTouchIdAlert(){
        let alertController = UIAlertController(title: "RKRett Touch ID", message: "Would you like to use Touch ID to access the app?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            useTouchId = false
            self.showLabel()
            self.passwordField.becomeFirstResponder()
        }))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            useTouchId = true
            self.authenticateUser()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

