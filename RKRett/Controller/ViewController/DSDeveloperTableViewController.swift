//
//  DSDeveloperTableViewController.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/25/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

// MARK: - Enums
enum Section: Int{
    case developer = 0
}

enum RowNumberSectionDeveloper: Int{
    case resetConsent = 0, test, resetDefaults, watch
}

// MARK: - UITableViewController
class DSDeveloperTableViewController: UITableViewController {
    
}

// MARK: - UITableViewDelegate
extension DSDeveloperTableViewController{
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        let sectionAndRow = (Section: indexPath.section, Row: indexPath.row)
        
        switch sectionAndRow {
        case (Section: Section.developer.rawValue, Row: RowNumberSectionDeveloper.resetConsent.rawValue):
            
            //KeychainWrapper.removeObjectForKey(kDSPasswordKey as! String)
            alreadyParticipating = false
            assert(UserDefaults.standard.synchronize(), "Error while reseting consent")
            print("Consent reseted")
            break
            
        case (Section: Section.developer.rawValue, Row: RowNumberSectionDeveloper.test.rawValue):
            let not = DSNotification()
            let next = not.nextDateForWeekday(5, fromDate: Date())
            print(next.description)
            break
        
        case (Section: Section.developer.rawValue, Row: RowNumberSectionDeveloper.resetDefaults.rawValue):
            DSUtils.resetUserDefaults()
            break
        case (Section: Section.developer.rawValue, Row: RowNumberSectionDeveloper.watch.rawValue):
            let storyboard = UIStoryboard(name: "SensorData", bundle: Bundle.main)
            let viewController = storyboard.instantiateInitialViewController()
            self.navigationController!.pushViewController(viewController!, animated: true)
            break
        default:
            print("Section: \(indexPath.section) Row: \(indexPath.row)")
        }
    }
}
