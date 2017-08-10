//
//  DSLearnDetailController.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/21/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import UIKit
import SafariServices

class DSLearnDetailController:UIViewController{
    
    @IBOutlet weak var webView: UIWebView!
    
    var section:DSLearnMoreSection!
    let bodyStyleDictionary = ["background-color":"transparent"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = section.title

        webView.delegate = self
        configureLayout()
        
        let textStyle = ["font-family":"Helvetica Neue", "font-size":"20px", "font-style":"normal", "font-weight":"normal", "color":"000000", "text-align": "left", "margin-left": "20px", "margin-right":"20px"]
        
        let contentString = DSUtils.applyStyleDictionary(textStyle, onTag: "p", withText: "<br>"+section.text)
        let htmlString = DSUtils.applyStyleDictionary(bodyStyleDictionary, onTag: "body", withText: contentString)
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func configureLayout(){
        let frame = CGRectMake(0, 0, 3, self.view.frame.size.height)
        let leftView = UIView(frame: frame)
        leftView.backgroundColor = .purpleColor()
        webView.addSubview(leftView)
        
        // To avoid black background on transition
        webView.opaque = false
    }
    
}

extension DSLearnDetailController:UIWebViewDelegate{
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.LinkClicked{
            UIApplication.sharedApplication().openURL(request.URL!)
            return false
        }
        return true
    }
}
