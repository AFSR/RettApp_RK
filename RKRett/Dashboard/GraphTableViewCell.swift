//
//  LineTableViewCell.swift
//  RKRett
//
//  Created by Julien Fieschi on 12/10/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit

class GraphTableViewCell: UITableViewCell {
    
    var taskId: String?
    var questionId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
