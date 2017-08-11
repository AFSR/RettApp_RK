//
//  TimeBasedGraphCell.swift
//  
//
//  Created by Mateus Reckziegel on 9/10/15.
//
//

import UIKit

class TimeBasedGraphCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var graphView: TimeBasedGraphView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.graphView.animate = true
    }
    
    func setColor(_ color:UIColor) {
        self.graphView.lineColor = color
        self.lblTitle.textColor = color
    }

}
