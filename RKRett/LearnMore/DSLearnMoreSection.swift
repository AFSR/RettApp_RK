//
//  DSLearnMoreSection.swift
//  RKRett
//
//  Created by Pietro Degrazia on 9/21/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//


class DSLearnMoreSection: NSObject{
    
    var title:String!
    var text:String!

    init(fromDictionary dic:NSDictionary){
        super.init()
        self.title = dic.objectForKey(PlistFile.Learn.Section.Title.rawValue) as! String
        self.text = dic.objectForKey(PlistFile.Learn.Section.Text.rawValue) as! String
    }
    
}