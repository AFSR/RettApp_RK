//
//  DSSettingsSection.swift
//  RKRett
//
//  Created by Julien Fieschi on 01/21/18.
//  Copyright © 2018 AFSR. All rights reserved.
//


class DSSettingsSection: NSObject{
    
    var title: String!
    var text: String!

    init(fromDictionary dic:NSDictionary){
        super.init()
        self.title = dic.object(forKey: PlistFile.Settings.Section.Title.rawValue) as! String
        self.text = dic.object(forKey: PlistFile.Settings.Section.Text.rawValue) as! String
    }
    
}
