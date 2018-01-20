//
//  DSDashboardViewController.swift
//  RKRett
//
//  Created by Mateus Reckziegel on 9/16/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import ScrollableGraphView

class DSDashboardViewController: UIViewController {
    //MARK: - Serialize/Deserialize Tuples
    typealias DSGraphIdentifierType = (taskId: String, questionId: String)
    typealias DSGraphIdentifierTypeDictionary = [String: String]
    
    let kQuestionsGraphArrayKey = "kQuestionsGraphArrayKey"
    let TaskIdKey = "taskId"
    let QuestionIdKey = "questionId"
    
    func serializeTuple(_ tuple: DSGraphIdentifierType) -> DSGraphIdentifierTypeDictionary {
        return [TaskIdKey : tuple.taskId, QuestionIdKey : tuple.questionId]
    }
    
    func deserializeDictionary(_ dictionary: DSGraphIdentifierTypeDictionary) -> DSGraphIdentifierType {
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
        
        tableView.register(UINib(nibName: "CircularGraphCell", bundle: Bundle.main), forCellReuseIdentifier: "CircularGraphCell")
        tableView.register(UINib(nibName: "TimeBasedGraphCell", bundle: Bundle.main), forCellReuseIdentifier: "TimeBasedGraphCell")
        
        if let unwrapped = UserDefaults.standard.object(forKey: kQuestionsGraphArrayKey) as? [DSGraphIdentifierTypeDictionary]{
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
        myActivity.isEligibleForSearch = true
        myActivity.keywords = Set(arrayLiteral: "Dashboard", "Charts", "Graph", "Rett")
        myActivity.userInfo = ["type":SpotlightSearchActions.Dashboard.rawValue]

        self.userActivity = myActivity
        myActivity.isEligibleForHandoff = false
        myActivity.becomeCurrent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for vc in viewControllers{
            updateViewController(vc)
        }
    }
    
    fileprivate func viewController(_ graphId:DSGraphIdentifierType) -> UIViewController? {
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
    
    fileprivate func containsViewController(_ graphId: DSGraphIdentifierType) -> Bool {
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
    
    func updateViewController(_ vc:UIViewController) {
        if vc is DSTimeBasedGraphViewController {
            let tvc = vc as! DSTimeBasedGraphViewController
            tvc.loadLocalData()
            tvc.updatePoints()
            tvc.showAllData()
        }
    }
    
    fileprivate func graphTypeForId(_ graphId:DSGraphIdentifierType) -> GraphType {
        // Esta retornando somente quando da certo pq o programador tem que criar o plist certo
        if let path = Bundle.main.path(forResource: graphId.taskId, ofType: "plist"){
            if let plistFile = NSDictionary(contentsOfFile: path){
                if let questions = plistFile.object(forKey: PlistFile.Task.Question.Key.rawValue) as? [NSDictionary]{
                    for question in questions{
                        if let dashboard = question.object(forKey: PlistFile.Task.Question.Dashboard.Key.rawValue) as? NSDictionary{
                            if let graphType = dashboard.object(forKey: PlistFile.Task.Question.Dashboard.GraphType.rawValue) as? String{
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
    
    fileprivate func getGraphIds() -> [DSGraphIdentifierType]{
        var graphIds = [DSGraphIdentifierType]()
        
        if let path = Bundle.main.path(forResource: "DSTasks", ofType: "plist"){
            if let tasks = NSArray(contentsOfFile: path) {
                for taskId in tasks {
                    if let taskPath = Bundle.main.path(forResource: (taskId as! String), ofType: "plist") {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return graphIdentifiers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if graphTypeForId(graphIdentifiers[indexPath.section]) == .Circular {
            return 265
        }
        return 290
    }
    
}

extension DSDashboardViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
