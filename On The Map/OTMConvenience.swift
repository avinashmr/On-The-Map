//
//  OTMConvenience.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/12/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit

extension OTMClient {
    
    // Login to Udacity
    func authenticateWithUdacity(userName: String?, password: String?, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        if (userName!.isEmpty || password!.isEmpty) {
            // Text fields are empty and fail.
            completionHandlerForAuth(success: false, errorString: "Username or Password is empty.")
        } else {
            if Reachability.isConnectedToNetwork(){
                // Everything is good so far, continue.
                
                getSessionID(userName, password: password, completionHandlerForSession: { (success, errorString) in
                    if (success) {
                        
                        self.getPublicUserData(self.uniqueKey, completionHandlerForUserData: { (success, student, error) in
                            if success {
                                completionHandlerForAuth(success: true, errorString: nil)
                            } else {
                                completionHandlerForAuth(success: false, errorString: "Could not get User Data.")
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
                completionHandlerForAuth(success: false, errorString: "Internet Connection Failed.")
            }
            
        }
    }
    
    // Check if the URL is a correct URL, if not, add a "http://".
    func formatURL(urlString: String, completionHandlerForURL: (success: Bool, newURL: String?, error: String?) -> Void) {
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: urlString)!) {
            completionHandlerForURL(success: true, newURL: urlString, error: nil)
        } else {
            if !(urlString.lowercaseString.hasPrefix("http://")) {
                let newURL = "http://" + urlString
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: newURL)!) {
                    completionHandlerForURL(success: true, newURL: newURL, error: nil)
                } else {
                    completionHandlerForURL(success: false, newURL: nil, error: "URL is incorrect")
                }
            } else {
                completionHandlerForURL(success: false, newURL: nil, error: "URL is incorrect")
            }
        }
        
    }
    
    // MARK: - UDACITY
    // API Usage: https://docs.google.com/document/d/1MECZgeASBDYrbBg7RlRu9zBBLGd3_kfzsN-0FtURqn0/pub?embedded=true
    
    // POSTing (Creating) a Session
    private func getSessionID(userName: String?, password: String?, completionHandlerForSession: (success: Bool, error: String?) -> Void) {
        
        
        let mutableMethod: String = Methods.Udacity.AuthorizationURL
        let udacityBody: [String:AnyObject] = [
            HTTPBodyKeys.Username: userName!,
            HTTPBodyKeys.Password: password!
        ]
        let jsonBody: [String:AnyObject] = [HTTPBodyKeys.Udacity: udacityBody]
        
        
        taskForPOSTMethod(mutableMethod, udacity: true, parameters: nil, jsonBody: jsonBody) { (result, error) in
            if let error = error {
                completionHandlerForSession(success: false, error: "getSessionID Error")
                
            } else {
                if let id = result.valueForKey(JSONResponseKeys.Session)?.valueForKey(JSONResponseKeys.Id) as? String {
                    self.sessionID = id
                    if let key = result.valueForKey(JSONResponseKeys.Account)?.valueForKey(JSONResponseKeys.Key) as? String {
                        self.uniqueKey = key
                    }
                    completionHandlerForSession(success: true, error: nil)
                }
                else {
                    completionHandlerForSession(success: false, error: "getSessionID Error")
                    
                }
                
            }
        }
        
    }
    
    // GETting Public User Data
    private func getPublicUserData(uniqueKey: String?, completionHandlerForUserData: (success: Bool, student: StudentInformation?, error: String?) -> Void) {
        
        let parameters: [String:AnyObject] = [String:AnyObject]()
        let method = Methods.Udacity.UserDataURL + uniqueKey!
        
        taskForGETMethod(method, udacity: true, parameters: parameters) { (result, error) in
            
            if let error = error {
                completionHandlerForUserData(success: true, student: nil, error: "Could not parse publicUserData")
            } else {
                
                if let lastName = result.valueForKey(JSONResponseKeys.User)?.valueForKey(JSONResponseKeys.Last_Name) as? String {
                    if let firstName = result.valueForKey(JSONResponseKeys.User)?.valueForKey(JSONResponseKeys.First_Name) as? String {
                        if let uniqueKey = result.valueForKey(JSONResponseKeys.User)?.valueForKey(JSONResponseKeys.Key) as? String {
                            self.currentStudent = StudentInformation(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName)
                            completionHandlerForUserData(success: true, student: self.currentStudent, error: nil)
                        }
                    }
                } else {
                    completionHandlerForUserData(success: true, student: nil, error: "Could not parse publicUserData")
                }

            }
        }
    }
    
    // DELETEing a Session
    func logoutOfUdacity(completionHandlerForUdacityLogout: (success: Bool, error: String?) -> Void) {
        
        let method = Methods.Udacity.AuthorizationURL
        
        taskForDELETEMethod(method) { (result, error) in
            if let error = error {
                completionHandlerForUdacityLogout(success: false, error: "Error Logging Out.")
            } else {
                if let logoutID = result.valueForKey("session")?.valueForKey("id") as? String {
                    completionHandlerForUdacityLogout(success: true, error: nil)
                }
                completionHandlerForUdacityLogout(success: false, error: "Error Logging Out.")
            }
        }
    }


    // MARK: - PARSE
    // API Usage: https://docs.google.com/document/d/1E7JIiRxFR3nBiUUzkKal44l9JkSyqNWvQrNH4pDrOFU/pub?embedded=true
    
    // Get Student Locations
    func getStudentLocations(completionHandlerForLocation: (success: Bool, error: String?) -> Void) {
        
        let parameters: [String:AnyObject] = [
            OTMClient.ParameterKeys.Limit: OTMClient.Constants.downloadLimit,
            OTMClient.ParameterKeys.Skip: OTMClient.Constants.skip,
            OTMClient.ParameterKeys.Order: OTMClient.Constants.downloadOrder
        ]
        
        let method = Methods.Parse.StudentLocations + OTMClient.escapedParameters(parameters)
        
        taskForGETMethod(method, udacity: false, parameters: nil) { (result, error) in
            
            if let error = error {
                completionHandlerForLocation(success: false, error: "Failed to get Student Locations")
            } else {
                if let results = result.valueForKey(JSONResponseKeys.Results) as? [[String:AnyObject]] {
                    StudentInformation.studentInformation = StudentInformation.studentInformationFromResults(results)
                    completionHandlerForLocation(success: true, error: nil)
                    
                } else {
                    completionHandlerForLocation(success: false, error: "Failed to get StudentInformation")
                }
            }
        }
        
    }

    // Post a Student Location
    func postAStudentLocation(updatedStudent: StudentInformation?, completionHandlerForStudentLocation: (success: Bool, error: String?) -> Void) {
        
        let method = Methods.Parse.StudentLocations
        let currentStudent = OTMClient.sharedInstance().currentStudent
        
        let jsonBody: [String:AnyObject] = [
            OTMClient.JSONBodyKeys.UniqueKey: currentStudent!.uniqueKey,
            OTMClient.JSONBodyKeys.FirstName: currentStudent!.firstName,
            OTMClient.JSONBodyKeys.LastName: currentStudent!.lastName,
            OTMClient.JSONBodyKeys.MapString: updatedStudent!.mapString!,
            OTMClient.JSONBodyKeys.MediaURL: updatedStudent!.mediaURL!,
            OTMClient.JSONBodyKeys.Latitude: updatedStudent!.latitude!,
            OTMClient.JSONBodyKeys.Longitude: updatedStudent!.longtitude!
        ]
        
        taskForPOSTMethod(method, udacity: false, parameters: nil, jsonBody: jsonBody) { (result, error) in
            if let error = error {
                completionHandlerForStudentLocation(success: false, error: "Error Posting Data")
            } else {
                if let objectID = result.valueForKey("objectId") as? String {
                    completionHandlerForStudentLocation(success: true, error: nil)
                } else {
                    completionHandlerForStudentLocation(success: false, error: "Could not post location")
                }
            }
        }
    }

    // TODO: Querying and PUTing StudentLocation
}

