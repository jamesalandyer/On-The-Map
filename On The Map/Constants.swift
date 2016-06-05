//
//  Constants.swift
//  On The Map
//
//  Created by James Dyer on 6/5/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}