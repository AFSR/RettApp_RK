//
//  SettingsViewController.swift
//  RKRett
//
//  Created by Julien Fieschi on 01/21/18.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import SVProgressHUD
import Realm
import RealmSwift
import Buglife

extension UITableViewCell {
    
//    func highlightWithColor(_ color: UIColor) {
//        let bgView = UIView(frame: CGRect(x: contentView.frame.width, y: 0, width: contentView.frame.width, height: contentView.frame.height))
//        bgView.backgroundColor = color
//        bgView.tag = kCellBackgroundViewTag
//        print(bgView)
//        UIView.beginAnimations("SelectedCell", context: nil)
//        UIView.setAnimationCurve(UIViewAnimationCurve.easeIn)
//        UIView.setAnimationDuration(1.0)
//        selectedBackgroundView?.addSubview(bgView)
//        bgView.frame = contentView.frame
//        UIView.commitAnimations()
//        print(bgView)
//    }
    
}

//let kCellBackgroundViewTag = 1

class DSSettingsViewController:UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var settingsArray:[DSSettingsSection] = [DSSettingsSection]()
    var url:URL?
    var rowSendEmail = 1
    var sectionSendEmail:Int!
    var sectionShareDataTv:Int!
    var sectionDeveloper:Int!
    
    //var healthManager = HealthManager()
    

    
    fileprivate enum SegueIdentifier:String{
        case SettingsDetail = "gotoSettingsDetail", ShareDataWithDoctor = "gotoShareDataWithDoctor"
        
        var description:String{
            return self.rawValue
        }
    }
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        loadSettingsPlistSections()
        
        tableView.contentInset = .zero
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch(segue.identifier!){
        case SegueIdentifier.SettingsDetail.rawValue:
            let vc = segue.destination as! DSSettingsDetailController
            vc.section = sender as! DSSettingsSection
        default:
            print("Identifier: \(String(describing: segue.identifier))")
        }
        
    }
    
    // MARK: - Functions
    func loadSettingsPlistSections(){
        if let path = Bundle.main.path(forResource: kDSSettingsPlist, ofType: "plist"){
            if let sectionsArray = NSArray(contentsOfFile: path){
                for section in sectionsArray as! [NSDictionary]{
                    //                    print(section)
                    let dsSection = DSSettingsSection(fromDictionary: section)
                    self.settingsArray += [dsSection]
                }
                self.tableView.reloadData()
            }
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
        alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController!.addAction(action)
        
        self.present(alertController!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section{
        
        case 0:
            
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.healthManager.authorizeHealthKit { (authorized,  error) -> Void in
                if error == nil {
                    print("HealthKit authorization received.")
                    if(!alreadyParticipating){
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.present(appDelegate.healthManager.showHealthKitAlert()!, animated: true, completion: nil)
                            //self.showHealthKitAlert()
                        })
                    }
                }else{
                    print("HealthKit authorization denied!")
                    print(error?.description ?? "No error")
                }
            }
            
        case 1:
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            Buglife.shared().start(withAPIKey: "aqXSsXuIBBCd4BAu9tdcVwtt")
            Buglife.shared().presentReporter()
            
        default:
            
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            performSegue(withIdentifier: SegueIdentifier.SettingsDetail.rawValue, sender: settingsArray[indexPath.section])
            
        }
        
    }
}

// MARK: - UITableViewDataSource
extension DSSettingsViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
        
        //createSideViewForCell(cell, withColor: .purple)
        cell.textLabel?.text = self.settingsArray[indexPath.section].title
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 0.5
    }
    
}