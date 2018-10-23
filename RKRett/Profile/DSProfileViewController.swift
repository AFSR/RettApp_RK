//
//  DSProfileViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 29/04/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import CloudKit
import CoreData
import CryptoSwift

class DSProfileViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var updateInformationsButton: UIButton!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var signUpOrLogInButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logOutButton: UIBarButtonItem!
    @IBOutlet weak var inscriptionCodeLabel: UILabel!
    @IBOutlet weak var inscriptionCodeTextField: UITextField!

    
    var signupModeActive = true

    func displayAlert(title:String, message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func switchToLoggedInMode(){
        
        DispatchQueue.main.async {
            //signUpOrLogInButton.isHidden = true
            self.signUpOrLogInButton.isEnabled = false
            self.emailLabel.isEnabled = false
            self.passwordLabel.isEnabled = false
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
            self.emailTextField.isEnabled = false
            self.passwordTextField.isEnabled = false
            self.updateInformationsButton.isEnabled = false
            self.logOutButton.isEnabled = true
            self.inscriptionCodeLabel.isEnabled = true
            self.inscriptionCodeTextField.isEnabled = true
            
            
            self.infoText.text = NSLocalizedString("You are logged in.", comment: "")
        }
        
    }
    
    func switchMode(status: Bool){ //if status is true => switch to loggedin Mode
        
        DispatchQueue.main.async {
            self.signUpOrLogInButton.isEnabled = !status
            self.emailTextField.isEnabled = !status
            self.passwordTextField.isEnabled = !status
            self.updateInformationsButton.isEnabled = status
            self.inscriptionCodeLabel.isEnabled = !status
            self.inscriptionCodeTextField.isEnabled = !status
            self.logOutButton.isEnabled = status
            
            if status == true {
                self.infoText.text = NSLocalizedString("You are logged in.", comment: "")
            }else{
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
                self.infoText.text = NSLocalizedString("You are about to sign up or log in with your credentials from AFSR. This will allow in the future to provide data from different devices and have access to your data from the web.", comment: "")
            }
        }
        
        
        
    }
    
    
    @IBAction func signUpOrLogIn(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if emailTextField.text == "" || passwordTextField.text == "" || inscriptionCodeTextField.text == ""{
            
            
            self.displayAlert(title: NSLocalizedString("Error", comment: ""), message:NSLocalizedString("Enter an email, a password and a validation code.", comment: ""))
            
            
        } else {
            
            var userGranted = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            if (signupModeActive){
                
                let name = CKRecord(recordType: "AppUsers")
                
                name["username"] = emailTextField.text as! String
                name["password"] = passwordTextField.text?.md5()
                name["validationCode"] = inscriptionCodeTextField.text as! String
                let validationCode = inscriptionCodeTextField.text as! String
                
                
                let recordZone = CKRecordZone.init(zoneName: "records")
                
                //Move to backgroung task
                DispatchQueue.global(qos: .userInitiated).sync {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                    print(name["username"] as! String)
                    let predicate = NSPredicate(format: "(username = %@) AND (validationCode = %@)", name["username"] as! String, validationCode)
                    let query = CKQuery(recordType: "AppUsers", predicate: predicate)
                    
                    let queryOperation = CKQueryOperation(query: query)
                    
                    queryOperation.recordFetchedBlock = { record in
                        if record.value(forKey: "password") == nil{
                            //The user is granted and connect for the first time
                            userGranted = true
                            let uuid = UUID().uuidString
                            name["UUID"] = uuid
                            print("The user is granted and connect for the first time")
                            appDelegate.publicDB.save(name, completionHandler: { savedRecord, error in
                                if error == nil {
                                    // Hooray! Let them use the app now.
                                    self.switchMode(status: true)
                                    print("OK for CK: ", savedRecord?.description)
                                    UserDefaults.standard.set(uuid, forKey: "LogUUID")
                                } else {
                                    print("Error: ",error)
                                }
                            })
                        }else{
                            let predicatePassword = NSPredicate(format: "(username = %@) AND (validationCode = %@) AND (passsword = %@)", name["username"] as! String, validationCode, name["password"] as! String)
                            let queryPassword = CKQuery(recordType: "AppUsers", predicate: predicatePassword)
                            
                            let queryOperationPwd = CKQueryOperation(query: queryPassword)
                            
                            queryOperationPwd.recordFetchedBlock = { record in
                                 //The user is granted and already loggedin with goodPassword
                                print("The user is granted and already loggedin with good Password")
                                userGranted = true
                                let uuid = record.value(forKey: "UUID") as! String
                                UserDefaults.standard.set(uuid, forKey: "LogUUID")
                                self.switchMode(status: true)
                            }
                            
                            queryOperationPwd.queryCompletionBlock = { [weak self] (cursor, error) in
                                if cursor == nil{
                                    //The user is granted, already loggedIn but with Incorrect Password
                                    print("The user is granted and already loggedin but with incorrect Password")
                                    userGranted = false
                                    self?.switchMode(status: false)
                                    self?.displayAlert(title: "Wrong Password", message: "You entered a wrong password")
                                }
                            }
                            
                            appDelegate.publicDB.add(queryOperationPwd)
                        }
                    }
                    
                    queryOperation.queryCompletionBlock = { [weak self] (cursor, error) in
                        if error != nil{
                            self?.displayAlert(title: NSLocalizedString("Problem", comment: ""), message: NSLocalizedString("Server connection issue.", comment: ""))
                        }else{
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                    
                    appDelegate.publicDB.add(queryOperation)
                    
                }
                
             }else{
                //Log In
                
                let name = CKRecord(recordType: "AppUsers")
                
                name["username"] = emailTextField.text as! String
                name["password"] = passwordTextField.text?.md5()
                name["validationCode"] = inscriptionCodeTextField.text as! String
                let validationCode = inscriptionCodeTextField.text as! String
                
                let recordZone = CKRecordZone.init(zoneName: "records")
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                let predicate = NSPredicate(format: "(username = %@) AND (validationCode = %@) AND (password = %@)", name["username"] as! String, validationCode,name["password"] as! String)
                let query = CKQuery(recordType: "AppUsers", predicate: predicate)
                
                let queryOperation = CKQueryOperation(query: query)
                
                queryOperation.recordFetchedBlock = { record in
                    userGranted = true
                    let uuid = record.value(forKey: "UUID") as! String
                    UserDefaults.standard.set(uuid, forKey: "LogUUID")
                    self.switchMode(status: true)
                }
                
                queryOperation.queryCompletionBlock = { [weak self] (cursor, error) in
                    if error != nil{
                        self?.displayAlert(title: NSLocalizedString("Problem", comment: ""), message: NSLocalizedString("Server connection issue.", comment: ""))
                    }else{
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
                
                appDelegate.publicDB.add(queryOperation)
                
            }
     
        }
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        let uuid = UserDefaults.standard.string(forKey: "LogUUID") ?? ""
        print("UUID saved in UserDefaults was: ",uuid)
        
        UserDefaults.standard.set("", forKey: "LogUUID")
        
        switchMode(status: false)
        self.view.endEditing(true)
        
        print("User logged out")
        
    }
    
    
    @IBAction func updateInformations(_ sender: Any) {
        performSegue(withIdentifier: "gotoUpdateInfos", sender: self)
    }
    
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recordZone = CKRecordZone.init(zoneName: "records")
        
        let uuid = UserDefaults.standard.string(forKey: "LogUUID") ?? ""
        print("UUID saved in UserDefaults: ",uuid)
        
        let predicate = NSPredicate(format: "UUID == %@",uuid)
        
        print("Predicate: ",predicate.description)
        
        let query = CKQuery(recordType: "AppUsers", predicate: predicate)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.privateDB.perform(query, inZoneWith: nil, completionHandler: {
            (records, error) -> Void in
            guard let records = records else {
                print("Error querying records: ", error)
                return
            }
            print(records.count)
            if records.count == 1{
                print("User aldready logged In")
                self.switchMode(status: true)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }else{
                self.switchMode(status: false)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
        })
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        inscriptionCodeTextField.delegate = self
        
        
        // Do any additional setup after loading the view.
        logOutButton.isEnabled = false
        
        //Check if the User is already logged in
//        if currentUser != nil {
//            // Do stuff with the user
//            switchMode(status: true)
//
//            emailTextField.text = currentUser?.email
//            passwordTextField.text = "*********"
//
//        } else {
//            // Show the signup or login screen
//            switchMode(status: false)
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
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
