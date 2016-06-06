//
//  UdacityConstants.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

extension UdacityClient {
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api"
    }
    
    struct Methods {
        static let Session = "/session"
        static let User = "/users"
    }
    
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    
    struct JSONResponseKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let UserKey = "key"
        static let Session = "session"
        static let SessionID = "id"
    }
    
}
