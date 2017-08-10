//
//  DSQueryDetailViewController.swift
//  RKRett
//
//  Created by Marcus Vinicius Kuquert on 06/10/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import RealmSwift
import JBChartView

class DSQueryDetailViewController: UIViewController{

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var identifier = ""
    var graphData = [(x: Double, y:Double, z:Double, date: NSDate)]()
    let lineChart = JBLineChartView(frame: CGRectMake(0, 0, 1000, 280))
    
    func showInfo(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "showInfo")
        self.navigationItem.rightBarButtonItem = barButton
        informationLabel.text = ""
        scrollView.addSubview(lineChart)
        scrollView.contentInset = UIEdgeInsetsMake(0,0,0,0)
        scrollView.clipsToBounds = true
        scrollView.contentSize = lineChart.bounds.size
        scrollView.layer.cornerRadius = 10
        scrollView.contentSize = CGSizeMake(lineChart.frame.width, scrollView.frame.height)

        let a = UIColor(r: 85,g: 239,b: 203, opacity: 1.0).CGColor
        let b = UIColor(r: 91,g: 202,b: 255, opacity: 1.0).CGColor
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = lineChart.bounds
        gradient.colors = [b, a, b]
        lineChart.layer.insertSublayer(gradient, atIndex: 0)
        
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 0.0
        lineChart.footerPadding = 5.0
        lineChart.backgroundColor = UIColor.clearColor()
        do{
            var text = ""
            let realm = try Realm()
            let query = realm.objectForPrimaryKey(DSSensorDataQuery.self, key: self.identifier)!
            for a in query.statusHistory{
                text += a.status + " --> " + a.timeStamp + "\n"
            }
            text += "identifier: \(query.identifier)\n initialDate: \(query.initialDate)\n finalDate: \(query.finalDate)\n expectedDataSize: \(query.expectedDataSize)\n dataSize: \(query.dataSize)\n succed: \(query.succed)\n url: \(query.url)\n gaps: \(query.gaps)"
            
            self.textView.text = text
            if (query.succed){
                let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
                let path = documents.stringByAppendingPathComponent(query.url)
                let fileURL = NSURL(fileURLWithPath: path)
                print(query.url)
                do{
                    
                    let csv = try CSV(contentsOfURL: fileURL)
                    for (index, dateString) in csv.columns["dateString"]!.enumerate(){
                        let timeInterval: Double! = Double(dateString)
                        let date = NSDate(timeIntervalSince1970: timeInterval)
                        let x = Double(csv.columns["acceleration.x"]![index])
                        let y = Double(csv.columns["acceleration.y"]![index])
                        let z = Double(csv.columns["acceleration.z"]![index])
                        graphData.append((x!, y!, z!, date))
                    }
                    lineChart.reloadData()
                    lineChart.setState(.Expanded, animated: true)
                }catch let error{
                    print(error)
                }
            }
        }catch let error{
            print("Problem using REALM or String(contentsOfURL)")
            print(error)
        } 

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lineChart.reloadData()
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showChart"), userInfo: nil, repeats: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        hideChart()
    }
    
    func hideChart() {
        lineChart.setState(.Collapsed, animated: true)
    }
    
    func showChart(){
        lineChart.frame = CGRect(x: 0, y: 0, width: 1000, height: scrollView.frame.height)
        let footerView = JBLineChartFooterView(frame: CGRectMake(0,0,10,30))
        footerView.sectionCount = 100
        if (graphData.count > 0){
            footerView.leftLabel.text = graphData[0].date.stringDateWithFormat("HH:mm")
            footerView.rightLabel.text = graphData[graphData.count - 1].date.stringDateWithFormat("HH:mm")
        }
        lineChart.footerView = footerView
        lineChart.setState(.Expanded, animated: true)
    }
}


extension DSQueryDetailViewController: JBLineChartViewDelegate, JBLineChartViewDataSource, UIScrollViewDelegate {
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 3
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(graphData.count)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        switch lineIndex{
        case 0:
            return CGFloat(pow(graphData[Int(horizontalIndex)].x, 2) )
        case 1:
            return CGFloat(pow(graphData[Int(horizontalIndex)].y, 2) )
        case 2:
            return CGFloat(pow(graphData[Int(horizontalIndex)].z, 2) )
        default:
            return nan("")
        }
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        switch lineIndex{
        case 0:
            return UIColor.redColor()
        case 1:
            return UIColor.greenColor()
        case 2:
            return UIColor.blueColor()
        default:
            return UIColor.purpleColor()
        }
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return false
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
        scrollView.scrollEnabled = false
        let data = graphData[Int(horizontalIndex)]
        switch lineIndex{
        case 0:
            informationLabel.text = "X -> " + String(data.x) + " at " + data.date.stringDateWithFormat("HH:mm:ss")
        case 1:
            informationLabel.text = "Y -> " + String(data.y) + " at " + data.date.stringDateWithFormat("HH:mm:ss")
        case 2:
            informationLabel.text = "Z -> " + String(data.z) + " at " + data.date.stringDateWithFormat("HH:mm:ss")
        default:
            informationLabel.text = data.date.description
        }
    }
    
    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        informationLabel.text = ""
        scrollView.scrollEnabled = true
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        
        return 1
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.purpleColor()
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func verticalSelectionWidthForLineChartView(lineChartView: JBLineChartView!) -> CGFloat {
        return 2
    }
    
    func shouldExtendSelectionViewIntoFooterPaddingForChartView(chartView: JBChartView!) -> Bool {
        return true
    }
}
