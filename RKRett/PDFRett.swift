//
//  PDFRett.swift
//  RKRett
//
//  Created by Julien Fieschi on 18/09/2018.
//  Copyright © 2018 AFSR. All rights reserved.
//

import UIKit
import PDFKit

@available(iOS 11.0, *)
class PDFRett: PDFDocument {
    
    var healthManager = HealthManager()
    let healthStore = HKHealthStore()
    
    
    override init() {
        
        var sex = ""
        var bloodType = ""
        var dateOfBirth = ""
        
        do {
            sex = try healthStore.biologicalSex().description
            bloodType = try healthStore.bloodType().description
            dateOfBirth = try healthStore.dateOfBirthComponents().description
            
        } catch  {
            print("Error")
        }
        
        let data = Data(base64Encoded: bloodType.data(using: String.Encoding.utf16)!)
        
        super.init(data: data!)!
        
    }
    
    
    
}
