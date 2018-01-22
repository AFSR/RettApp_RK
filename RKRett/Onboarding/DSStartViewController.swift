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
    
    override func viewDidAppear(_ animated: Bool) {
        self.configureScrollView()
//        let fx = UIBlurEffect(style: UIBlurEffectStyle.Light)
//        let blurView = UIVisualEffectView(effect: fx)
//        blurView.frame = imageView.bounds
//        blurView.alpha = 0.8
//        imageView.addSubview(blurView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func backFromConsent(_ segue: UIStoryboardSegue) {
        
    }
    
    func configureScrollView(){
        print(self.firstView.frame)
        print(self.scrollView.frame)
        let width:CGFloat = self.scrollView.frame.width
        let height:CGFloat = self.scrollView.frame.height
        let textStyle = ["font-family":"Helvetica Neue", "font-size":"15px", "font-style":"normal", "font-weight":"normal", "color":"000000", "text-align": "left", "margin-left": "15px", "margin-right":"15px"]
        let titleStyle = ["font-family":"HelveticaNeue-Light", "font-size":"20px", "font-style":"normal", "font-weight":"normal", "text-align": "center"]
        
        self.scrollView.layer.borderWidth = 1.0
        self.scrollView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        
        //SecondCard "About Rett Syndrome"
        let secondCard = UIWebView(frame: CGRect(x:width,y: 0,width: width,height: height))
        secondCard.backgroundColor = UIColor.white
        
        var title = "<br>" + NSLocalizedString("About Rett Syndrome", comment:"")
        title = DSUtils.applyStyleDictionary(titleStyle as NSDictionary, onTag: "h1", withText: title)
        
        var text = NSLocalizedString("Rett Syndrome About", comment: "")
        text = DSUtils.applyStyleDictionary(textStyle as NSDictionary, onTag: "p", withText: text)
        
        let body = DSUtils.applyStyleDictionary(NSDictionary(), onTag: "body", withText: title + text)
        
        secondCard.loadHTMLString(body, baseURL: nil)
    
        //ThirdCard "About ResearchKit"
        let thirdCard = UIWebView(frame: CGRect(x:width*2,y: 0,width: width,height: height))
        thirdCard.backgroundColor = UIColor.white
        
        var title2 = "<br>"+NSLocalizedString("About Research Kit", comment:"")
        title2 = DSUtils.applyStyleDictionary(titleStyle as NSDictionary, onTag: "h1", withText: title2)
        
        var text2 = NSLocalizedString("Research Kit About", comment: "")
        text2 = DSUtils.applyStyleDictionary(textStyle as NSDictionary, onTag: "p", withText: text2)
        
        let body2 = DSUtils.applyStyleDictionary(NSDictionary(), onTag: "body", withText: title2 + text2)
        
        thirdCard.loadHTMLString(body2, baseURL: nil)

        //FourthCard "About AFSR"
        let fourthCard = UIWebView(frame: CGRect(x:width*3,y: 0,width: width,height: height))
        fourthCard.backgroundColor = UIColor.white
        
        var title3 = "<br>"+NSLocalizedString("About AFSR", comment:"")
        title3 = DSUtils.applyStyleDictionary(titleStyle as NSDictionary, onTag: "h1", withText: title3)
        
        var text3 = NSLocalizedString("AFSR About", comment: "")
        text3 = DSUtils.applyStyleDictionary(textStyle as NSDictionary, onTag: "p", withText: text3)
        
        let body3 = DSUtils.applyStyleDictionary(NSDictionary(), onTag: "body", withText: title3 + text3)
        
        fourthCard.loadHTMLString(body3, baseURL: nil)
        
        //FifthCard "About CoRe"
        let fifthCard = UIWebView(frame: CGRect(x:width*4,y: 0,width: width,height: height))
        fifthCard.backgroundColor = UIColor.white
        
        var title4 = "<br>"+NSLocalizedString("About CoRe", comment:"")
        title4 = DSUtils.applyStyleDictionary(titleStyle as NSDictionary, onTag: "h1", withText: title4)
        
        var text4 = NSLocalizedString("CoRe About", comment: "")
        text4 = DSUtils.applyStyleDictionary(textStyle as NSDictionary, onTag: "p", withText: text4)
        
        let body4 = DSUtils.applyStyleDictionary(NSDictionary(), onTag: "body", withText: title4 + text4)
        
        fifthCard.loadHTMLString(body4, baseURL: nil)
        
        scrollView.addSubview(secondCard)
        scrollView.addSubview(thirdCard)
        scrollView.addSubview(fourthCard)
        scrollView.addSubview(fifthCard)
        
        scrollView.contentSize = CGSize(width: width*5,height: height)
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
    }
    
}
