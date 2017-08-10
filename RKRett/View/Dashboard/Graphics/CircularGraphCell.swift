//
//  CircularGraphCell.swift
//  RKRett
//
//  Created by Mateus Reckziegel on 9/10/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

class CircularGraphCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var graphView: CircularGraphView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
