//
//  DashboardGraphCell.swift
//  RKRett
//
//  Created by Julien Fieschi on 11/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//


import UIKit
//import ScrollableGraphView

protocol DashboardGraphCellDelegate : AnyObject {
    
    typealias GraphIdentifierType = (taskId: String, questionId: String)
    
    func didTapShowGraph(_ sender: DashboardGraphCell)
    
}

class DashboardGraphCell: UITableViewCell {
    
    weak var delegate: DashboardGraphCellDelegate?
    typealias DSGraphIdentifierType = (taskId: String, questionId: String)
    
    @IBOutlet weak var wideButton: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var graphView: TimeBasedGraphView!
    
    var taskId = ""
    var questionId = ""
    
    
    @IBAction func showGraph(_ sender: UIButton) {
        
        delegate?.didTapShowGraph(self)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.graphView.animate = true
    }
    
    func setColor(_ color:UIColor) {
        self.graphView.lineColor = color
        self.lblTitle.textColor = color
    }
    
}
