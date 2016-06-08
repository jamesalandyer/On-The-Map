//
//  ParseClient.swift
//  On The Map
//
//  Created by James Dyer on 6/5/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class ParseClient: NSObject {
    
    typealias CompletionHandler = (result: AnyObject!, error: NSError?) -> Void
    
    var session = NSURLSession.sharedSession()
    
    /**
     Sends a request for information to parse.
     
     - Parameter parameters: The parameters that specify the type of information we want back.
     - Parameter completionHandlerForGet: Specify what to do once the data comes back.
     
     - Returns: NSURLSessionDataTask of the task that was ran.
     */
    func taskForGETMethod(parameters: [String: AnyObject], completionHandlerForGet: CompletionHandler) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters))
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard let data = data where error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGet)
        }
        
        task.resume()
        
        return task
    }
    
    /**
     Sends a request for information to parse.
     
     - Parameter method: The type of request being sent to parse.
     - Parameter jsonBody: The body of the request being sent to parse.
     - Parameter path: (Optional) The path added to the request to specify a certain location.
     - Parameter completionHandlerForPost: Specify what to do once the data comes back.
     
     - Returns: NSURLSessionDataTask of the task that was ran.
     */
    func taskForPOSTMethod(method: String, jsonBody: String, path: String?, completionHandlerForPost: CompletionHandler) -> NSURLSessionDataTask {
        
        let request = NSMutableURLRequest(URL: parseURLFromParameters(nil, withPathExtension: (path ?? "")))
        request.HTTPMethod = method
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard let data = data where error == nil else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPost)
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
     
     - Parameter parameters: (Optional) The information that is added to the end of the URL.
     - Parameter withPathExtension: (Optional) The string that will be added to the path of the URL.
     
     - Returns: NSURL that was configured.
     */
    private func parseURLFromParameters(parameters: [String: AnyObject]?, withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        if parameters != nil {
            for (key, value) in parameters! {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.URL!
    }
    
    /**
     Cretaes a shared instnace of the class.
     
     - Returns: ParseClient.
     */
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
}
