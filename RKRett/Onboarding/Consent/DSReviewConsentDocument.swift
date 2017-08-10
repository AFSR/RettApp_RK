//
//  ReviewConsentDocument.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import ResearchKit

public var DSReviewConsentDocument : ((String, ORKConsentDocument) -> (ORKConsentReviewStep)) = { identifier, document in

    let reviewConsentStep = ORKConsentReviewStep(identifier: identifier, signature: nil, in: document)
    if let path = Bundle.main.path(forResource: "Consent", ofType: "plist") {
        if let plistDictionary = NSDictionary(contentsOfFile: path){
            if let reviewDictionary = plistDictionary.value(forKey: "ReviewStep") as? NSDictionary{
                reviewConsentStep.title = reviewDictionary.value(forKey: "title") as? String
                reviewConsentStep.reasonForConsent = reviewDictionary.value(forKey: "reason") as? String
            }
        }
    }
    return reviewConsentStep
}


