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
    @objc dynamic var identifier = UUID().uuidString
    @objc dynamic var createdAt = Date()
    @objc dynamic var initialDate = Date(timeIntervalSince1970: 1)
    @objc dynamic var finalDate =  Date(timeIntervalSince1970: 1)
    @objc dynamic var expectedDataSize = 0
    @objc dynamic var dataSize = 0
    @objc dynamic var succed = false
    @objc dynamic var url = ""
    @objc dynamic var gaps = 0
    let statusHistory = List<DSSensorDataQueryStatusHistory>()
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}

class DSSensorDataQueryStatusHistory: Object {
    @objc dynamic var status = ""
    @objc dynamic var timeStamp = ""
    @objc dynamic var owner: [DSSensorDataQuery] {
        return [LinkingObjects(fromType: DSSensorDataQuery.self, property: "statusHistory") as! DSSensorDataQuery]
    }
    
    func configure(_ status: String, timeStamp: String) -> DSSensorDataQueryStatusHistory{
        self.status = status;
        self.timeStamp = timeStamp
        return self
    }
    
}
