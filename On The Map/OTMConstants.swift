//
//  OTMConstants.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/12/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import Foundation

extension OTMClient {
    
    struct Methods {
        
//        static let ApiScheme = "https"
//        static let ApiHost = "www.udacity.com/"
//        static let ApiPath = "/api"
        static let AuthorizationURL: String = "https://www.udacity.com/api/session"
        static let UserDataURL: String      = "https://www.udacity.com/api/users/"
        static let StudentLocations: String = "https://api.parse.com/1/classes/StudentLocation"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status"
        static let Session = "session"
        static let Account = "account"
        static let Key = "key"
        static let Id = "id"
        static let User = "user"
        static let Error = "error"
        static let Last_Name = "last_name"
        static let First_Name = "first_name"
        static let Results = "results"
//        static let ObjectID = "objectId"
//        static let UpdatedAt = "updatedAt"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        
        static let AccessToken = "access_token"
        static let FacebookMobile = "facebook_mobile"
    }
    
    // MARK: JSON Body Keys
    struct HTTPBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }

}