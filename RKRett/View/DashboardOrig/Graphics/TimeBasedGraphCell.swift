//
//  TimeBasedGraphCell.swift
//  
//
//  Created by Mateus Reckziegel on 9/10/15.
//
//

import UIKit
//import ScrollableGraphView

protocol TimeBasedGraphCellDelegate : AnyObject {
    
    typealias DSGraphIdentifierType = (taskId: String, questionId: String)
    
    func didTapShowGraph(_ sender: TimeBasedGraphCell)
    
}

class TimeBasedGraphCell: UITableViewCell {

    weak var delegate: TimeBasedGraphCellDelegate?
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
