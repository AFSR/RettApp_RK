//
//  CircularTableViewCell.swift
//  RKRett
//
//  Created by Julien Fieschi on 11/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit


protocol CircularTableViewCellDelegate : AnyObject {
    
    typealias GraphIdentifierType = (taskId: String, questionId: String)
    
    func didTapShowGraph(_ sender: Any, taskID: String,questionID: String)
}

class CircularTableViewCell: GraphTableViewCell {

    weak var delegate: CircularTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    let cell = self
    
    @IBAction func toggleFullScreen(_ sender: Any) {
        
        delegate?.didTapShowGraph(self, taskID: self.taskId!, questionID: self.questionId!)
        
    }
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var graphView: ORKPieChartView!
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
