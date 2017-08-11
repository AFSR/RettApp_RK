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
    
    dynamic var bloodType:HKBloodType = .notSet {
        didSet{
            var bloodTypeString = ""
            switch(bloodType){
            case .notSet:
                bloodTypeString = ""
                break
                
            case .aPositive:
                bloodTypeString = "A+"
                break
                
            case .aNegative:
                bloodTypeString = "A-"
                break
                
            case .bPositive:
                bloodTypeString = "B+"
                break
                
            case .bNegative:
                bloodTypeString = "B-"
                break
                
            case .abPositive:
                bloodTypeString = "AB+"
                break
                
            case .abNegative:
                bloodTypeString = "AB-"
                break
                
            case .oPositive:
                bloodTypeString = "O+"
                break
                
            case .oNegative:
                bloodTypeString = "O-"
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
