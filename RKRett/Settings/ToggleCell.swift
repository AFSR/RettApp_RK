//
//  ToggleCell.swift
//  Table Views
//
//  Created by Julien Fieschi on 02/05/2018.
//  Copyright © 2018 Julien Fieschi. All rights reserved.
//

import UIKit


protocol ToggleCellDelegate : AnyObject {
    
    func switchValueIsChanged(_ sender: ToggleCell)
    
}

class ToggleCell: UITableViewCell {

    weak var delegate: ToggleCellDelegate?
    var id = ""
    
    @IBOutlet weak var switchToggle: UISwitch!
   
    
   @IBAction func switching(_ sender: Any) {
        
        delegate?.switchValueIsChanged(self)
        
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
