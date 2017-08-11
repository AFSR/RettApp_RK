//
//  DSError.swift
//  RKRett
//
//  Created by Marcus Vinicius Kuquert on 03/11/15.
//  Copyright © 2015 DarkShine. All rights reserved.
//

enum DSErrorCode{
    case watchNotReachable, queryReturnIsNil, fileURLError, fileSaveError
}
class DSError: NSError{
    convenience init(code: DSErrorCode, context: String?){
        var localDescription = ""
        var suggestion = ""
        var reason = ""
        
        switch code{
        case .watchNotReachable:
            localDescription = NSLocalizedString("Watch not reacheble", comment: "")
            suggestion = NSLocalizedString("Make sure the watch face is on nad the watch app is open", comment: "")
            reason = NSLocalizedString("This error happen when the watch is not reacheble to recive messages", comment: "")
            
        case .queryReturnIsNil:
            localDescription = NSLocalizedString("There is no accelerometer data available", comment: "")
            suggestion = NSLocalizedString("Try to renew the recording or put the watch on the wrist ", comment: "")
            reason = NSLocalizedString("method call accelerometerDataFrom() returned nil, this can happen if the watch is not in the wrist or there is no recording sessions open", comment: "")
            
        case .fileURLError:
            localDescription = NSLocalizedString("The recived file URL is not valid", comment: "")
            suggestion = NSLocalizedString("Close the app and try again", comment: "")
            reason = NSLocalizedString("This can happen when realm url record is pointing to the wrong file", comment: "")
            
        case .fileSaveError:
            localDescription = NSLocalizedString("The watch is unable to save file", comment: "")
            suggestion = NSLocalizedString("Please try to restart the watch app", comment: "")
            reason = NSLocalizedString("This can happen when the watch is not able to save the file requested by the iPhone", comment: "")
        }
        
        let domain = "io.darkshine.RettSyndrome"
        let dic = [NSLocalizedDescriptionKey:localDescription,
            NSLocalizedRecoverySuggestionErrorKey:suggestion,
            NSLocalizedFailureReasonErrorKey:reason,
        ]
        
        self.init(domain: domain, code: code.hashValue, userInfo: dic)
    }
}
