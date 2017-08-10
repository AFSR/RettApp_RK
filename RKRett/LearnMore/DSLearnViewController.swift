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

extension UITableViewCell {
    
    func highlightWithColor(color: UIColor) {
        let bgView = UIView(frame: CGRect(x: contentView.frame.width, y: 0, width: contentView.frame.width, height: contentView.frame.height))
        bgView.backgroundColor = color
        bgView.tag = kCellBackgroundViewTag
        print(bgView)
        UIView.beginAnimations("SelectedCell", context: nil)
        UIView.setAnimationCurve(UIViewAnimationCurve.easeIn)
        UIView.setAnimationDuration(1.0)
        selectedBackgroundView?.addSubview(bgView)
        bgView.frame = contentView.frame
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
    
    fileprivate enum SegueIdentifier:String{
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
        
        tableView.contentInset = .zero
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch(segue.identifier!){
        case SegueIdentifier.LearnDetail.rawValue:
            let vc = segue.destination as! DSLearnDetailController
            vc.section = sender as! DSLearnMoreSection
        default:
            print("Identifier: \(String(describing: segue.identifier))")
        }
        
    }
    
    // MARK: - Functions
    func loadLearnPlistSections(){
        if let path = Bundle.main.path(forResource: kDSLearnMorePlist, ofType: "plist"){
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
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        performSegue(withIdentifier: SegueIdentifier.LearnDetail.rawValue, sender: learnMoreArray[indexPath.section])
    }
}

// MARK: - UITableViewDataSource
extension DSLearnViewController: UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.learnMoreArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "learnMoreCell")
        
        createSideViewForCell(cell: cell, withColor: .purple)
        cell.textLabel?.text = self.learnMoreArray[indexPath.section].title
        
        return cell
    }
    
    private func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 0.5
    }
    
}
