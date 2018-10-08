//
//  TimeBasedGraphView.swift
//  DataGraphics
//
//  Created by Mateus Reckziegel on 8/27/15.
//  Updated by Julien Fieschi on 8/12/18.
//  Copyright (c) 2015 Mateus Reckziegel. All rights reserved.
//

import UIKit

enum TimeUnit {
    case second, minute, hour, day, week, month, year
}

class TimeBasedGraphView: StandardGraphView {
    
    fileprivate var referenceDate = Date()
    
    var timeUnit:TimeUnit = .hour {
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
    fileprivate var dateFormatter = DateFormatter()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dateFormatter.dateFormat = self.systemDateFormat()
    }
    
    override func setXValuesRange(_ range: (min:Any, max:Any)) {
        self.referenceDate = range.min as! Date
        self.xValuesRange = (0.0, (range.max as! Date).timeIntervalSince(self.referenceDate as Date))
    }
    override func setPoints(_ points: [(Any, Any)]) {
        self.points = points
        super.shouldUpdatePoints = true
        self.setNeedsDisplay()
    }

    fileprivate func stringFromDate(_ date:Date) -> String {
        return self.dateFormatter.string(from: date as Date)
    }
    
    fileprivate func systemDateFormat() -> String {
        switch self.timeUnit {
        case .second:
            return "ss"
        case .minute:
            return "HH:mm"
        case .hour:
            return "HH:mm"
        case .day:
            return "MMM dd"
        case .week:
            return "'s'W, MMM"
        case .month:
            return "MMM"
        case .year:
            return "yyyy"
        }
    }
    
    override func XValueForIndex(_ index: CGFloat) -> String {
        let date = self.referenceDate.addingTimeInterval(Double(index*self.guidelinesSpacing/self.xScale))
        return String(format: "%@", arguments: [self.stringFromDate(date)])
    }
    
    func pointIsOnGraph(_ object: (date: Any, value: Any)) -> Bool {
        let x = (object.date as! Date).timeIntervalSince(self.referenceDate as Date)
        if (x > self.xValuesRange.min && x < self.xValuesRange.max) {
            return true
        }else{
            return false
        }
    }
    
    override func pointForObject(_ object: (date: Any, value: Any)) -> CGPoint {
        let x = CGFloat((object.date as! Date).timeIntervalSince(self.referenceDate as Date))
        let y = CGFloat(object.value as! Double)
        return CGPoint(x: x*self.xScale, y: self.getGraphHeight() - (y*self.yScale))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
}
