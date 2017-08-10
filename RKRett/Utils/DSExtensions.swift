//
//  DSExtensions.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/17/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

//MARK: - NSDate
//MARK: Formats
extension NSDate{
    func stringDateWithFormat(format:String = "yyyyMMdd-HHmmss") -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    
    func ISOStringFromDate() -> String {
        return self.stringDateWithFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").stringByAppendingString("Z")
    }
    
    func dateFromISOString(string: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.dateFromString(string)!
    }
    
    func isToday() -> Bool {
        let cal = NSCalendar.currentCalendar()
        return cal.isDateInToday(self)
    }
}

//MARK: Date components vars
extension NSDate{
    var seconds: Int{
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Second, fromDate: self)
    }
    
    var minutes: Int{
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Minute, fromDate: self)
    }
    
    var hour: Int{
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Hour, fromDate: self)
    }
    
    var day: Int{
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: self)
    }
    
    var weekDay: Int{
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Weekday, fromDate: self)
    }
    
    var weekDayString: String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE"
        let str = formatter.stringFromDate(self)
        return str
    }
    
    var month: Int{
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Month, fromDate: self)
    }
    var monthString: String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM"
        let str = formatter.stringFromDate(self)
        return str
    }
    
    func stringWithDateFormat(dateFormater: NSDateFormatter) -> String?{
        let str = dateFormater.stringFromDate(self)
        return str
    }
    
    var year: Int{
        return NSCalendar.currentCalendar().component(NSCalendarUnit.Year, fromDate: self)
    }
    
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}

//MARK: - NSError
//MARK: Utils
extension NSError{
    func codeIn(arrayCodes:[Int])->Bool{
        return arrayCodes.contains(self.code)
    }
    
}

//MARK: - UIColor
//MARK: Utils
extension UIColor{
    func purpleColor() -> UIColor{
        return UIColor(red: 0.5450, green: 0.3333, blue: 0.5294, alpha: 1.0)
    }
    
    class func lightOrangeColor() -> UIColor{
        return UIColor ( r: 243, g: 183, b: 1, opacity: 1.0 )
    }
    
    class func greenColorDarker() -> UIColor{
        return UIColor ( red: 0.3255, green: 0.8392, blue: 0.3412, alpha: 1.0 )
    }
    /*
    Convenience method to pass rgb values
    */
    convenience init(r: Int, g:Int , b:Int , opacity: Double) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(opacity))
    }
}

//MARK: - UIButton
//MARK: Utils
extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color), forState: state)
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension UIImage{
    class func imageWithColor(color: UIColor) -> UIImage {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

