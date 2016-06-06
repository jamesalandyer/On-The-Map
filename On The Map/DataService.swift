//
//  DataService.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation

class DataService {
    
    static let sharedInstance = DataService()
    
    private var _userId: String = NSUserDefaults.standardUserDefaults().stringForKey("user") ?? "not_authorized"
    private var _userFirstName: String = NSUserDefaults.standardUserDefaults().stringForKey("firstName") ?? "not_authorized"
    private var _userLastName: String = NSUserDefaults.standardUserDefaults().stringForKey("lastName") ?? "not_authorized"
    private var _studentLocations = [StudentInformation]()
    
    var userId: String {
        get {
           return _userId
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "user")
        }
    }
    
    var userFirstName: String {
        get {
            return _userFirstName
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "firstName")
        }
    }
    
    var userLastName: String {
        get {
            return _userLastName
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "lastName")
        }
    }
    
    var studentLocations: [StudentInformation] {
        get {
            return _studentLocations
        }
        set {
            _studentLocations.append(newValue[0])
        }
    }
    
}