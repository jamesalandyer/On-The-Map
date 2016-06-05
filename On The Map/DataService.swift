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
    
    var userId: String {
        return _userId
    }
    
    func setUser(id: String) {
        _userId = id
        NSUserDefaults.standardUserDefaults().setValue(id, forKey: "user")
    }
    
}