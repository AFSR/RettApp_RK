//
//  TimeBasedTableViewCell.swift
//  RKRett
//
//  Created by Julien Fieschi on 11/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit

protocol DiscreteTableViewCellDelegate : AnyObject {
    
    typealias GraphIdentifierType = (taskId: String, questionId: String)
    
    func didTapShowGraph(_ sender: Any, taskID: String,questionID: String)
    
}

class DiscreteTableViewCell: GraphTableViewCell {

    weak var delegate: DiscreteTableViewCellDelegate?
    var dataSource: DiscreteGraphDataSource?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var graphView: ORKDiscreteGraphChartView!

    @IBAction func toggleFullScreen(_ sender: Any) {
        
        delegate?.didTapShowGraph(self, taskID: self.taskId!, questionID: self.questionId!)
        
    }
    
    func createGraph(color : UIColor ){
        
        self.graphView.animate(withDuration: 0.5)
        self.graphView.showsHorizontalReferenceLines = true
        self.graphView.showsVerticalReferenceLines = true
        self.graphView.axisColor = UIColor.darkGray
        self.graphView.verticalAxisTitleColor = UIColor.orange
        self.graphView.showsHorizontalReferenceLines = true
        self.graphView.showsVerticalReferenceLines = true
        self.graphView.scrubberLineColor = UIColor.red
        self.graphView.tintColor = color
        self.graphView.drawsConnectedRanges = true
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
