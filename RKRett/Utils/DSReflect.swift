//
//  DSReflect.swift
//  RKRett
//
//  Created by Henrique Valcanaia on 8/21/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//

import UIKit

class DSReflect: NSObject {
    
    func properties() -> [String] {
        let mirror = Mirror(reflecting: self)
        var properties = [String]()
        for child in mirror.children{
            guard let property = child.label else{
                print("deu ruim")
                break;
            }
            
            if property == "super" { continue }
            properties.append(property)
        }
        return properties
    }
    
}
