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
                
                getSessionID(userName, password: password, completionHandlerForSession: { (success, errorString) in
                    if (success) {
                        self.getPublicUserData(self.uniqueKey, completionHandlerForUserData: { (success, student, error) in
                            if success {
                                completionHandlerForAuth(success: true, errorString: nil)
                            } else {
                                completionHandlerForAuth(success: false, errorString: "Could not get User Data")
                            }
                        })
                        
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
    
    // MARK: - UDACITY
    // https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
    
    // POSTing (Creating) a Session
    private func getSessionID(userName: String?, password: String?, completionHandlerForSession: (success: Bool, errorString: NSError?) -> Void) {
        
        
        let mutableMethod: String = Methods.AuthorizationURL
        let udacityBody: [String:AnyObject] = [JSONBodyKeys.Username: userName!, JSONBodyKeys.Password: password!]
        let jsonBody: [String:AnyObject] = [JSONBodyKeys.Udacity: udacityBody]
        
        taskForPOSTMethod(mutableMethod, udacity: true, parameters: nil, jsonBody: jsonBody) { (result, error) in
            if let error = error {
                completionHandlerForSession(success: false, errorString: error)
                
            } else {
                if let id = result.valueForKey(JSONResponseKeys.Session)?.valueForKey(JSONResponseKeys.Id) as? String {
                    self.sessionID = id
                    if let key = result.valueForKey(JSONResponseKeys.Account)?.valueForKey(JSONResponseKeys.Key) as? String {
                        self.uniqueKey = key
                        print(self.uniqueKey)
                    }
                    completionHandlerForSession(success: true, errorString: nil)
                }
                else {
                    completionHandlerForSession(success: false, errorString: NSError(domain: "getSession Parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getSessionID result"]))
                    
                }
                
            }
        }
        
    }
    
    // GETting Public User Data
    private func getPublicUserData(uniqueKey: String?, completionHandlerForUserData: (success: Bool, student: StudentInformation?, error: NSError?) -> Void) {
        
        let parameters: [String:AnyObject] = [String:AnyObject]()
        let method = Methods.UserDataURL + uniqueKey!
        
        taskForGETMethod(method, udacity: true, parameters: parameters) { (result, error) in
            if (error != nil) {
                completionHandlerForUserData(success: true, student: nil, error: NSError(domain: "Failed to get User Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPublicUserData"]))
            } else {
                if let lastName = result.valueForKey(JSONResponseKeys.User)?.valueForKey(JSONResponseKeys.Last_Name) as? String {
                    if let firstName = result.valueForKey(JSONResponseKeys.User)?.valueForKey(JSONResponseKeys.First_Name) as? String {
                        if let uniqueKey = result.valueForKey(JSONResponseKeys.User)?.valueForKey(JSONResponseKeys.Key) as? String {
                            self.currentStudent = StudentInformation(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName)
                            print(firstName + lastName + uniqueKey)
                            completionHandlerForUserData(success: true, student: self.currentStudent, error: nil)
                        }
                    }
                } else {
                    completionHandlerForUserData(success: true, student: nil, error: NSError(domain: "Failed to get User Data", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPublicUserData"]))
                }
            }
        }
    }
}
