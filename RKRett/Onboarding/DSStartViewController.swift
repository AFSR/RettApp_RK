//
//  DSStartViewController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/24/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

class DSStartViewController: UIViewController {
   
    var consentController:DSConsentController!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var joinStudyButton: UIButton!
    @IBOutlet weak var alreadyParticipatingButton: UIButton!
//    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setAppearance()
    }
    
    func setAppearance(){
        self.joinStudyButton.layer.cornerRadius = 5
        self.joinStudyButton.layer.borderWidth = 1.0
//        self.joinStudyButton.layer.borderColor = UIColor.purpleColor().CGColor
//        joinStudyButton.layer.shadowOffset = CGSize(width: 3, height: 3)
//        joinStudyButton.layer.shadowOpacity = 0.5
//        joinStudyButton.layer.shadowRadius = 2
//
//        pageControl.layer.shadowOffset = CGSize(width: 3, height: 3)
//        pageControl.layer.shadowOpacity = 0.5
//        pageControl.layer.shadowRadius = 2
        
//        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewDidAppear(animated: Bool) {
        self.configureScrollView()
//        let fx = UIBlurEffect(style: UIBlurEffectStyle.Light)
//        let blurView = UIVisualEffectView(effect: fx)
//        blurView.frame = imageView.bounds
//        blurView.alpha = 0.8
//        imageView.addSubview(blurView)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func backFromConsent(segue: UIStoryboardSegue) {
        
    }
    
    func configureScrollView(){
        print(self.firstView.frame)
        print(self.scrollView.frame)
        let width:CGFloat = self.scrollView.frame.width
        let height:CGFloat = self.scrollView.frame.height
        let textStyle = ["font-family":"Helvetica Neue", "font-size":"20px", "font-style":"normal", "font-weight":"normal", "color":"000000", "text-align": "left", "margin-left": "20px", "margin-right":"20px"]
        let titleStyle = ["font-family":"HelveticaNeue-Light", "font-size":"25px", "font-style":"normal", "font-weight":"normal", "text-align": "center"]
        
        self.scrollView.layer.borderWidth = 1.0
        self.scrollView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).CGColor
        
        let secondCard = UIWebView(frame: CGRectMake(width, 0, width, height))
        secondCard.backgroundColor = UIColor.whiteColor()
        
        var title = "<br>" + NSLocalizedString("About Rett Syndrome", comment:"")
        title = DSUtils.applyStyleDictionary(titleStyle, onTag: "h1", withText: title)
        
        var text = NSLocalizedString("Rett Syndrome About", comment: "")
        text = DSUtils.applyStyleDictionary(textStyle, onTag: "p", withText: text)
        
        let body = DSUtils.applyStyleDictionary(NSDictionary(), onTag: "body", withText: title + text)
        
        secondCard.loadHTMLString(body, baseURL: nil)
        
        let thirdCard = UIWebView(frame: CGRectMake(width*2, 0, width, height))
        thirdCard.backgroundColor = UIColor.whiteColor()
        
        var title2 = "<br>"+NSLocalizedString("About Research Kit", comment:"")
        title2 = DSUtils.applyStyleDictionary(titleStyle, onTag: "h1", withText: title2)
        
        var text2 = NSLocalizedString("Research Kit About", comment: "")
        text2 = DSUtils.applyStyleDictionary(textStyle, onTag: "p", withText: text2)
        
        let body2 = DSUtils.applyStyleDictionary(NSDictionary(), onTag: "body", withText: title2 + text2)
        
        thirdCard.loadHTMLString(body2, baseURL: nil)

        scrollView.addSubview(secondCard)
        scrollView.addSubview(thirdCard)
        scrollView.contentSize = CGSizeMake(width*3, height)
        scrollView.contentInset = UIEdgeInsetsZero
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
    }
    
}