//
//  DSBloodType.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 12/4/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

import Foundation
import RealmSwift

class DSBloodType: Object {
    
    dynamic var bloodType:HKBloodType = .NotSet {
        didSet{
            var bloodTypeString = ""
            switch(bloodType){
            case .NotSet:
                bloodTypeString = ""
                break
                
            case .APositive:
                bloodTypeString = "A+"
                break
                
            case .ANegative:
                bloodTypeString = "A-"
                break
                
            case .BPositive:
                bloodTypeString = "A+"
                break
                
            case .BNegative:
                bloodTypeString = "A+"
                break
                
            case .ABPositive:
                bloodTypeString = "A+"
                break
                
            case .ABNegative:
                bloodTypeString = "A+"
                break
                
            case .OPositive:
                bloodTypeString = "A+"
                break
                
            case .ONegative:
                bloodTypeString = "A+"
                break
                
            }
            
            self.bloodTypeString = bloodTypeString
        }
    }
    
    dynamic var bloodTypeString:String = ""
    
    convenience init(bloodTypeObject: HKBloodTypeObject){
        self.init()
        self.bloodType = bloodTypeObject.bloodType
    }
    
}