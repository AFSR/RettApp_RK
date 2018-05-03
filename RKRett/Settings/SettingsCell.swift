//
//  SettingsCell.swift
//  Table Views
//
//  Created by Julien Fieschi on 02/05/2018.
//  Copyright © 2018 Julien Fieschi. All rights reserved.
//

import UIKit


protocol SettingsCellDelegate: AnyObject {
    
}

class SettingsCell: UITableViewCell {

    weak var delegate: SettingsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
