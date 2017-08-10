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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let sectionAndRow = (Section: indexPath.section, Row: indexPath.row)
        
        switch sectionAndRow {
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.ResetConsent.rawValue):
            KeychainWrapper.removeObjectForKey(kDSPasswordKey)
            alreadyParticipating = false
            assert(NSUserDefaults.standardUserDefaults().synchronize(), "Error while reseting consent")
            print("Consent reseted")
            break
            
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.Test.rawValue):
            let not = DSNotification()
            let next = not.nextDateForWeekday(5, fromDate: NSDate())
            print(next.stringDateWithFormat())
            break
        
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.ResetDefaults.rawValue):
            DSUtils.resetUserDefaults()
            break
        case (Section: Section.Developer.rawValue, Row: RowNumberSectionDeveloper.Watch.rawValue):
            let storyboard = UIStoryboard(name: "SensorData", bundle: NSBundle.mainBundle())
            let viewController = storyboard.instantiateInitialViewController()
            self.navigationController!.pushViewController(viewController!, animated: true)
            break
        default:
            print("Section: \(indexPath.section) Row: \(indexPath.row)")
        }
    }
}
