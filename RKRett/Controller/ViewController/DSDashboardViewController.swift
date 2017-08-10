//
//  DSDashboardViewController.swift
//  RKRett
//
//  Created by Mateus Reckziegel on 9/16/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit

class DSDashboardViewController: UIViewController {
    //MARK: - Serialize/Deserialize Tuples
    typealias DSGraphIdentifierType = (taskId: String, questionId: String)
    typealias DSGraphIdentifierTypeDictionary = [String: String]
    
    let kQuestionsGraphArrayKey = "kQuestionsGraphArrayKey"
    let TaskIdKey = "taskId"
    let QuestionIdKey = "questionId"
    
    func serializeTuple(tuple: DSGraphIdentifierType) -> DSGraphIdentifierTypeDictionary {
        return [TaskIdKey : tuple.taskId, QuestionIdKey : tuple.questionId]
    }
    
    func deserializeDictionary(dictionary: DSGraphIdentifierTypeDictionary) -> DSGraphIdentifierType {
        return DSGraphIdentifierType(dictionary[TaskIdKey] as String!, dictionary[QuestionIdKey] as String!)
    }
    
    // -------------------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    var graphIdentifiers = [DSGraphIdentifierType]()
    var viewControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.registerNib(UINib(nibName: "CircularGraphCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CircularGraphCell")
        tableView.registerNib(UINib(nibName: "TimeBasedGraphCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TimeBasedGraphCell")
        
        if let unwrapped = NSUserDefaults.standardUserDefaults().objectForKey(kQuestionsGraphArrayKey) as? [DSGraphIdentifierTypeDictionary]{
            unwrapped.forEach({ (element) -> () in
                graphIdentifiers += [deserializeDictionary(element)]
            })
        }
        
        graphIdentifiers = getGraphIds()
        tableView.reloadData()
        configureSpotlightSearch()
    }
    
    func configureSpotlightSearch(){
        let myActivity = NSUserActivity(activityType: bundleId + "." + SpotlightSearchActions.Dashboard.rawValue)
        myActivity.title = SpotlightSearchActions.Dashboard.rawValue
        myActivity.eligibleForSearch = true
        myActivity.keywords = Set(arrayLiteral: "Dashboard", "Charts", "Graph", "Rett")
        myActivity.userInfo = ["type":SpotlightSearchActions.Dashboard.rawValue]

        self.userActivity = myActivity
        myActivity.eligibleForHandoff = false
        myActivity.becomeCurrent()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for vc in viewControllers{
            updateViewController(vc)
        }
    }
    
    private func viewController(graphId:DSGraphIdentifierType) -> UIViewController? {
        for vc in viewControllers {
            if vc is DSTimeBasedGraphViewController {
                let tbvc = (vc as! DSTimeBasedGraphViewController)
                if (tbvc.taskId == graphId.taskId) && (tbvc.questionId == graphId.questionId) {
                    return tbvc
                }
            }
        }
        return nil
    }
    
    private func containsViewController(graphId: DSGraphIdentifierType) -> Bool {
        for vc in viewControllers /*where vc.isKindOfClass(DSTimeBasedGraphViewController)*/ {
            switch(vc){
            case is DSTimeBasedGraphViewController:
                let tupleFromVc = (taskId: (vc as! DSTimeBasedGraphViewController).taskId, questionId: (vc as! DSTimeBasedGraphViewController).questionId)
                if tupleFromVc == graphId {
                    return true
                }
                
                //            case is DSCircularGraphViewController:
                //                break
            default:
                print("tipo errado")
                break
            }
        }
        return false
    }
    
    enum GraphType:String, CustomStringConvertible{
        case TimeBased = "timeBased", Circular = "circular"
        
        var description:String{
            return self.rawValue
        }
    }
    
    func updateViewController(vc:UIViewController) {
        if vc is DSTimeBasedGraphViewController {
            let tvc = vc as! DSTimeBasedGraphViewController
            tvc.loadLocalData()
            tvc.updatePoints()
            tvc.showAllData()
        }
    }
    
    private func graphTypeForId(graphId:DSGraphIdentifierType) -> GraphType{
        // Esta retornando somente quando da certo pq o programador tem que criar o plist certo
        if let path = NSBundle.mainBundle().pathForResource(graphId.taskId, ofType: "plist"){
            if let plistFile = NSDictionary(contentsOfFile: path){
                if let questions = plistFile.objectForKey(PlistFile.Task.Question.Key.rawValue) as? [NSDictionary]{
                    for question in questions{
                        if let dashboard = question.objectForKey(PlistFile.Task.Question.Dashboard.Key.rawValue) as? NSDictionary{
                            if let graphType = dashboard.objectForKey(PlistFile.Task.Question.Dashboard.GraphType.rawValue) as? String{
                                return GraphType(rawValue: graphType)!
                            }
                        }
                    }
                }
            }
        }
        assertionFailure("Tipo invalido, olha o plist la o mané! \nTaskID: \(graphId.taskId) \nQuestionID: \(graphId.questionId)")
        return GraphType(rawValue: String())!
    }
    
    private func getGraphIds() -> [DSGraphIdentifierType]{
        var graphIds = [DSGraphIdentifierType]()
        
        if let path = NSBundle.mainBundle().pathForResource("DSTasks", ofType: "plist"){
            if let tasks = NSArray(contentsOfFile: path) {
                for taskId in tasks {
                    if let taskPath = NSBundle.mainBundle().pathForResource((taskId as! String), ofType: "plist") {
                        if let task = NSDictionary(contentsOfFile: taskPath) {
                            if let questions = task["questions"] as? NSArray {
                                for question in questions {
                                    if (question as! NSDictionary)["dashboard"] != nil {
                                        if let questionId = (question as! NSDictionary)["questionId"] as? String {
                                            graphIds += [(taskId as! String, questionId)]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return graphIds
    }
}

extension DSDashboardViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return graphIdentifiers.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let graphId = graphIdentifiers[indexPath.section]
        
        let graphType = graphTypeForId(graphIdentifiers[indexPath.section])
        switch(graphType){
        case GraphType.TimeBased:
            let vc:DSTimeBasedGraphViewController
            if containsViewController(graphId) {
                vc = viewController(graphId) as! DSTimeBasedGraphViewController
            } else {
                vc = DSTimeBasedGraphViewController()
                vc.taskId = graphId.taskId
                vc.questionId = graphId.questionId
                vc.loadPlistData()
                vc.loadLocalData()
                vc.updateView()
                vc.updatePoints()
                vc.showAllData()
                viewControllers += [vc]
            }
            
            return vc.view as! TimeBasedGraphCell
            
        case GraphType.Circular:
            //                let vc = DSCircularGraphViewController()
            //                viewControllers+=[vc]
            //                cell.contentView.addSubview(vc.view)
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if graphTypeForId(graphIdentifiers[indexPath.section]) == .Circular {
            return 265
        }
        return 290
    }
    
}

extension DSDashboardViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}