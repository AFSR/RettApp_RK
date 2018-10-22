//
//  LineTableViewCell.swift
//  RKRett
//
//  Created by Julien Fieschi on 12/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit

protocol LineTableViewCellDelegate : AnyObject {
    
    typealias GraphIdentifierType = (taskId: String, questionId: String)
    
    func didTapShowGraph(_ sender: Any, taskID: String,questionID: String)
    
}

class LineTableViewCell: GraphTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var graphView: ORKLineGraphChartView!
    
    @IBOutlet weak var toggleFullScreenButton: UIButton!
    @IBAction func toggleFullScreen(_ sender: Any) {
        
        delegate?.didTapShowGraph(self, taskID: self.taskId!, questionID: self.questionId!)
        
    }
    
    weak var delegate: LineTableViewCellDelegate?
    var dataSource: LineGraphDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func createGraph(color : UIColor ){
        
        self.graphView.animate(withDuration: 1)
        self.graphView.showsHorizontalReferenceLines = true
        self.graphView.showsVerticalReferenceLines = true
        self.graphView.axisColor = UIColor.darkGray
        self.graphView.verticalAxisTitleColor = UIColor.orange
        self.graphView.showsHorizontalReferenceLines = true
        self.graphView.showsVerticalReferenceLines = true
        self.graphView.scrubberLineColor = UIColor.red
        self.graphView.tintColor = color
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
