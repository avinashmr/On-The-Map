//
//  OTMConvenience.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/12/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

extension OTMClient {
    
    func authenticateWithUdacity(userName: String?, password: String?, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        
        if (userName!.isEmpty || password!.isEmpty) {
            // Text fields are empty and fail.
            completionHandlerForAuth(success: false, errorString: "Username or Password is empty.")
        } else {
            if Reachability.isConnectedToNetwork(){
                // Everything is good so far, continue.
                print("Internet connection OK")
                
                getSessionID(userName, password: password, completionHandlerForSession: { (success, sessionID, errorString) in
                    if (success) {
                        completionHandlerForAuth(success: true, errorString: nil)
                    }
                    else {
                        completionHandlerForAuth(success: false, errorString: "Wrong Username or Password.")
                    }
                })
            }
            else {
                // Internet Connection fails.
                print("Internet connection FAILED")
                completionHandlerForAuth(success: false, errorString: "Internet Connection Failed")
            }
            
        }
    }
    
    private func getSessionID(userName: String?, password: String?, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: NSError?) -> Void) {
        
        
        let mutableMethod: String = Method.AuthorizationURL
        let udacityBody: [String:AnyObject] = [JSONBodyKeys.Username: userName!, JSONBodyKeys.Password: password!]
        let jsonBody: [String:AnyObject] = [JSONBodyKeys.Udacity: udacityBody]
        
        taskForPOSTMethod(mutableMethod, udacity: true, parameters: nil, jsonBody: jsonBody) { (result, error) in
            if let error = error {
                completionHandlerForSession(success: false, sessionID: nil, errorString: error)
                
            } else {
                if let id = result.valueForKey(JSONResponseKeys.Session)?.valueForKey(JSONResponseKeys.Id) as? String {
                    self.sessionID = id
                    if let key = result.valueForKey(JSONResponseKeys.Account)?.valueForKey(JSONResponseKeys.Key) as? String {
                        self.uniqueKey = key
                        print(self.uniqueKey)
                    }
                    completionHandlerForSession(success: true, sessionID: nil, errorString: nil)
                }
                else {
                    completionHandlerForSession(success: false, sessionID: nil, errorString: NSError(domain: "getSession Parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getSessionID result"]))
                    
                }
                
            }
        }
        
    }
}
