//
//  MapVC.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class MapVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if !userIsLoggedIn() {
            performSegueWithIdentifier("loginScreen", sender: nil)
        }
    }
    
    func userIsLoggedIn() -> Bool {
        if DataService.sharedInstance.userId == "not_authorized" {
            return false
        }
        
        return true
    }


}

