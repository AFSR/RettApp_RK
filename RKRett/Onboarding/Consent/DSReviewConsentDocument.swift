//
//  ReviewConsentDocument.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import ResearchKit

public var DSReviewConsentDocument : ((String, ORKConsentDocument) -> (ORKConsentReviewStep)) = { identifier, document in

    let reviewConsentStep = ORKConsentReviewStep(identifier: identifier, signature: nil, inDocument: document)
    if let path = NSBundle.mainBundle().pathForResource("Consent", ofType: "plist") {
        if let plistDictionary = NSDictionary(contentsOfFile: path){
            if let reviewDictionary = plistDictionary.valueForKey("ReviewStep") as? NSDictionary{
                reviewConsentStep.title = reviewDictionary.valueForKey("title") as? String
                reviewConsentStep.reasonForConsent = reviewDictionary.valueForKey("reason") as? String
            }
        }
    }
    return reviewConsentStep
}


