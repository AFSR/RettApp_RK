//
//  ConsentTask.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/18/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import ResearchKit

public var DSConsentTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    let consentDocument = DSConsentDocument
    let visualConsentStep = ORKVisualConsentStep(identifier: kVisualStepIdentifier , document: consentDocument)
    steps += [visualConsentStep]
    
//    if let signatures = consentDocument.signatures{
//        if let signature = signatures.first{
            let reviewConsentStep = DSReviewConsentDocument(kReviewStepIdentifier, consentDocument)
            steps += [reviewConsentStep]
//        }
//    }
    
//    let sharingConsentStep = DSSharingConsent(kSharingStepIdentifier)
//    steps += [sharingConsentStep]
    
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}