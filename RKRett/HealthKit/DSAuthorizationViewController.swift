//
//  DSHealthKitIntroViewController.swift
//  RKRett
//
//  Created by Marcus Vinicius Kuquert on 26/10/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import CoreMotion

class DSAuthorizationViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var lblHealthKit: UILabel!
    @IBOutlet weak var lblMotion: UILabel!
    @IBOutlet weak var lblNotifications: UILabel!
    @IBOutlet weak var lblAuthorizations: UILabel!
    
    @IBOutlet weak var btnHealthKit: UIButton!
    @IBOutlet weak var btnMotion: UIButton!
    @IBOutlet weak var btnNotifications: UIButton!
    
    var isHealthKitAuthorized = false
    var healthManager = HealthManager()
    var parentController: DSOnboardingViewController?
    
    //MARK: IBActions
    @IBAction func doneButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.parentController?.proceedToPassword()
    }
    
    @IBAction func healthKit(_ sender: AnyObject) {
        self.authorizeHealthKit()
        self.configureButtons()
    }
    
    @IBAction func motion(_ sender: AnyObject) {
        CMSensorRecorder().recordAccelerometer(forDuration: 100)
        if(!alreadyParticipating){
            showSettingsAlert()
        }
    }
    
    @IBAction func notifications(_ sender: AnyObject) {
        self.registerForPushForiOS7AndAbove()
        if(!alreadyParticipating){
            showSettingsAlert()
        }
    }
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(DSAuthorizationViewController.configureButtons), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        Bundle.main.loadNibNamed("DSAuthorizationViewController", owner: self, options: nil)
        for button in buttons{
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 5
        }
        self.configureButtons()
        let application = UIApplication.shared
        application.statusBarStyle = UIStatusBarStyle.default
        
        /*self.lblAuthorizations.text = NSLocalizedString("Authorizations", comment: "")
        self.lblHealthKit.text = NSLocalizedString("HealthKit Authorization", comment: "")
        self.lblMotion.text = NSLocalizedString("Motion Authorization", comment: "")
        self.lblNotifications.text = NSLocalizedString("Notifications Authorization", comment: "")
        
        self.btnHealthKit.setTitle(NSLocalizedString("Authorize HealthKit", comment: ""), for: UIControlState.normal)
        self.btnMotion.setTitle(NSLocalizedString("Authorize Motion", comment: ""), for: UIControlState.normal)
        self.btnNotifications.setTitle(NSLocalizedString("Authorize Notifications", comment: ""), for: UIControlState.normal)
        */
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: Internal functioons
    @objc func configureButtons(){
        
        //Configure healthKit button
        /* healthManager.readProfile({ (success: Bool, error: NSError?) -> Void in
            if error == nil{
                do{
                    let _ = try self.healthManager.healthKitStore.dateOfBirth()
                    let _ = try self.healthManager.healthKitStore.biologicalSex()
                    let _ = try self.healthManager.healthKitStore.bloodType()
                    self.isHealthKitAuthorized = true
                    
                }catch let error{
                    self.isHealthKitAuthorized = false
                    print("Any of Health info is nil \(error)")
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.buttons[0].enabled = !self.isHealthKitAuthorized
                })
            }else{
                print(error)
            }
        })
        */
        
        //Lecture du profil Health Manager
        //let profile = healthManager.readProfile()
        
        //Configure motion button
        buttons[1].isEnabled = !CMSensorRecorder.isAuthorizedForRecording()
        
        //Configure notificationsButton
        buttons[2].isEnabled = !UIApplication.shared.isRegisteredForRemoteNotifications
    }
    
    func registerForPushForiOS7AndAbove(){
        //UIApplication.shared
        let application = UIApplication.shared
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let notifSettings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
            application.registerUserNotificationSettings(notifSettings)
            application.registerForRemoteNotifications()
        }else{
            //Deprecated in iOS8
//            application.registerForRemoteNotificationTypes([.Sound, .Alert, .Badge])
        }
    }
    
    func authorizeHealthKit(){
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if error == nil {
                print("HealthKit authorization received.")
                if(!alreadyParticipating){
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.showHealthKitAlert()
                    })
                }
            }else{
                print("HealthKit authorization denied!")
                print(error?.description ?? "No error")
            }
        }
    }
    
    func showSettingsAlert(){
        let alertController: UIAlertController?
        let title = NSLocalizedString("You should change this permission on settings", comment: "")
        let msg = NSLocalizedString("Please, go to the Settings app and change the permissions for the app", comment: "")
        alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let gotoSettingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
            
            UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
        }
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController!.addAction(gotoSettingsAction)
        alertController!.addAction(action)
        
        self.present(alertController!, animated: true, completion: nil)
    }
    
    func showHealthKitAlert(){
        let alertController: UIAlertController?
        let title = NSLocalizedString("You changed HealthKit permissions", comment: "")
        let msg = NSLocalizedString("Please, go to the Health App and give permissions back manually", comment: "")
        alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController!.addAction(action)
        
        self.present(alertController!, animated: true, completion: nil)
    }
}
