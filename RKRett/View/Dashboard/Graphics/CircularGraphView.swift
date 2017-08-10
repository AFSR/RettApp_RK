//
//  CircularGraphView.swift
//  CALayerTests
//
//  Created by Mateus Reckziegel on 9/4/15.
//  Copyright (c) 2015 Mateus Reckziegel. All rights reserved.
//

import UIKit

class CircularGraphView: UIView {
    
    private var backgroundLayer = CAShapeLayer()
    private var percentageLayer = CAShapeLayer()
    private var totalLayer = CAShapeLayer()
    
    private var imageLayer = CALayer()
    private var bImageLayer = CALayer()
    
    private var textLayer = CATextLayer()
    
    private var percentage = 0.0
    
    var backgroundImage:CGImageRef? {
        didSet {
            self.setImageLayers()
            self.setPercentageLayer()
            self.setTotalLayer()
        }
    }
    var graphColor = UIColor(red: 0.3568, green: 0.87, blue: 0.563, alpha: 1.0).CGColor {
        didSet {
            self.percentageLayer.strokeColor = self.graphColor
        }
    }
    var textColor = UIColor.lightGrayColor() {
        didSet {
            self.setTextLayer()
        }
    }
    var backgroundGraphColor = UIColor.groupTableViewBackgroundColor().CGColor {
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
    
    private func deg2Rad(degree:Double) -> CGFloat {
        return CGFloat(degree*(M_PI/180))
    }
    
    private func updateLayers(){
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.setBackgroundLayer()
        self.setTotalLayer()
        self.setPercentageLayer()
        self.setTextLayer()
        self.setImageLayers()
        CATransaction.commit()
    }
    
    private func setImageLayers(){
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
    
    private func setTextLayer(){
        
        self.textLayer.frame = CGRectMake(0, self.bounds.height/2 - self.radius*0.3, self.bounds.width, (self.radius*2)*0.3)
        self.textLayer.alignmentMode = "center"
        self.textLayer.contentsScale = UIScreen.mainScreen().scale
        
        let font1 = UIFont(name: "HelveticaNeue", size: self.radius/2)
        let font2 = UIFont(name: "HelveticaNeue-Light", size: self.radius/5)
        
        let val = NSMutableAttributedString(string: "\(Int(self.percentage*100))", attributes: [NSFontAttributeName:font1!, NSForegroundColorAttributeName:self.textColor])
        let perc = NSAttributedString(string: " %", attributes: [NSFontAttributeName:font2!, NSForegroundColorAttributeName:self.textColor])
        
        val.appendAttributedString(perc)
        
        self.textLayer.string = val
    }
    
    private func setBackgroundLayer(){
        self.backgroundLayer.fillColor = self.backgroundGraphColor
        self.backgroundLayer.path = self.makeArc(CGPointMake(self.bounds.midX, self.bounds.midY),radius: self.radius)
    }
    
    private func setTotalLayer(){
        
        let path = self.makeArc(CGPointMake(self.bounds.midX, self.bounds.midY),radius: self.radius - (self.lineWidth/2))
        
        self.totalLayer.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3).CGColor
        self.totalLayer.fillColor = UIColor.clearColor().CGColor
        self.totalLayer.lineWidth = self.lineWidth
        self.totalLayer.lineCap = kCALineCapRound
        self.totalLayer.path = path
        
    }
    
    private func setPercentageLayer(){
        
        let path = self.makeArc(CGPointMake(self.bounds.midX, self.bounds.midY),radius: self.radius - (self.lineWidth/2))
        
        self.percentageLayer.strokeColor = self.graphColor
        self.percentageLayer.fillColor = UIColor.clearColor().CGColor
        self.percentageLayer.lineWidth = self.lineWidth
        self.percentageLayer.lineCap = kCALineCapRound
        self.percentageLayer.path = path
        
    }
    
    private func updatePercentage(animated:Bool) {
        if animated {
            
            CATransaction.begin()
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            let lastPercentage = self.percentageLayer.strokeEnd
            anim.duration = abs((self.percentage - Double(lastPercentage))*0.7)
            anim.fromValue = lastPercentage
            anim.toValue = CGFloat(self.percentage)
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            self.textLayer.hidden = true
            self.setTextLayer()
            
            CATransaction.setCompletionBlock({ () -> Void in
                self.textLayer.hidden = false
            })
            
            self.percentageLayer.strokeEnd = CGFloat(self.percentage)
            self.percentageLayer.addAnimation(anim, forKey: "animateStrokeEnd")
            CATransaction.commit()
            
            return
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.setTextLayer()
        self.percentageLayer.strokeEnd = CGFloat(self.percentage)
        CATransaction.commit()
    }
    
    private func makeArc(center:CGPoint, radius:CGFloat) -> CGPathRef {
        
        let path = UIBezierPath(arcCenter: CGPointZero, radius: radius, startAngle: deg2Rad(0), endAngle: deg2Rad(360), clockwise: true)
        
        let rot = CGAffineTransformMakeRotation(self.deg2Rad(270))
        let tra = CGAffineTransformMakeTranslation(center.x, center.y)
        path.applyTransform(rot)
        path.applyTransform(tra)
        
        return path.CGPath
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateLayers()
    }
    
    func setPercentage(value:Double, animated:Bool) {
        if (value >= 0 && value <= 1) {
            self.percentage = value
            self.updatePercentage(animated)
        }
    }
}




























