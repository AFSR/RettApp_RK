//
//  DSCircularView.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/15/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit

@IBDesignable
class DSCircularView: UIView {
    
    @IBInspectable
    var rounded: Bool = false {
        didSet {
            if rounded{
                self.layer.cornerRadius = layer.visibleRect.height/2
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.whiteColor(){
        didSet {
            self.layer.borderColor = borderColor.CGColor
            if (self.layer.borderWidth == 0){
                self.layer.borderWidth = 1.0;
            }
        }
    }
    
}
