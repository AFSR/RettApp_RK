//
//  DSExtensions.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/17/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

//MARK: - Date
//MARK: Formats
extension Date{
    func stringDateWithFormat(format: String = "yyyyMMdd-HHmmss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func ISOStringFromDate() -> String {
        return self.stringDateWithFormat(format: "yyyy-MM-dd'T'HH:mm:ss.SSS").appending("Z")
    }
    
    func dateFromISOString(string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        dateFormatter.timeZone = NSTimeZone.local
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: string)! as Date
    }
    
    func isToday() -> Bool {
        let cal = NSCalendar.current
        return cal.isDateInToday(self)
    }
}

//MARK: Date components vars
extension Date {
    var seconds: Int {
        return NSCalendar.current.component(.second, from: self)
    }
    
    var minutes: Int {
        return NSCalendar.current.component(.minute, from: self)
    }
    
    var hour: Int{
        return NSCalendar.current.component(.hour, from: self)
    }
    
    var day: Int{
        return NSCalendar.current.component(.day, from: self)
    }
    
    var weekDay: Int{
        return NSCalendar.current.component(.weekday, from: self)
    }
    
    var weekDayString: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let str = formatter.string(from: self)
        return str
    }
    
    var month: Int{
        return NSCalendar.current.component(.month, from: self)
    }
    var monthString: String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let str = formatter.string(from: self)
        return str
    }
    
    func stringWithDateFormat(dateFormater: DateFormatter) -> String?{
        let str = dateFormater.string(from: self)
        return str
    }
    
    var year: Int {
        return NSCalendar.current.component(.year, from: self)
    }
    
//    func yearsFrom(date: Date) -> Int {
//        return NSCalendar.current.dateComponents(Set<Calendar.Component>(.year), from: date, to: self).year as! Int
//    }
//    
//    func monthsFrom(date: Date) -> Int{
//        return NSCalendar.currentCalendar.components(.month, fromDate: date, toDate: self, options: []).month
//    }
//    
//    func weeksFrom(date: Date) -> Int{
//        return NSCalendar.currentCalendar.components(.weekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
//    }
//    
//    func daysFrom(date: Date) -> Int{
//        return NSCalendar.currentCalendar.components(.day, fromDate: date, toDate: self, options: []).day
//    }
//    
//    func hoursFrom(date: Date) -> Int{
//        return NSCalendar.currentCalendar.components(.hour, fromDate: date, toDate: self, options: []).hour
//    }
//    
//    func minutesFrom(date: Date) -> Int{
//        return NSCalendar.currentCalendar.components(.minute, fromDate: date, toDate: self, options: []).minute
//    }
//    
//    func secondsFrom(date: Date) -> Int{
//        return NSCalendar.currentCalendar.components(.second, fromDate: date, toDate: self, options: []).second
//    }
    
//    func offsetFrom(date: Date) -> String {
//        if yearsFrom(date: date)   > 0 { return "\(yearsFrom(date: date))y"   }
//        if monthsFrom(date: date)  > 0 { return "\(monthsFrom(date: date))M"  }
//        if weeksFrom(date: date)   > 0 { return "\(weeksFrom(date: date))w"   }
//        if daysFrom(date: date)    > 0 { return "\(daysFrom(date: date))d"    }
//        if hoursFrom(date: date)   > 0 { return "\(hoursFrom(date: date))h"   }
//        if minutesFrom(date: date) > 0 { return "\(minutesFrom(date: date))m" }
//        if secondsFrom(date: date) > 0 { return "\(secondsFrom(date: date))s" }
//        return ""
//    }
}

//MARK: - NSError
//MARK: Utils
extension NSError {
    func codeIn(arrayCodes: [Int]) -> Bool {
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
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        setBackgroundImage(imageWithColor(color: color), for: state)
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
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

