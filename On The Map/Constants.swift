//
//  Constants.swift
//  On The Map
//
//  Created by James Dyer on 6/5/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation

//Marks the field as empty
let FIELD_EMPTY = "field_empty"

//The main color of the app
let lightBlueColor = UIColor(red: 90 / 255, green: 200 / 255, blue: 250 / 255, alpha: 1.0)

//Switchs to the main queue to update UI
func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}