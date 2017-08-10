//
//  SharingConsent.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//
//
//import ResearchKit
//
//public var DSSharingConsent : ((String) -> (ORKConsentSharingStep)) = { identifier in
//    var sharingConsent = ORKConsentSharingStep(identifier: identifier)
//    
//    if let path = NSBundle.mainBundle().pathForResource(kDSConsentPlist, ofType: "plist") {
//        if let plistDictionary = NSDictionary(contentsOfFile: path){
//            if let sharingDictionary = plistDictionary.valueForKey("SharingStep") as? NSDictionary{
//                let shortDescription = sharingDictionary.valueForKey("shortDescription") as? String
//                let longDescription = sharingDictionary.valueForKey("longDescription") as? String
//                let learnMore = sharingDictionary.valueForKey("learnMore") as? String
//                sharingConsent = ORKConsentSharingStep(identifier: identifier, investigatorShortDescription: shortDescription!, investigatorLongDescription:tion!, localizedLearnMoreHTMLContent: learnMore!)
//                return sharingConsent
//            }
//        }
//    }
//    
//    return sharingConsent
//}