//
//  CircularGraphView.swift
//  CALayerTests
//
//  Created by Mateus Reckziegel on 9/4/15.
//  Copyright (c) 2015 Mateus Reckziegel. All rights reserved.
//

import UIKit

class CircularGraphView: UIView {
    
    fileprivate var backgroundLayer = CAShapeLayer()
    fileprivate var percentageLayer = CAShapeLayer()
    fileprivate var totalLayer = CAShapeLayer()
    
    fileprivate var imageLayer = CALayer()
    fileprivate var bImageLayer = CALayer()
    
    fileprivate var textLayer = CATextLayer()
    
    fileprivate var percentage = 0.0
    
    var backgroundImage:CGImage? {
        didSet {
            self.setImageLayers()
            self.setPercentageLayer()
            self.setTotalLayer()
        }
    }
    
    var graphColor = UIColor(red: 0.3568, green: 0.87, blue: 0.563, alpha: 1.0).cgColor {
        didSet {
            self.percentageLayer.strokeColor = self.graphColor
        }
    }
    
    var textColor = UIColor.lightGray {
        didSet {
            self.setTextLayer()
        }
    }
    var backgroundGraphColor = UIColor.groupTableViewBackground.cgColor {
        didSet {
            self.setBackgroundLayer()
        }
    }
    var radius:CGFloat = 0 {
        didSet {
            self.updateLayers()
        }
    }
    var lineWidth:CGFloat = 15 {
        didSet {
            self.updateLayers()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if self.bounds.height > self.bounds.width {
            self.radius = self.bounds.width/2
        } else {
            self.radius = self.bounds.height/2
        }
        
        self.setBackgroundLayer()
        self.setPercentageLayer()
        self.setTextLayer()
        self.percentageLayer.strokeEnd = 0.0
        
        self.setTotalLayer()
        self.totalLayer.strokeEnd = 1.0
        
        self.layer.addSublayer(self.backgroundLayer)
        self.layer.addSublayer(self.totalLayer)
        self.layer.addSublayer(self.percentageLayer)
        self.layer.addSublayer(self.textLayer)
        
        self.setImageLayers()
        
        self.layer.addSublayer(self.bImageLayer)
        self.layer.addSublayer(self.imageLayer)
        
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        self.setPercentage(0, animated: false)
        self.setPercentage(self.percentage, animated: true)
    }
    
    fileprivate func deg2Rad(_ degree:Double) -> CGFloat {
        return CGFloat(degree * (.pi/180))
    }
    
    fileprivate func updateLayers(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.setBackgroundLayer()
        self.setTotalLayer()
        self.setPercentageLayer()
        self.setTextLayer()
        self.setImageLayers()
        CATransaction.commit()
    }
    
    fileprivate func setImageLayers(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.imageLayer.frame = self.bounds
        if self.backgroundImage != nil {
            self.imageLayer.contents = self.backgroundImage
            self.imageLayer.contentsGravity = kCAGravityResizeAspect
            self.imageLayer.mask = self.percentageLayer
        } else {
            self.imageLayer.contents = nil
        }
        self.bImageLayer.frame = self.bounds
        if self.backgroundImage != nil {
            self.bImageLayer.contents = self.backgroundImage
            self.bImageLayer.contentsGravity = kCAGravityResizeAspect
            self.bImageLayer.mask = self.totalLayer
        } else {
            self.bImageLayer.contents = nil
        }
        CATransaction.commit()
        
    }
    
    fileprivate func setTextLayer(){
        
        self.textLayer.frame = CGRect(x: 0, y: bounds.height/2 - radius*0.3, width: bounds.width, height: (radius * 2) * 0.3)
        self.textLayer.alignmentMode = "center"
        self.textLayer.contentsScale = UIScreen.main.scale
        
        let font1 = UIFont(name: "HelveticaNeue", size: self.radius/2)
        let font2 = UIFont(name: "HelveticaNeue-Light", size: self.radius/5)
        
        let val = NSMutableAttributedString(string: "\(Int(self.percentage*100))", attributes: [NSFontAttributeName:font1!, NSForegroundColorAttributeName:self.textColor])
        let perc = NSAttributedString(string: " %", attributes: [NSFontAttributeName:font2!, NSForegroundColorAttributeName:self.textColor])
        
        val.append(perc)
        
        self.textLayer.string = val
    }
    
    fileprivate func setBackgroundLayer(){
        self.backgroundLayer.fillColor = self.backgroundGraphColor
        self.backgroundLayer.path = self.makeArc(CGPoint(x: bounds.midX, y: bounds.midY), radius: self.radius)
    }
    
    fileprivate func setTotalLayer(){
        
        let path = self.makeArc(CGPoint(x: bounds.midX, y: bounds.midY),radius: self.radius - (self.lineWidth/2))
        
        self.totalLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
        self.totalLayer.fillColor = UIColor.clear.cgColor
        self.totalLayer.lineWidth = self.lineWidth
        self.totalLayer.lineCap = kCALineCapRound
        self.totalLayer.path = path
        
    }
    
    fileprivate func setPercentageLayer(){
        
        let path = self.makeArc(CGPoint(x: bounds.midX, y: bounds.midY), radius: radius - (lineWidth/2))
        
        self.percentageLayer.strokeColor = self.graphColor
        self.percentageLayer.fillColor = UIColor.clear.cgColor
        self.percentageLayer.lineWidth = self.lineWidth
        self.percentageLayer.lineCap = kCALineCapRound
        self.percentageLayer.path = path
        
    }
    
    fileprivate func updatePercentage(_ animated:Bool) {
        if animated {
            
            CATransaction.begin()
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            let lastPercentage = self.percentageLayer.strokeEnd
            anim.duration = abs((self.percentage - Double(lastPercentage))*0.7)
            anim.fromValue = lastPercentage
            anim.toValue = CGFloat(self.percentage)
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            self.textLayer.isHidden = true
            self.setTextLayer()
            
            CATransaction.setCompletionBlock({ () -> Void in
                self.textLayer.isHidden = false
            })
            
            self.percentageLayer.strokeEnd = CGFloat(self.percentage)
            self.percentageLayer.add(anim, forKey: "animateStrokeEnd")
            CATransaction.commit()
            
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.setTextLayer()
        self.percentageLayer.strokeEnd = CGFloat(self.percentage)
        CATransaction.commit()
    }
    
    fileprivate func makeArc(_ center:CGPoint, radius:CGFloat) -> CGPath {
        
        let path = UIBezierPath(arcCenter: .zero, radius: radius, startAngle: deg2Rad(0), endAngle: deg2Rad(360), clockwise: true)
        
        let rot = CGAffineTransform(rotationAngle: self.deg2Rad(270))
        let tra = CGAffineTransform(translationX: center.x, y: center.y)
        path.apply(rot)
        path.apply(tra)
        
        return path.cgPath
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayers()
    }
    
    func setPercentage(_ value:Double, animated:Bool) {
        if (value >= 0 && value <= 1) {
            self.percentage = value
            self.updatePercentage(animated)
        }
    }
}




























