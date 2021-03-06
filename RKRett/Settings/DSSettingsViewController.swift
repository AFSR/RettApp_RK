//
//  SettingsViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 01/21/18.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import SVProgressHUD
import Buglife
import CoreData
import CloudKit

class DSSettingsViewController:UIViewController, UICloudSharingControllerDelegate{
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("Fail to save Share")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return NSLocalizedString("Tasks results", comment: "")
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var url:URL?
    var rowSendEmail = 1
    var sectionSendEmail:Int!
    var sectionShareDataTv:Int!
    var sectionDeveloper:Int!
    
    var settingsArray: [[[String]]] = []
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    
    var settingsSection = ["HealthKit", "Configure","Developer Section"]
    var settingsItems = [["Personal device of disease child", "Authorize HealthKit"],["Select Data"],["Report a bug"]]
    
    fileprivate enum SegueIdentifier:String{
        case SettingsDetail = "gotoSettingsDetail", ShareDataWithDoctor = "gotoShareDataWithDoctor"
        
        var description:String{
            return self.rawValue
        }
    }
    
    internal func getSettingsTableData(){
        
        let url = Bundle.main.url(forResource:"DSSettings", withExtension: "plist")!
        do {
            let data = try Data(contentsOf:url)
            let sections = try PropertyListSerialization.propertyList(from: data, format: nil) as! [[[String]]]
            for (_, section) in sections.enumerated() {
                var sectionArray: [[String]] = []
                for item in section {
                    sectionArray.append(item)
                }
                settingsArray.append(sectionArray)
            }
        } catch {
            print("This error must never occur", error)
        }
        
    }
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.contentInset = .zero
        getSettingsTableData()
    }

    // MARK: - Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!){
        case SegueIdentifier.SettingsDetail.rawValue:
            let vc = segue.destination as! DSSettingsDetailController
            vc.section = sender as! DSSettingsSection
        default:
            print("Identifier: \(String(describing: segue.identifier))")
        }
    }
    

}

// MARK: - UITableViewDelegate
extension DSSettingsViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func showHealthKitAlert(){
        let alertController: UIAlertController?
        let title = NSLocalizedString("You changed HealthKit permissions", comment: "")
        let msg = NSLocalizedString("Please, go to the Health App and give permissions back manually", comment: "")
        alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController!.addAction(action)
        self.present(alertController!, animated: true, completion: nil)
    }
    
    func shareData(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if UserDefaults.standard.value(forKey: "fatherRecordID") == nil {
            appDelegate.checkInitCKData()
        }else{
            
            if (UserDefaults.standard.value(forKey: "shareData") != nil) && (UserDefaults.standard.value(forKey: "shareData") as! Bool) && (UserDefaults.standard.value(forKey: "sharedRecordID") != nil) {
                let recordSharedID = CKRecord.ID(recordName: UserDefaults.standard.value(forKey: "sharedRecordID") as! String)
                let sharedRecord = CKShare(recordType: "TaskAnswer", recordID: recordSharedID)
                let sharingController = UICloudSharingController(share: sharedRecord, container: CKContainer.default())
                sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
                sharingController.delegate = self
                self.parent?.present(sharingController, animated: true, completion: nil)
                print("Parent record is created")
                
            }else{
                
                let ckRecordZoneID = CKRecordZone.ID(zoneName: "records", ownerName: CKCurrentUserDefaultName)
                let ckRecordID = CKRecord.ID(recordName: UserDefaults.standard.value(forKey: "fatherRecordID") as! String, zoneID: ckRecordZoneID)
                let recordToSave = CKRecord(recordType: "TaskAnswer", recordID: ckRecordID)
                let share = CKShare(rootRecord: recordToSave)
                let sharingController = UICloudSharingController(preparationHandler: {(UICloudSharingController, handler:
                    @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                    let modifyOp = CKModifyRecordsOperation(recordsToSave:[share], recordIDsToDelete: nil)
                    modifyOp.modifyRecordsCompletionBlock = { (record, recordID, error) in
                        handler(share, CKContainer.default(), error)
                        print("Record saved in sharing process:",record?.count)
                        if let record = record{
                            UserDefaults.standard.set(record.first?.recordID.recordName, forKey: "sharedRecordID")
                            UserDefaults.standard.set(true, forKey: "shareData")
                        }
                    }
                    appDelegate.privateDB.add(modifyOp)
                })
                sharingController.availablePermissions = [.allowReadWrite, .allowPrivate]
                sharingController.delegate = self
                
                self.parent?.present(sharingController, animated: true, completion: nil)
                print("Shared record is created")
                print(UserDefaults.standard.value(forKey: "fatherRecordID"))
                
            }
            
            print("---",UserDefaults.standard.value(forKey: "shareData"),UserDefaults.standard.value(forKey: "sharedRecordID"))
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch settingsArray[indexPath.section][indexPath.row + 1][2] {
        case "authorizeHK":
            print("HealthKit")
        case "printData":
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: "showPDF", sender: self)
            print("Print Data")
        case "shareData":
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            shareData()
            print("Share Data")
        case "selectData":
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: "viewDashboardConf", sender: self)
        case "reportBug":
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            Buglife.shared().presentReporter()
        case "defineTreatment":
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: "viewPersonalTreatment", sender: self)
        case "deleteData":
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.clearCoreDataRecords()
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            print("Delete local data")
        case "deleteRemoteData":
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.clearCloudKitRecords(recordType: "TaskAnswer")
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            print("Delete remote data")
        default:
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
        
    }
}

// MARK: - UITableViewDataSource
extension DSSettingsViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsArray.count
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingsArray[section].count - 1
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsArray[section][0][0]
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let identifier:String = settingsArray[indexPath.section][indexPath.row + 1][1]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = settingsArray[indexPath.section][indexPath.row + 1][0]
        
        if identifier == "ToggleCell" {
            let cell2 = cell as! ToggleCell
            cell2.id = settingsArray[indexPath.section][indexPath.row + 1][2]
            
            if settingsArray[indexPath.section][indexPath.row + 1][2] == "authorizeHK"{
                delegate.healthStore.authorizationStatus(for: )
                if delegate.healthManager.isAuthorized {
                    print("HK Authorized")
                    cell2.switchToggle.isOn = true
                }else{
                    print("HK Not Authorized")
                    cell2.switchToggle.isOn = false
                }
            }
            
            if settingsArray[indexPath.section][indexPath.row + 1][2] == "shareData"{
                if (UserDefaults.standard.value(forKey: "shareData") != nil) && (UserDefaults.standard.value(forKey: "shareData") as! Bool){
                    cell2.switchToggle.isOn = true
                }else{
                    cell2.switchToggle.isOn = false
                }
            }
            
            cell2.delegate = self
            return cell2
        }else{
            return cell
        }
        
        
    }
    
}


extension DSSettingsViewController:ToggleCellDelegate{
    
    func switchValueIsChanged(_ sender: ToggleCell){
        
        if sender.switchToggle.isOn{
            
            if sender.id == "personalDevice"{
                let indexPath = IndexPath(row: (tableView.indexPath(for: sender)?.row)! + 1, section: (tableView.indexPath(for: sender)?.section)!)
                tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = true
                tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor.black
                
            }
            
        }else{
            if sender.id == "personalDevice"{
                print(sender.id)
                let indexPath = IndexPath(row: (tableView.indexPath(for: sender)?.row)! + 1, section: (tableView.indexPath(for: sender)?.section)!)
                
                let cellHK = tableView.cellForRow(at: indexPath) as! ToggleCell
                
                tableView.cellForRow(at: indexPath)?.isUserInteractionEnabled = false
                tableView.cellForRow(at: indexPath)?.textLabel?.textColor = UIColor.lightGray
                
                if delegate.healthManager.isAuthorized{
                    let alert = UIAlertController(title: "Autorisation HealthKit", message: "Voulez-vous retirer l'autorisation HealthKit?", preferredStyle: .alert)
                    
                    
                    alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: {
                        
                        action in print("HKRemove")
                        cellHK.switchToggle.setOn(false, animated: true)
                    }))
                    alert.addAction(UIAlertAction(title: "Non", style: .cancel, handler: {
                        action in print("HKRemain")
                        
                    } ))
                    
                    present(alert, animated: true)
                }
                
            }
            
        }
        tableView.reloadData()
    }
}


