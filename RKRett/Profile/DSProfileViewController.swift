//
//  DSProfileViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 29/04/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import Parse

class DSProfileViewController: UIViewController {

    var signupModeActive = true
    
    var currentUser = PFUser.current()
    
    func switchToLoggedInMode(){
        signUpOrLogInButton.isHidden = true
        emailLabel.isHidden = true
        passwordLabel.isHidden = true
        emailTextField.text = ""
        passwordTextField.text = ""
        emailTextField.isHidden = true
        passwordTextField.isHidden = true
        updateInformationsButton.isHidden = true
        logOutButton.isEnabled = true
        
        infoText.text = NSLocalizedString("You are logged in.", comment: "")
    }
    
    func switchMode(status: Bool){ //if status is true => switch to loggedin Mode
        signUpOrLogInButton.isHidden = status
        emailTextField.isEnabled = !status
        passwordTextField.isEnabled = !status
        updateInformationsButton.isHidden = !status
        
        logOutButton.isEnabled = status
        
        if status == true {
            infoText.text = NSLocalizedString("You are logged in.", comment: "")
        }else{
            emailTextField.text = ""
            passwordTextField.text = ""
            infoText.text = NSLocalizedString("You are about to sign up or log in with your credentials from AFSR. This will allow in the future to provide data from different devices and have access to your data from the web.", comment: "")
        }
        
    }
    
    
    @IBAction func signUpOrLogIn(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if emailTextField.text == "" || passwordTextField.text == ""{
            
            
            self.displayAlert(title: NSLocalizedString("Error", comment: ""), message:NSLocalizedString("Enter an email and a password.", comment: ""))
            
            
        } else {
            
            if (signupModeActive){
                
                let user = PFUser()
                
                user.username = emailTextField.text
                user.password = passwordTextField.text
                user.email = emailTextField.text
                
                print(user.username,"-",user.password,"-",user.email)
                
                user.signUpInBackground(block: {(success, error) in
                    
                    if let error = error {
                       
                        print("Error in background signin process")
                        PFUser.logInWithUsername(inBackground: self.emailTextField.text!, password: self.passwordTextField.text!, block: { (user, error) in
                            if user != nil{
                                self.switchMode(status: true)
                            }else{
                                var errorText = "Unknown error"
                                if let error = error {
                                    errorText = error.localizedDescription
                                    self.displayAlert(title: NSLocalizedString("Login impossible", comment: ""), message: errorText)
                                    
                                }
                                
                            }
                        })
                        
                    } else {
                        // Hooray! Let them use the app now.
                        self.switchMode(status: true)
                    }
                    
                })
                
            }else{
                
                PFUser.logInWithUsername(inBackground: emailTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                    if user != nil{
                        self.switchMode(status: true)
                    }else{
                        var errorText = "Unknown error"
                        if let error = error {
                            errorText = error.localizedDescription
                            self.displayAlert(title: NSLocalizedString("Login impossible", comment: ""), message: errorText)
                            
                        }
                        
                    }
                })
            }
            
            print("OK")
        }
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        PFUser.logOut()
        switchMode(status: false)
        self.view.endEditing(true)
        
    }
    
    
    @IBAction func updateInformations(_ sender: Any) {
        performSegue(withIdentifier: "gotoUpdateInfos", sender: self)
    }
    
    
    @IBOutlet weak var updateInformationsButton: UIButton!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var signUpOrLogInButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    
    func displayAlert(title:String, message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        logOutButton.isEnabled = false
        
        //Check if the User is already logged in
        if currentUser != nil {
            // Do stuff with the user
            switchMode(status: true)
            
            emailTextField.text = currentUser?.email
            passwordTextField.text = "*********"
            
            
        } else {
            // Show the signup or login screen
            switchMode(status: false)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
