//
//  DSSensorData.swift
//  RKRett
//
//  Created by Marcus Vinicius Kuquert on 18/09/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import Foundation
import RealmSwift

class DSSensorDataQuery: Object {
    dynamic var identifier = UUID().uuidString
    dynamic var createdAt = Date()
    dynamic var initialDate = Date(timeIntervalSince1970: 1)
    dynamic var finalDate =  Date(timeIntervalSince1970: 1)
    dynamic var expectedDataSize = 0
    dynamic var dataSize = 0
    dynamic var succed = false
    dynamic var url = ""
    dynamic var gaps = 0
    let statusHistory = List<DSSensorDataQueryStatusHistory>()
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

class DSSensorDataQueryStatusHistory: Object {
    dynamic var status = ""
    dynamic var timeStamp = ""
    dynamic var owner: [DSSensorDataQuery] {
        return [LinkingObjects(fromType: DSSensorDataQuery.self, property: "statusHistory") as! DSSensorDataQuery]
    }
    
    func configure(_ status: String, timeStamp: String) -> DSSensorDataQueryStatusHistory{
        self.status = status;
        self.timeStamp = timeStamp
        return self
    }
    
}
