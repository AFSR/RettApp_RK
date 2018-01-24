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
        
        let textStyle = ["font-family":"Helvetica Neue", "font-size":"15px", "font-style":"normal", "font-weight":"normal", "color":"000000", "text-align": "left", "margin-left": "15px", "margin-right":"15px"]
        
        let contentString = DSUtils.applyStyleDictionary(textStyle as NSDictionary, onTag: "p", withText: "<br>"+section.text)
        let htmlString = DSUtils.applyStyleDictionary(bodyStyleDictionary as NSDictionary, onTag: "body", withText: contentString)
        
        webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    }
    
    func configureLayout(){
        let frame = CGRect(x: 0,y: 0,width: 3,height: self.view.frame.size.height)
        let leftView = UIView(frame: frame)
        leftView.backgroundColor = .purple
        webView.addSubview(leftView)
        
        // To avoid black background on transition
        webView.isOpaque = false
    }
    
}

extension DSLearnDetailController:UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        //var path = Bundle.path(self) as String
        //var baseURL = URL.init(fileURLWithPath: path)
        
        //webView.loadHTMLString("", baseURL: Bundle.main.bundleURL)
        
        if navigationType == UIWebViewNavigationType.linkClicked{
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
}
