//
//  UdacityClient.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {
    
    static let sharedInstance = UdacityClient()

    typealias CompletionHandler = (result: AnyObject!, error: NSError?) -> Void
    
    var session = NSURLSession.sharedSession()
    
    /**
     Sends a request for information to udacity.
     
     - Parameter method: The type of request being sent to parse.
     - Parameter jsonBody: The body of the request being sent to udacity.
     - Parameter completionHandlerForPost: Specify what to do once the data comes back.
     
     - Returns: NSURLSessionDataTask of the task that was ran.
     */
    func taskForPOSTMethod(method: String, jsonBody: String, completionHandlerForPost: CompletionHandler) -> NSURLSessionDataTask {
    
        let request = NSMutableURLRequest(URL: udacityURLFromMethod(method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2XX!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPost)
        }
        
        task.resume()
        
        return task
    }
    
    /**
     Sends a request to delete a session from udacity.
     
     - Parameter method: The method to be added to the path of the request.
     - Parameter completionHandlerForDelete: Specify what to do once the data comes back.
     
     - Returns: NSURLSessionDataTask of the task that was ran.
     */
    func taskForDELETEMethod(method: String, completionHandlerForDelete: CompletionHandler) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: udacityURLFromMethod(method))
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDelete)
        }
        
        task.resume()
        
        return task
    }
    
    /**
     Sends a request for information to udacity.
     
     - Parameter method: The method to be added to the path of the request.
     - Parameter completionHandlerForGET: Specify what to do once the data comes back.
     
     - Returns: NSURLSessionDataTask of the task that was ran.
     */
    func taskForGETMethod(method: String, completionHandlerForGET: CompletionHandler) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: udacityURLFromMethod(method))
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        
        return task
    }
    
    /**
     Converts the data to be readable by Swift.
     
     - Parameter data: The data being converted.
     - Parameter completionHandlerForConvertData: Specify what to do once the data is done.
     */
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: CompletionHandler) {
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "converDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    /**
     Sets up the URL.
     
     - Parameter method: The method to add to the end of the path.
     
     - Returns: NSURL that was configured.
     */
    private func udacityURLFromMethod(method: String) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + method
        
        return components.URL!
    }
    
}
