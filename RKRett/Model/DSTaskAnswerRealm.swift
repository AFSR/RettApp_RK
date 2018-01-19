//
//  DSTaskAnswerRealm.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 9/17/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import RealmSwift

class DSTaskAnswerRealm: Object {
    
    @objc dynamic var taskName = ""
    @objc dynamic var json = ""
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
