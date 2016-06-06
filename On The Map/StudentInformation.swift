//
//  StudentInformation.swift
//  On The Map
//
//  Created by James Dyer on 6/5/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation

struct StudentInformation {
    
    var firstName: String!
    var lastName: String!
    var latitude: Double!
    var longitude: Double!
    var mapString: String!
    var mediaURL: String!
    
    init(student: [String: AnyObject]) {
        guard let first = student["firstName"] as? String else { return }
        guard let last = student["lastName"] as? String else { return }
        guard let lat = student["latitude"] as? Double else { return }
        guard let long = student["longitude"] as? Double else { return }
        guard let map = student["mapString"] as? String else { return }
        guard let media = student["mediaURL"] as? String else { return }
        
        firstName = first
        lastName = last
        latitude = lat
        longitude = long
        mapString = map
        mediaURL = media
    }
}