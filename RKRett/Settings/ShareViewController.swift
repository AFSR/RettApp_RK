//
//  ShareViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 18/09/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ShareViewController:UITableViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Initialisation du PeerId
        let displayName = "My Device"
        
        if (UserDefaults.standard.object(forKey: "kDisplayNameKey") != nil) {
            
            if ((UserDefaults.standard.object(forKey: "kDisplayNameKey") as! String) == displayName) {
                let peerIDData = UserDefaults.standard.object(forKey: "kPeerIDKey") as! Data
                let peerID = NSKeyedUnarchiver.unarchiveObject(with: peerIDData)
                print("Déjà vu:",peerID.debugDescription)
            } else {
                let peerID = MCPeerID(displayName: displayName)
                let peerIDData = NSKeyedArchiver.archivedData(withRootObject: peerID)
                UserDefaults.standard.set(peerIDData, forKey: "kPeerIDKey")
                UserDefaults.standard.set(displayName, forKey: "kDisplayNameKey")
                UserDefaults.standard.synchronize()
                print("Nouveau",peerID.debugDescription)
                
            }
            
        }else{
            let peerID = MCPeerID(displayName: displayName)
            let peerIDData = NSKeyedArchiver.archivedData(withRootObject: peerID)
            UserDefaults.standard.set(peerIDData, forKey: "kPeerIDKey")
            UserDefaults.standard.set(displayName, forKey: "kDisplayNameKey")
            UserDefaults.standard.synchronize()
            print("Brand New:",peerID.debugDescription)
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

