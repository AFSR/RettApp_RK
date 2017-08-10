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
    
    private var xHighlightedLines = NSMutableArray()
    private var yHighlightedLines = NSMutableArray()
    private var lineLayer = CAShapeLayer()
    private var pointsLayer = CAShapeLayer()
    private lazy var graphHeight:CGFloat = {
        return self.frame.height - (self.edgeInsets.top + self.edgeInsets.bottom)
    }()
    private lazy var graphWidth:CGFloat = {
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
    @IBInspectable var axisColor:UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var lineColor:UIColor = UIColor ( red: 0.3354, green: 0.3354, blue: 0.3354, alpha: 1.0 ) {
        didSet {
            self.drawPoints()
        }
    }
    @IBInspectable var guidelinesColor:UIColor = UIColor.lightGrayColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var highlightedLinesColor:UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var textColor:UIColor = UIColor.blackColor() {
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
        
        self.contentMode = UIViewContentMode.Redraw
    }
    
    required init(coder aDecoder: NSCoder) {
        self.xValuesRange = (0, 1)
        self.yValuesRange = (0, 1)
        
        super.init(coder: aDecoder)!
        self.contentMode = UIViewContentMode.Redraw
        self.layer.addSublayer(self.lineLayer)
        self.layer.addSublayer(self.pointsLayer)
    }
    
    internal func setXValuesRange(range:(min:Any, max:Any)) {
        self.xValuesRange = (range.min as! Double, range.max as! Double)
    }
    
    internal func setYValuesRange(range:(min:Any, max:Any)) {
        self.yValuesRange = (range.min as! Double, range.max as! Double)
    }
    
    internal func setPoints(points:[(Any, Any)]){
        self.points = points
        self.drawPoints()
    }
    
    private func distanceBetweenPoints(p1:CGPoint, p2:CGPoint) -> Double{
        return Double(abs(p2.x-p1.x) + abs(p2.y-p1.y))
    }
    
    private func updateGraphMeasurements() {
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
    
    func addXHighlightedLine(x:CGFloat) {
        if self.xHighlightedLines.containsObject(x){
            return
        }
        self.xHighlightedLines.addObject(x)
        self.setNeedsDisplay()
    }
    
    func removeXHighlightedLine(x:CGFloat) {
        self.xHighlightedLines.removeObject(x)
        self.setNeedsDisplay()
    }
    
    func removeAllXHighlightedLines(){
        self.xHighlightedLines.removeAllObjects()
        self.setNeedsDisplay()
    }
    
    func addYHighlightedLine(y:CGFloat) {
        if self.yHighlightedLines.containsObject(y){
            return
        }
        self.yHighlightedLines.addObject(y)
        self.setNeedsDisplay()
    }
    
    func removeYHighlightedLine(y:CGFloat) {
        self.yHighlightedLines.removeObject(y)
        self.setNeedsDisplay()
    }
    
    func removeAllYHighlightedLines(){
        self.yHighlightedLines.removeAllObjects()
        self.setNeedsDisplay()
    }
    
    internal func drawAxis(){
        let axis = UIBezierPath()
        axis.lineCapStyle = .Round
        axis.lineWidth = 2.0
        self.axisColor.setStroke()
        
        //X axis
        axis.moveToPoint(CGPointMake(self.edgeInsets.left, self.frame.height - self.edgeInsets.bottom))
        axis.addLineToPoint(CGPointMake(self.frame.width - self.edgeInsets.right, self.frame.height - self.edgeInsets.bottom))
        
        //Y axis
        axis.moveToPoint(CGPointMake(self.edgeInsets.left, self.frame.height - self.edgeInsets.bottom))
        axis.addLineToPoint(CGPointMake(self.edgeInsets.left, self.edgeInsets.top))
        
        axis.stroke()
    }
    
    internal func drawHorizontalGuidelines(){
        let hGuidelines = UIBezierPath()
        hGuidelines.lineCapStyle = .Round
        self.guidelinesColor.setStroke()
        
        for var i = self.frame.height - self.edgeInsets.bottom; i > self.edgeInsets.top; i -= self.guidelinesSpacing {
            hGuidelines.moveToPoint(CGPointMake(self.edgeInsets.left, i))
            hGuidelines.addLineToPoint(CGPointMake(self.frame.width - self.edgeInsets.right, i))
        }
        
        hGuidelines.stroke()
    }
    
    internal func drawVerticalGuidelines(){
        let vGuidelines = UIBezierPath()
        vGuidelines.lineCapStyle = .Round
        self.guidelinesColor.setStroke()
        
        for var i = self.edgeInsets.left; i < self.frame.width - self.edgeInsets.right; i += self.guidelinesSpacing {
            vGuidelines.moveToPoint(CGPointMake(i, self.frame.height-self.edgeInsets.bottom))
            vGuidelines.addLineToPoint(CGPointMake(i, self.edgeInsets.top))
        }
        
        vGuidelines.stroke()
    }
    
    internal func drawHighlightedLines(ctx:CGContextRef){
        
        let highlightedLines = UIBezierPath()
        highlightedLines.lineCapStyle = .Round
        highlightedLines.setLineDash([7.5, 5], count: 2, phase: 0)
        self.highlightedLinesColor.setStroke()
        
        let font = UIFont(name: "Helvetica", size: 13)
        let attr:CFDictionaryRef = [NSFontAttributeName:font!,NSForegroundColorAttributeName:self.highlightedLinesColor]
        let affineMatrix = CGAffineTransformMakeScale(1, -1)
        CGContextSetTextMatrix(ctx, affineMatrix)
//        let alignment = CTTextAlignment.Right
        
        //X Values
        for x in self.xHighlightedLines {
            let v = (x as! CGFloat)*self.xScale
            
            if v > 0 && v < (self.frame.width - self.edgeInsets.right - self.edgeInsets.left) {
                highlightedLines.moveToPoint(CGPointMake(self.edgeInsets.left + v, self.frame.height - self.edgeInsets.bottom))
                highlightedLines.addLineToPoint(CGPointMake(self.edgeInsets.left + v, self.edgeInsets.top))
                
                let text = CFAttributedStringCreate(nil, String(format: "%.1f", arguments: [Float(x as! NSNumber)]), attr)
                let line = CTLineCreateWithAttributedString(text)
                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
                
                if v - (bounds.width+1) > 0 {
                    CGContextSetTextPosition(ctx, v - (bounds.width+1) + self.edgeInsets.left, self.frame.height - self.edgeInsets.bottom + bounds.height)
                }
                
            }
        }
        
        //Y Values
        for y in self.yHighlightedLines {
            let v = (y as! CGFloat)*self.yScale
            
            if v > 0 && v < (self.frame.height - self.edgeInsets.bottom - self.edgeInsets.top) {
                highlightedLines.moveToPoint(CGPointMake(self.edgeInsets.left + 7.5, self.frame.height - self.edgeInsets.bottom - v))
                highlightedLines.addLineToPoint(CGPointMake(self.frame.width - self.edgeInsets.right, self.frame.height - self.edgeInsets.bottom - v))
                
                let text = CFAttributedStringCreate(nil, String(format: "%.1f", arguments: [Float(y as! NSNumber)]), attr)
                let line = CTLineCreateWithAttributedString(text)
                let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
                
                CGContextSetTextPosition(ctx, self.frame.width - self.edgeInsets.right - bounds.width , self.frame.height - self.edgeInsets.bottom - v - bounds.height/3)
                CTLineDraw(line, ctx)
            }
        }
        
        highlightedLines.stroke()
        
    }
    
    internal func XValueForIndex(index:CGFloat) -> String {
        let x = (index*self.guidelinesSpacing/self.xScale)+CGFloat(self.xValuesRange.min)
        return String(format: "%.1f", arguments: [x])
    }
    
    internal func YValueForIndex(index:CGFloat) -> String {
        let y = (index*self.guidelinesSpacing/self.yScale)+CGFloat(self.yValuesRange.min)
        return String(format: "%.1f", arguments: [y])
    }
    
    internal func drawGraphValues(ctx:CGContextRef){
        let font = UIFont(name: "Helvetica", size: 13)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Right
        let attr:CFDictionaryRef = [NSFontAttributeName:font!,NSForegroundColorAttributeName:self.textColor, NSParagraphStyleAttributeName:paragraphStyle]
        
        CGContextSetLineWidth(ctx, 1.0)
        CGContextSetTextDrawingMode(ctx, .Fill)
        let affineMatrix = CGAffineTransformMakeScale(1, -1)
        CGContextSetTextMatrix(ctx, affineMatrix)

        
        //Y Values
        for var i = CGFloat(1); i < ((self.frame.height - self.edgeInsets.top - self.edgeInsets.bottom)) / self.guidelinesSpacing; i++ {
            let text = CFAttributedStringCreate(nil, self.YValueForIndex(i), attr)
            let line = CTLineCreateWithAttributedString(text)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
            
            CGContextSetTextPosition(ctx, 4, (self.frame.height - self.edgeInsets.bottom + (bounds.height/4)) - (i*self.guidelinesSpacing))
            CTLineDraw(line, ctx)
        }
        
        //X Values
        for var i = CGFloat(0); i < ((self.frame.width - self.edgeInsets.left - self.edgeInsets.right)) / self.guidelinesSpacing; i++ {
            let text = CFAttributedStringCreate(nil, self.XValueForIndex(i), attr)
            let line = CTLineCreateWithAttributedString(text)
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
            
            CGContextSetTextPosition(ctx, self.edgeInsets.left + (i*self.guidelinesSpacing) - (bounds.width/2), self.frame.height - self.edgeInsets.bottom + bounds.height)
            CTLineDraw(line, ctx)
        }
        
    }
    
    internal func pointForObject(object:(Any, Any)) -> CGPoint{
        let p = object as (x:Any, y:Any)
        let x = CGFloat(p.x as! Double - self.xValuesRange.min)
        let y = CGFloat(p.y as! Double - self.yValuesRange.min)
        
        return CGPointMake((x*self.xScale), self.graphHeight - (y*self.yScale))
    }
    
    internal func drawPoints(){
        if self.points.count == 0 {
            return
        }
        
        self.lineLayer.frame = CGRectMake(self.edgeInsets.left, self.edgeInsets.top, self.graphWidth, self.graphHeight)
        self.lineLayer.strokeColor = self.lineColor.CGColor
        self.lineLayer.fillColor = UIColor.clearColor().CGColor
        self.lineLayer.lineWidth = 1.2
        
        self.pointsLayer.frame = CGRectMake(self.edgeInsets.left, self.edgeInsets.top, self.graphWidth, self.graphHeight)
        self.pointsLayer.strokeColor = self.lineColor.CGColor
        self.pointsLayer.fillColor = self.backgroundColor!.CGColor
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
                line.moveToPoint(correctPoint)
            } else {
                line.moveToPoint(lastPoint!)
                line.addLineToPoint(correctPoint)
                lineLength = lineLength + self.distanceBetweenPoints(lastPoint!, p2: correctPoint)
            }
            
            let circle = UIBezierPath(arcCenter: correctPoint, radius: 4.0, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: false)
            points.appendPath(circle)
            
            lastPoint = correctPoint
            
//            self.pointsLayer.masksToBounds = true
//            self.lineLayer.masksToBounds = true
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.pointsLayer.path = points.CGPath
        CATransaction.commit()
        
        if self.animate {
            self.lineLayer.strokeEnd = 0.0
            
            CATransaction.begin()
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.duration = lineLength/400
            anim.fromValue = 0.0
            anim.toValue = 1.0
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            self.lineLayer.path = line.CGPath
            self.lineLayer.strokeEnd = 1.0
            self.lineLayer.addAnimation(anim, forKey: "animateStrokeEnd")
            CATransaction.commit()
            
        } else {
            self.lineLayer.path = line.CGPath
        }
        
        self.shouldUpdatePoints = false
    }
    
    override func layoutSubviews() {
        self.shouldUpdatePoints = true
        super.layoutSubviews()
    }
    
    override func drawRect(rect: CGRect) {
        
        self.updateGraphMeasurements()
        
        if let ctx = UIGraphicsGetCurrentContext(){
            CGContextSetLineCap(ctx, .Round)
            
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
