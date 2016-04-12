//
//  OTMConstants.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/12/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import Foundation

extension OTMClient {
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        static let Session = "session"
        static let Account = "account"
        static let Key = "key"
        static let Id = "id"
        static let User = "user"
        static let Last_Name = "last_name"
        static let First_Name = "first_name"
        static let Results = "results"
        static let ObjectID = "objectId"
        static let UpdatedAt = "updatedAt"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        
        static let AccessToken = "access_token"
        static let FacebookMobile = "facebook_mobile"
    }

}