//
//  LearnViewController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/21/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import SVProgressHUD
import Realm
import RealmSwift

extension UITableViewCell{
    
    func highlightWithColor(color:UIColor){
        let bgView = UIView(frame: CGRectMake(self.contentView.frame.width, 0, self.contentView.frame.width, self.contentView.frame.height))
        bgView.backgroundColor = color
        bgView.tag = kCellBackgroundViewTag
        print(bgView)
        UIView.beginAnimations("SelectedCell", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseIn)
        UIView.setAnimationDuration(1.0)
        self.selectedBackgroundView?.addSubview(bgView)
        bgView.frame = self.contentView.frame
        UIView.commitAnimations()
        print(bgView)
    }
    
}

let kCellBackgroundViewTag = 1

class DSLearnViewController:UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var learnMoreArray:[DSLearnMoreSection] = [DSLearnMoreSection]()
    var url:NSURL?
    var rowSendEmail = 1
    var sectionSendEmail:Int!
    var sectionShareDataTv:Int!
    var sectionDeveloper:Int!
    
    private enum SegueIdentifier:String{
        case LearnDetail = "gotoLearnDetail", ShareDataWithDoctor = "gotoShareDataWithDoctor"
        
        var description:String{
            return self.rawValue
        }
    }
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        loadLearnPlistSections()
        
        tableView.contentInset = UIEdgeInsetsZero
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier!){
        case SegueIdentifier.LearnDetail.rawValue:
            let vc = segue.destinationViewController as! DSLearnDetailController
            vc.section = sender as! DSLearnMoreSection
        default:
            print("Identifier: \(segue.identifier)")
        }
        
    }
    
    // MARK: - Functions
    func loadLearnPlistSections(){
        if let path = NSBundle.mainBundle().pathForResource(kDSLearnMorePlist, ofType: "plist"){
            if let sectionsArray = NSArray(contentsOfFile: path){
                for section in sectionsArray as! [NSDictionary]{
                    //                    print(section)
                    let dsSection = DSLearnMoreSection(fromDictionary: section)
                    self.learnMoreArray += [dsSection]
                }
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension DSLearnViewController:UITableViewDelegate{
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier(SegueIdentifier.LearnDetail.rawValue, sender: learnMoreArray[indexPath.section])
    }
}

// MARK: - UITableViewDataSource
extension DSLearnViewController: UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.learnMoreArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "learnMoreCell")
        
        createSideViewForCell(cell, withColor: .purpleColor())
        cell.textLabel?.text = self.learnMoreArray[indexPath.section].title
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 0.5
    }
    
}
