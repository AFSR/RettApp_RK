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
    case Developer = 0
}

enum RowNumberSectionDeveloper: Int{
    case ResetConsent = 0, Test, ResetDefaults, Watch
}

// MARK: - UITableViewController
class DSDeveloperTableViewController: UITableViewController {
    
}

// MARK: - UITableViewDelegate
extension DSDeveloperTableViewController{
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath as IndexPath, animated: true)
        let sectionAndRow = (Section: indexPath.section, Row: indexPath.row)
        
        switch sectionAndRow {
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.ResetConsent.rawValue):
            KeychainWrapper.removeObject(kDSPasswordKey)
            alreadyParticipating = false
            assert(UserDefaults.standardUserDefaults().synchronize(), "Error while reseting consent")
            print("Consent reseted")
            break
            
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.Test.rawValue):
            let not = DSNotification()
            let next = not.nextDateForWeekday(desiredWeekday: 5, fromDate: NSDate())
            print(next.stringDateWithFormat())
            break
        
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.ResetDefaults.rawValue):
            DSUtils.resetUserDefaults()
            break
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.Watch.rawValue):
            let storyboard = UIStoryboard(name: "SensorData", bundle: Bundle.mainBundle)
            let viewController = storyboard.instantiateInitialViewController()
            self.navigationController!.pushViewController(viewController!, animated: true)
            break
        default:
            print("Section: \(indexPath.section) Row: \(indexPath.row)")
        }
    }
}
