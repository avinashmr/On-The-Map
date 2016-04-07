//
//  UClient.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/7/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import Foundation

class UClient: NSObject {
    
    // MARK: Properties
    
    // Shared Session
    var session = NSURLSession.sharedSession()
    
    // Authentication State
    var userID: String? = nil
    var objectID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Login and create a session
    func createASession(username: String!, password: String, completionHandlerForSession: (success: Bool, userID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let URL = NSURL(string: UClient.Constants.AuthorizationURL)
        print(URL)
        
        /* 2. Configure the request */
        let request = NSMutableURLRequest(URL: URL!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            func sendError(error: String) {
                print(error)
                completionHandlerForSession(success: false, userID: nil, errorString: "error")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data as JSON: '\(data)")
                return
            }
            
            // TODO: Insert Status code check
            
            guard (parsedResult.objectForKey("status_code") == nil) else {
                print("The DB returned an error. See the status_code and status_message in \(parsedResult)")
                completionHandlerForSession(success: false, userID:nil, errorString: "Network Error")
                return
            }
            
            /* GUARD: is the account key in parsedResult? */
            guard let account = parsedResult["account"] as? NSDictionary else {
                completionHandlerForSession(success: false, userID:nil, errorString: "Error Error")
                print("account failed.")
                return
            }
            
            /* GUARD: does the userID exist in the account? */
            guard let userID = account["key"] as? String else {
                completionHandlerForSession(success: false, userID:nil, errorString: "Error")
                print("failed to aquire user id")
                return
            }
            
            print(userID)
            completionHandlerForSession(success: true, userID: userID, errorString: nil)
            
        }
        task.resume()
        
    }
    
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    private func UURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = UClient.Constants.ApiScheme
        components.host = UClient.Constants.ApiHost
        components.path = UClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UClient {
        
        struct Singleton {
            static var sharedInstance = UClient()
        }
        
        return Singleton.sharedInstance
    }
}