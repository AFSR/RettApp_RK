//
//  DSConsentDocument.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/18/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import ResearchKit

public var DSConsentDocument: ORKConsentDocument {
    
    let consentDocument = ORKConsentDocument()

    if let path = Bundle.main.path(forResource: kDSConsentPlist, ofType: "plist") {
        if let plistDictionary = NSDictionary(contentsOfFile: path){
            
            consentDocument.title = plistDictionary.value(forKey: PlistFile.Consent.Title.rawValue) as? String
            
            if let plistArray = plistDictionary.value(forKey: PlistFile.Consent.VisualStep.rawValue) as? Array<AnyObject>{
                var sections = [ORKConsentSection]()
                for dictionary in plistArray{
                    let sectionDictionary = dictionary as! NSDictionary
                    let consentSection: ORKConsentSection!
                    
                    if let image = sectionDictionary.value(forKey: PlistFile.Consent.Section.Image.rawValue) as? String{
                        
                        consentSection = ORKConsentSection(type:  ORKConsentSectionType.custom)
                        consentSection.customImage = UIImage(named: image)
                        
                        if let animation = sectionDictionary.value(forKey: PlistFile.Consent.Section.Animation.rawValue) as? String{
                            let animationExtension = plistDictionary.value(forKey: PlistFile.Consent.Extension.rawValue) as? String
                            if let animationPath = Bundle.main.path(forResource: animation, ofType: animationExtension){
                                consentSection.customAnimationURL = NSURL(fileURLWithPath: animationPath) as URL
                            }
                        }
                    
                    } else {
                        switch(sectionDictionary.value(forKey: PlistFile.Consent.Section.Type.rawValue) as! String){
                        case "Overview":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.overview)
                        case "DataGathering":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.dataGathering)
                        case "Privacy":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.privacy)
                        case "DataUse":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.dataUse)
                        case "TimeCommitment":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.timeCommitment)
                        case "StudySurvey":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.studySurvey)
                        case "StudyTasks":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.studyTasks)
                        case "Withdrawing":
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.withdrawing)
                        default:
                            consentSection = ORKConsentSection(type: ORKConsentSectionType.custom)
                        }
                    }
                    
                    consentSection.title = sectionDictionary.value(forKey: PlistFile.Consent.Section.Title.rawValue) as? String
                    consentSection.summary = sectionDictionary.value(forKey: PlistFile.Consent.Section.Summary.rawValue) as? String
                    consentSection.content = sectionDictionary.value(forKey: PlistFile.Consent.Section.Content.rawValue) as? String
                    
                    sections.insert(consentSection, at: sections.count)
                }
                
                consentDocument.sections = sections
            }
        }
    }
//    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))
    
    return consentDocument
    
}



//public var DSConsentDocument: ORKConsentDocument {
//
//    let consentDocument = ORKConsentDocument()
//    consentDocument.title = "Consent Document"
//
//    enum SectionTypePlistKey : String {
//        case Overview = "Overview"
//        case DataGathering = "DataGathering"
//        case Privacy = "Privacy"
//        case DataUse = "DataUse"
//        case TimeCommitment = "TimeCommitment"
//        case StudySurvey = "StudySurvey"
//        case StudyTasks = "StudyTasks"
//        case Withdrawing = "Withdrawing"
//        case Custom = "Custom"
//        case OnlyInDocument = "OnlyInDocument"
//    }
//
//    if let path = NSBundle.mainBundle().pathForResource(kDSConsentPlist, ofType: "plist") {
//        if let plistDictionary = NSDictionary(contentsOfFile: path){
//            if let plistArray = plistDictionary.valueForKey("VisualStep") as? Array<AnyObject>{
//                var sections = [ORKConsentSection]()
//                for dictionary in plistArray{
//                    let sectionDictionary = dictionary as! NSDictionary
//                    var consentSection:ORKConsentSection
//
//                    switch(sectionDictionary.valueForKey("sectionType") as! String){
//                    case "Overview":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.Overview)
//                    case "DataGathering":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.DataGathering)
//                    case "Privacy":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.Privacy)
//                    case "DataUse":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.DataUse)
//                    case "TimeCommitment":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.TimeCommitment)
//                    case "StudySurvey":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.StudySurvey)
//                    case "StudyTasks":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.StudyTasks)
//                    case "Withdrawing":
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.Withdrawing)
//                    default:
//                        consentSection = ORKConsentSection(type: ORKConsentSectionType.Custom)
//                    }
//
//                    consentSection.title = sectionDictionary.valueForKey("sectionTitle") as? String
////                    consentSection.customAnimationURL = NSURL()
//                    consentSection.summary = sectionDictionary.valueForKey("summary") as? String
//                    consentSection.content = sectionDictionary.valueForKey("content") as? String
//                    sections.insert(consentSection, atIndex: sections.count)
//                }
//
//                consentDocument.sections = sections
//            }
//        }
//    }
//    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))
//
//    return consentDocument
//
//}






 
