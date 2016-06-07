//
//  ListVC.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class ListVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: lightBlueColor], forState: .Selected)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: "newData", object: nil)
    }
    
    func reloadData() {
        
    }
}
