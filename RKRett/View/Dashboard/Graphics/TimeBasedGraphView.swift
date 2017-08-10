//
//  TimeBasedGraphView.swift
//  DataGraphics
//
//  Created by Mateus Reckziegel on 8/27/15.
//  Copyright (c) 2015 Mateus Reckziegel. All rights reserved.
//

import UIKit

enum TimeUnit {
    case Second, Minute, Hour, Day, Week, Month, Year
}

class TimeBasedGraphView: StandardGraphView {
    
    private var referenceDate = NSDate()
    
    var timeUnit:TimeUnit = .Hour {
        didSet{
            self.dateFormat = self.systemDateFormat()
            super.shouldUpdatePoints = true
            self.setNeedsDisplay()
        }
    }
    var dateFormat:String? {
        didSet{
            if self.dateFormat != nil{
                self.dateFormatter.dateFormat = self.dateFormat!
                self.setNeedsDisplay()
            }
        }
    }
    private var dateFormatter = NSDateFormatter()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dateFormatter.dateFormat = self.systemDateFormat()
    }
    
    override func setXValuesRange(range: (min:Any, max:Any)) {
        self.referenceDate = range.min as! NSDate
        self.xValuesRange = (0.0, (range.max as! NSDate).timeIntervalSinceDate(self.referenceDate))
        print(self.xValuesRange.max)
    }
    override func setPoints(points: [(Any, Any)]) {
        self.points = points
        super.shouldUpdatePoints = true
        self.setNeedsDisplay()
    }

    private func stringFromDate(date:NSDate) -> String {
        return self.dateFormatter.stringFromDate(date)
    }
    
    private func systemDateFormat() -> String {
        switch self.timeUnit {
        case .Second:
            return "ss"
        case .Minute:
            return "HH:mm"
        case .Hour:
            return "HH:mm"
        case .Day:
            return "MMM dd"
        case .Week:
            return "'w'W, MMM"
        case .Month:
            return "MMM"
        case .Year:
            return "yyyy"
        }
    }
    
    override func XValueForIndex(index: CGFloat) -> String {
        let date = self.referenceDate.dateByAddingTimeInterval(Double(index*self.guidelinesSpacing/self.xScale))
        return String(format: "%@", arguments: [self.stringFromDate(date)])
    }
    
    override func pointForObject(object: (date: Any, value: Any)) -> CGPoint {
        let x = CGFloat((object.date as! NSDate).timeIntervalSinceDate(self.referenceDate))
        let y = CGFloat(object.value as! Double)
        return CGPointMake(x*self.xScale, self.getGraphHeight() - (y*self.yScale))
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
    
}


































