//
//  StandardGraphView.swift
//  DataGraphics
//
//  Created by Mateus Reckziegel on 8/18/15.
//  Copyright (c) 2015 Mateus Reckziegel. All rights reserved.
//

import UIKit

@IBDesignable

class StandardGraphView: UIView {
    
    fileprivate var xHighlightedLines = NSMutableArray()
    fileprivate var yHighlightedLines = NSMutableArray()
    fileprivate var lineLayer = CAShapeLayer()
    fileprivate var pointsLayer = CAShapeLayer()
    fileprivate lazy var graphHeight:CGFloat = {
        return self.frame.height - (self.edgeInsets.top + self.edgeInsets.bottom)
    }()
    fileprivate lazy var graphWidth:CGFloat = {
        return self.frame.width - (self.edgeInsets.right + self.edgeInsets.left)
    }()
    
    internal lazy var xScale:CGFloat = {
        let range = CGFloat(self.xValuesRange.max - self.xValuesRange.min)
        return self.graphWidth/range
    }()
    
    internal lazy var yScale: CGFloat = {
        let range = CGFloat(self.yValuesRange.max - self.yValuesRange.min)
        return self.graphHeight/range
    }()
    
    internal var shouldUpdatePoints = true
    
    internal var points = [(Any, Any)]()
    
    var animate = false
    
    var edgeInsets = UIEdgeInsetsMake(16, 40, 40, 16) {
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable internal var yValuesRange:(min:Double, max:Double) {
        didSet{
            self.shouldUpdatePoints = true
            self.setNeedsDisplay()
        }
    }
    @IBInspectable internal var xValuesRange:(min:Double, max:Double) {
        didSet{
            self.shouldUpdatePoints = true
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    @IBInspectable var showAxis: Bool = true {
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var showHorizontalGuidelines: Bool = true {
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var showVerticalGuidelines: Bool = true {
        didSet{
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var guidelinesSpacing: CGFloat = 50 {
        didSet {
            if self.guidelinesSpacing < 5 {
                self.guidelinesSpacing = 5
            }
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var axisColor:UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var lineColor:UIColor = UIColor ( red: 0.3354, green: 0.3354, blue: 0.3354, alpha: 1.0 ) {
        didSet {
            self.drawPoints()
        }
    }
    @IBInspectable var guidelinesColor:UIColor = UIColor.lightGray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var highlightedLinesColor:UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var textColor:UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if self.animate {
            self.setPoints(self.points)
        }
    }
    
    override init(frame: CGRect) {
        self.xValuesRange = (0, Double(frame.width - (self.edgeInsets.right + self.edgeInsets.left)))
        self.yValuesRange = (0, Double(frame.height - (self.edgeInsets.top + self.edgeInsets.bottom)))

        super.init(frame: frame)
        
        self.contentMode = UIViewContentMode.redraw
    }
    
    required init(coder aDecoder: NSCoder) {
        self.xValuesRange = (0, 1)
        self.yValuesRange = (0, 1)
        
        super.init(coder: aDecoder)!
        self.contentMode = UIViewContentMode.redraw
        self.layer.addSublayer(self.lineLayer)
        self.layer.addSublayer(self.pointsLayer)
    }
    
    internal func setXValuesRange(_ range:(min:Any, max:Any)) {
        self.xValuesRange = (range.min as! Double, range.max as! Double)
    }
    
    internal func setYValuesRange(_ range:(min:Any, max:Any)) {
        self.yValuesRange = (range.min as! Double, range.max as! Double)
    }
    
    internal func setPoints(_ points:[(Any, Any)]){
        self.points = points
        self.drawPoints()
    }
    
    fileprivate func distanceBetweenPoints(_ p1:CGPoint, p2:CGPoint) -> Double{
        return Double(abs(p2.x-p1.x) + abs(p2.y-p1.y))
    }
    
    fileprivate func updateGraphMeasurements() {
        self.graphWidth = self.frame.width - (self.edgeInsets.right + self.edgeInsets.left)
        self.graphHeight = self.frame.height - (self.edgeInsets.top + self.edgeInsets.bottom)
        
        let rangeX = CGFloat(self.xValuesRange.max - self.xValuesRange.min)
        self.xScale =  self.graphWidth/rangeX
        
        let rangeY = CGFloat(self.yValuesRange.max - self.yValuesRange.min)
        self.yScale = self.graphHeight/rangeY
    }
    
    func getGraphHeight() -> CGFloat {
        return self.graphHeight
    }
    
    func getGraphWidth() -> CGFloat {
        return self.graphWidth
    }
    
    func addXHighlightedLine(_ x:CGFloat) {
        if self.xHighlightedLines.contains(x){
            return
        }
        self.xHighlightedLines.add(x)
        self.setNeedsDisplay()
    }
    
    func removeXHighlightedLine(_ x:CGFloat) {
        self.xHighlightedLines.remove(x)
        self.setNeedsDisplay()
    }
    
    func removeAllXHighlightedLines(){
        self.xHighlightedLines.removeAllObjects()
        self.setNeedsDisplay()
    }
    
    func addYHighlightedLine(_ y:CGFloat) {
        if self.yHighlightedLines.contains(y){
            return
        }
        self.yHighlightedLines.add(y)
        self.setNeedsDisplay()
    }
    
    func removeYHighlightedLine(_ y:CGFloat) {
        self.yHighlightedLines.remove(y)
        self.setNeedsDisplay()
    }
    
    func removeAllYHighlightedLines(){
        self.yHighlightedLines.removeAllObjects()
        self.setNeedsDisplay()
    }
    
    internal func drawAxis(){
        let axis = UIBezierPath()
        axis.lineCapStyle = .round
        axis.lineWidth = 2.0
        self.axisColor.setStroke()
        
        //X axis
        axis.move(to: CGPoint(x: self.edgeInsets.left,y: self.frame.height - self.edgeInsets.bottom))
        axis.addLine(to: CGPoint(x: self.frame.width - self.edgeInsets.right, y: self.frame.height - self.edgeInsets.bottom))
        
        //Y axis
        axis.move(to: CGPoint(x: self.edgeInsets.left, y: self.frame.height - self.edgeInsets.bottom))
        axis.addLine(to: CGPoint(x: self.edgeInsets.left, y: self.edgeInsets.top))
        
        axis.stroke()
    }
    
    internal func drawHorizontalGuidelines(){
        let hGuidelines = UIBezierPath()
        hGuidelines.lineCapStyle = .round
        self.guidelinesColor.setStroke()
        
        for i in stride(from: self.frame.height - self.edgeInsets.bottom, to: self.edgeInsets.top, by: self.guidelinesSpacing).reversed() {
            hGuidelines.move(to: CGPoint(x: self.edgeInsets.left,y: i))
            hGuidelines.addLine(to: CGPoint(x: self.frame.width - self.edgeInsets.right, y: i))
        }
        
        hGuidelines.stroke()
    }
    
    internal func drawVerticalGuidelines(){
        let vGuidelines = UIBezierPath()
        vGuidelines.lineCapStyle = .round
        self.guidelinesColor.setStroke()
        
        for i in stride(from: self.edgeInsets.left, to: self.frame.width - self.edgeInsets.right, by:self.guidelinesSpacing) {
            vGuidelines.move(to: CGPoint(x: i, y: self.frame.height-self.edgeInsets.bottom))
            vGuidelines.addLine(to: CGPoint(x: i, y: self.edgeInsets.top))
        }
        
        vGuidelines.stroke()
    }
    
    internal func drawHighlightedLines(_ ctx:CGContext){
        
        let highlightedLines = UIBezierPath()
        highlightedLines.lineCapStyle = .round
        highlightedLines.setLineDash([7.5, 5], count: 2, phase: 0)
        self.highlightedLinesColor.setStroke()
        
        let font = UIFont(name: "Helvetica", size: 13)
        //let attr:CFDictionary = [NSFontAttributeName:font!,NSForegroundColorAttributeName:self.highlightedLinesColor]
        let attr = [NSAttributedStringKey.font.rawValue:font!,NSAttributedStringKey.foregroundColor:self.highlightedLinesColor] as! [String : Any]
        let affineMatrix = CGAffineTransform(scaleX: 1, y: -1)
        ctx.textMatrix = affineMatrix
//        let alignment = CTTextAlignment.Right
        
        //X Values
        for x in self.xHighlightedLines {
            let v = (x as! CGFloat)*self.xScale
            
            if v > 0 && v < (self.frame.width - self.edgeInsets.right - self.edgeInsets.left) {
                highlightedLines.move(to: CGPoint(x: self.edgeInsets.left + v, y: self.frame.height - self.edgeInsets.bottom))
                highlightedLines.addLine(to: CGPoint(x: self.edgeInsets.left + v, y: self.edgeInsets.top))
                
                let text = CFAttributedStringCreate(nil, String(format: "%.1f", arguments: [Float(x as! NSNumber)]) as CFString, attr as CFDictionary)
                let line = CTLineCreateWithAttributedString(text!)
                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
                
                if v - (bounds.width+1) > 0 {
                    //CGContextSetTextPosition(ctx, v - (bounds.width+1) + self.edgeInsets.left, self.frame.height - self.edgeInsets.bottom + bounds.height)
                    ctx.textPosition = CGPoint(x: v - (bounds.width+1) + self.edgeInsets.left, y: self.frame.height - self.edgeInsets.bottom + bounds.height)
                }
                
            }
        }
        
        //Y Values
        for y in self.yHighlightedLines {
            let v = (y as! CGFloat)*self.yScale
            
            if v > 0 && v < (self.frame.height - self.edgeInsets.bottom - self.edgeInsets.top) {
                highlightedLines.move(to: CGPoint(x: self.edgeInsets.left + 7.5, y: self.frame.height - self.edgeInsets.bottom - v))
                highlightedLines.addLine(to: CGPoint(x: self.frame.width - self.edgeInsets.right, y: self.frame.height - self.edgeInsets.bottom - v))
                
                let text = CFAttributedStringCreate(nil, String(format: "%.1f", arguments: [Float(y as! NSNumber)]) as CFString, attr as CFDictionary)
                let line = CTLineCreateWithAttributedString(text!)
                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
                
                //CGContextSetTextPosition(ctx, self.frame.width - self.edgeInsets.right - bounds.width , self.frame.height - self.edgeInsets.bottom - v - bounds.height/3)
                ctx.textPosition = CGPoint (x: self.frame.width - self.edgeInsets.right - bounds.width, y: self.frame.height - self.edgeInsets.bottom - v - bounds.height/3)
                CTLineDraw(line, ctx)
            }
        }
        
        highlightedLines.stroke()
        
    }
    
    internal func XValueForIndex(_ index:CGFloat) -> String {
        let x = (index*self.guidelinesSpacing/self.xScale)+CGFloat(self.xValuesRange.min)
        return String(format: "%.1f", arguments: [x])
    }
    
    internal func YValueForIndex(_ index:CGFloat) -> String {
        let y = (index*self.guidelinesSpacing/self.yScale)+CGFloat(self.yValuesRange.min)
        return String(format: "%.1f", arguments: [y])
    }
    
    internal func drawGraphValues(_ ctx:CGContext){
        let font = UIFont(name: "Helvetica", size: 13)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        //let attr:CFDictionary = [NSFontAttributeName:font!,NSForegroundColorAttributeName:self.textColor, NSParagraphStyleAttributeName:paragraphStyle]
        let attr = [NSAttributedStringKey.font.rawValue:font!,NSAttributedStringKey.foregroundColor:self.textColor, NSAttributedStringKey.paragraphStyle:paragraphStyle!] as! [String : Any]
        
        
        ctx.setLineWidth(1.0)
        ctx.setTextDrawingMode(.fill)
        let affineMatrix = CGAffineTransform(scaleX: 1, y: -1)
        ctx.textMatrix = affineMatrix

        
        //Y Values
        for var i in stride( from: CGFloat(1), to: ((self.frame.height - self.edgeInsets.top - self.edgeInsets.bottom)) / self.guidelinesSpacing, by: 1) {
            let text = CFAttributedStringCreate(nil, self.YValueForIndex(i) as CFString, attr as CFDictionary)
            let line = CTLineCreateWithAttributedString(text!)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
            
            //CGContextSetTextPosition(ctx, 4, (self.frame.height - self.edgeInsets.bottom + (bounds.height/4)) - (i*self.guidelinesSpacing))
            ctx.textPosition = CGPoint(x: 4, y: (self.frame.height - self.edgeInsets.bottom + (bounds.height/4)) - (i*self.guidelinesSpacing))
            CTLineDraw(line, ctx)
        }
        
        //X Values
        for var i in stride(from: CGFloat(0), to: ((self.frame.width - self.edgeInsets.left - self.edgeInsets.right)) / self.guidelinesSpacing, by:1) {
            let text = CFAttributedStringCreate(nil, self.XValueForIndex(i) as CFString, attr as CFDictionary)
            let line = CTLineCreateWithAttributedString(text!)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
            
            //CGContextSetTextPosition(ctx, self.edgeInsets.left + (i*self.guidelinesSpacing) - (bounds.width/2), self.frame.height - self.edgeInsets.bottom + bounds.height)
            ctx.textPosition = CGPoint(x: self.edgeInsets.left + (i*self.guidelinesSpacing) - (bounds.width/2), y: self.frame.height - self.edgeInsets.bottom + bounds.height)
            CTLineDraw(line, ctx)
        }
        
    }
    
    internal func pointForObject(_ object:(Any, Any)) -> CGPoint{
        let p = object as (x:Any, y:Any)
        let x = CGFloat(p.x as! Double - self.xValuesRange.min)
        let y = CGFloat(p.y as! Double - self.yValuesRange.min)
        
        return CGPoint(x: (x*self.xScale),y: self.graphHeight - (y*self.yScale))
    }
    
    internal func drawPoints(){
        if self.points.count == 0 {
            return
        }
        
        self.lineLayer.frame = CGRect(x: self.edgeInsets.left,y: self.edgeInsets.top,width: self.graphWidth,height: self.graphHeight)
        self.lineLayer.strokeColor = self.lineColor.cgColor
        self.lineLayer.fillColor = UIColor.clear.cgColor
        self.lineLayer.lineWidth = 1.2
        
        self.pointsLayer.frame = CGRect(x: self.edgeInsets.left,y: self.edgeInsets.top,width: self.graphWidth,height: self.graphHeight)
        self.pointsLayer.strokeColor = self.lineColor.cgColor
        self.pointsLayer.fillColor = self.backgroundColor!.cgColor
        self.pointsLayer.lineWidth = 2.0
        
        let line = UIBezierPath()
        let points = UIBezierPath()
        var lineLength = 0.0
        
        var lastPoint:CGPoint?
        
        for point in self.points {
            let correctPoint = self.pointForObject(point)
            
//            if self.negativeY {
//                correctPoint.y = correctPoint.y - (self.bounds.height - (self.edgeInsets.top + self.edgeInsets.bottom))/2
//            }
            
            if lastPoint == nil {
                line.move(to: correctPoint)
            } else {
                line.move(to: lastPoint!)
                line.addLine(to: correctPoint)
                lineLength = lineLength + self.distanceBetweenPoints(lastPoint!, p2: correctPoint)
            }
            
            let circle = UIBezierPath(arcCenter: correctPoint, radius: 4.0, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: false)
            points.append(circle)
            
            lastPoint = correctPoint
            
//            self.pointsLayer.masksToBounds = true
//            self.lineLayer.masksToBounds = true
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.pointsLayer.path = points.cgPath
        CATransaction.commit()
        
        if self.animate {
            self.lineLayer.strokeEnd = 0.0
            
            CATransaction.begin()
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.duration = lineLength/400
            anim.fromValue = 0.0
            anim.toValue = 1.0
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            self.lineLayer.path = line.cgPath
            self.lineLayer.strokeEnd = 1.0
            self.lineLayer.add(anim, forKey: "animateStrokeEnd")
            CATransaction.commit()
            
        } else {
            self.lineLayer.path = line.cgPath
        }
        
        self.shouldUpdatePoints = false
    }
    
    override func layoutSubviews() {
        self.shouldUpdatePoints = true
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        
        self.updateGraphMeasurements()
        
        if let ctx = UIGraphicsGetCurrentContext(){
            ctx.setLineCap(.round)
            
            if self.showHorizontalGuidelines {
                self.drawHorizontalGuidelines()
            }
            if self.showVerticalGuidelines{
                self.drawVerticalGuidelines()
            }
            if (self.xHighlightedLines.count > 0) || (self.yHighlightedLines.count > 0){
                self.drawHighlightedLines(ctx)
            }
            if self.showAxis{
                self.drawAxis()
            }
            self.drawGraphValues(ctx)
            
            if self.points.count != 0 && self.shouldUpdatePoints {
                self.drawPoints()
            }
        }
    }
    
}
