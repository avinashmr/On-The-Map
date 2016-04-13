//
//  OTMClient.swift
//  On The Map
//
//  Created by Avinash Mudivedu on 4/12/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import Foundation

class OTMClient: NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // authentication state
    var sessionID: String? = nil
    var uniqueKey: String? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, udacity: Bool, parameters: [String:AnyObject]?, jsonBody: [String:AnyObject], completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var urlString: String
        
        if let methodParameters = parameters {
            urlString = method + escapedParameters(methodParameters)
        } else {
            urlString = method
        }
        
        
        /* 2/3. Build the URL, Configure the request */
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        /* Is the request Udacity or Parse? */
        if udacity {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
            
        } else {
            // TODO: Parse Request
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch _ as NSError {
            request.HTTPBody = nil
        }
        
    
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            if let JSONError = error {
                _ = OTMClient.errorForData(data, response: response, error: JSONError)
                completionHandlerForPOST(result: nil, error: error)
            } else {
                var newData = data
                if(udacity){// If it isn't for parse, it is for the Udacity API which it requires to ommit the first 5 characters for security reasons
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                }
                /* 5/6. Parse the data and use the data (happens in completion handler) */
                self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertData: completionHandlerForPOST)
            }
            
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // given raw JSON, return a usable Foundation object
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
    
    // MARK: Helper for error, see if a status_message is returned, otherwise return the previous error
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[OTMClient.JSONResponseKeys.StatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "On The Map Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    // MARK: Helper for Escaping Parameters in URL
    
    private func escapedParameters(parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}