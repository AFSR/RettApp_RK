//
//  DSQueryDetailViewController.swift
//  RKRett
//
//  Created by Marcus Vinicius Kuquert on 06/10/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import JBChartView

class DSQueryDetailViewController: UIViewController{

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var identifier = ""
    var graphData = [(x: Double, y:Double, z:Double, date: Date)]()
    let lineChart = JBLineChartView(frame: CGRect(x: 0, y: 0, width: 1000, height: 280))
    
    @objc func showInfo(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(DSQueryDetailViewController.showInfo))
        self.navigationItem.rightBarButtonItem = barButton
        informationLabel.text = ""
        scrollView.addSubview(lineChart)
        scrollView.contentInset = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 0)
        scrollView.clipsToBounds = true
        scrollView.contentSize = lineChart.bounds.size
        scrollView.layer.cornerRadius = 10
        scrollView.contentSize = CGSize(width: lineChart.frame.width, height: scrollView.frame.height)

        let a = UIColor(r: 85,g: 239,b: 203, opacity: 1.0).cgColor
        let b = UIColor(r: 91,g: 202,b: 255, opacity: 1.0).cgColor
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = lineChart.bounds
        gradient.colors = [b, a, b]
        lineChart.layer.insertSublayer(gradient, at: 0)
        
        lineChart.delegate = self
        lineChart.dataSource = self
        lineChart.minimumValue = 0.0
        lineChart.footerPadding = 5.0
        lineChart.backgroundColor = UIColor.clear
        //Utilisation de CoreData
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lineChart.reloadData()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(DSQueryDetailViewController.showChart), userInfo: nil, repeats: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        hideChart()
    }
    
    func hideChart() {
        lineChart.setState(.collapsed, animated: true)
    }
    
    @objc func showChart() {
        lineChart.frame = CGRect(x: 0, y: 0, width: 1000, height: scrollView.frame.height)
        let footerView = JBLineChartFooterView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
        footerView.sectionCount = 100
        if (graphData.count > 0){
            footerView.leftLabel.text = graphData[0].date.stringDateWithFormat("HH:mm")
            footerView.rightLabel.text = graphData[graphData.count - 1].date.stringDateWithFormat("HH:mm")
        }
        lineChart.footerView = footerView
        lineChart.setState(.expanded, animated: true)
    }
}


extension DSQueryDetailViewController: JBLineChartViewDelegate, JBLineChartViewDataSource, UIScrollViewDelegate {
    
    func numberOfLines(in lineChartView: JBLineChartView!) -> UInt {
        return 3
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(graphData.count)
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
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
    
    func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        switch lineIndex{
        case 0:
            return UIColor.red
        case 1:
            return UIColor.green
        case 2:
            return UIColor.blue
        default:
            return UIColor.purple
        }
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return false
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAt lineIndex: UInt, horizontalIndex: UInt) {
        scrollView.isScrollEnabled = false
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
    
    func didDeselectLine(in lineChartView: JBLineChartView!) {
        informationLabel.text = ""
        scrollView.isScrollEnabled = true
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        
        return 1
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.purple
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.white
    }
    
    func verticalSelectionWidth(for lineChartView: JBLineChartView!) -> CGFloat {
        return 2
    }
    
    func shouldExtendSelectionViewIntoFooterPadding(for chartView: JBChartView!) -> Bool {
        return true
    }
}
