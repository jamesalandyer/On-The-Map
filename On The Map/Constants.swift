//
//  Constants.swift
//  On The Map
//
//  Created by James Dyer on 6/5/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation

let lightBlueColor = UIColor(red: 90 / 255, green: 200 / 255, blue: 250 / 255, alpha: 1.0)

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}