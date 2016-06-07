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
    
    private var _userId: String = NSUserDefaults.standardUserDefaults().stringForKey("user") ?? FIELD_EMPTY
    private var _userFirstName: String = FIELD_EMPTY
    private var _userLastName: String = FIELD_EMPTY
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
            _userFirstName = newValue
        }
    }
    
    var userLastName: String {
        get {
            return _userLastName
        }
        set {
            _userLastName = newValue
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
    
    func emptyStudentLocations() {
        _studentLocations = [StudentInformation]()
    }
    
}