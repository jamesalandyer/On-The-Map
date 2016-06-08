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
    
    private var _userLoggedIn = false
    private var _userId: String = FIELD_EMPTY
    private var _userFirstName: String = FIELD_EMPTY
    private var _userLastName: String = FIELD_EMPTY
    private var _studentLocations = [StudentInformation]()
    
    var userId: String {
        get {
            if let user = NSUserDefaults.standardUserDefaults().stringForKey("user") {
                return user
            }
            
            return _userId
        }
        set {
            _userLoggedIn = true
            _userId = newValue
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
    
    var userLoggedIn: Bool {
        if !_userLoggedIn {
            if _userId != FIELD_EMPTY {
                _userLoggedIn = true
            }
        } else {
            return _userLoggedIn
        }
        return false
    }
    
    var studentLocations: [StudentInformation] {
        get {
            return _studentLocations
        }
        set {
            _studentLocations.append(newValue[0])
        }
    }
    
    /**
    Empties out the student locations that the app has stored.
    */
    func emptyStudentLocations() {
        _studentLocations = [StudentInformation]()
    }
    
    /**
     Logs the user out by deleteing the user id and marking them as not being logged in.
     */
    func logoutUser() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("user")
        _userLoggedIn = false
    }
    
}