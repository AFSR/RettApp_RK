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
    private var dateFormatter = DateFormatter()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dateFormatter.dateFormat = self.systemDateFormat()
    }
    
    override func setXValuesRange(range: (min:Any, max:Any)) {
        self.referenceDate = range.min as! NSDate
        self.xValuesRange = (0.0, (range.max as! NSDate).timeIntervalSince(self.referenceDate as Date))
        print(self.xValuesRange.max)
    }
    override func setPoints(points: [(Any, Any)]) {
        self.points = points
        super.shouldUpdatePoints = true
        self.setNeedsDisplay()
    }

    private func stringFromDate(date:NSDate) -> String {
        return self.dateFormatter.string(from: date as Date)
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
        let date = self.referenceDate.addingTimeInterval(Double(index*self.guidelinesSpacing/self.xScale))
        return String(format: "%@", arguments: [self.stringFromDate(date: date)])
    }
    
    override func pointForObject(object: (date: Any, value: Any)) -> CGPoint {
        let x = CGFloat((object.date as! NSDate).timeIntervalSince(self.referenceDate as Date))
        let y = CGFloat(object.value as! Double)
        return CGPoint(x: x*self.xScale, y: self.getGraphHeight() - (y*self.yScale))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
}


































