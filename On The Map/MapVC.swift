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
    
    override func viewWillAppear(animated: Bool) {
        getStudentLocations { (success) in
            if success {
                //tableView.reloadData()
                print("STUDENT LOCATIONS RECEIVED")
                print(DataService.sharedInstance.studentLocations.count)
                print(DataService.sharedInstance.studentLocations)
            } else {
                //show error
                print("STUDENT LOCATIONS FAILED")
            }
        }
        getUserInformation { (success) in
            if success {
                print("GOT IT!")
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if !userIsLoggedIn() {
            performSegueWithIdentifier("loginScreen", sender: nil)
        } else {
            
        }
    }
    
    func userIsLoggedIn() -> Bool {
        if DataService.sharedInstance.userId == "not_authorized" {
            return false
        }
        
        return true
    }
    
    
    
    func getUserInformation(completed: (success: Bool) -> Void) {
        UdacityClient.sharedInstance().taskForGETMethod("\(UdacityClient.Methods.User)/\(DataService.sharedInstance.userId)") { (result, error) in
            if error == nil {
                guard let result = result else {
                    completed(success: false)
                    return
                }
                
                guard let user = result["user"] as? [String: AnyObject] else {
                    completed(success: false)
                    return
                }
                
                guard let firstName = user["first_name"] as? String else {
                    completed(success: false)
                    return
                }
                
                guard let lastName = user["last_name"] as? String else {
                    completed(success: false)
                    return
                }
                
                DataService.sharedInstance.userFirstName = firstName
                DataService.sharedInstance.userLastName = lastName
                
                completed(success: true)
            } else {
                completed(success: false)
            }
            
        }
    }
    
    func getStudentLocations(completed: (success: Bool) -> Void) {
        
        let parameters = [
            "limit": 100,
            "order": "-updatedAt"
        ]
        
        ParseClient.sharedInstance().taskForGETMethod(parameters) { (result, error) in
            if error == nil {
                guard let students = result["results"] as? [[String: AnyObject]] else {
                    completed(success: false)
                    return
                }
                
                self.createStudentLocationsArray(students, completed: completed)
            } else {
                completed(success: false)
            }
        }
    }
    
    func createStudentLocationsArray(students: [[String: AnyObject]], completed: (success: Bool) -> Void) {
        
        for student in students {
            guard let firstName = student["firstName"] as? String else { return }
            guard let lastName = student["lastName"] as? String else { return }
            guard let latitude = student["latitude"] as? Double else { return }
            guard let longitude = student["longitude"] as? Double else { return }
            guard let mapString = student["mapString"] as? String else { return }
            guard let mediaURL = student["mediaURL"] as? String else { return }
            
            let studentInformation = StudentInformation(firstName: firstName, lastName: lastName, latitude: latitude, longitude: longitude, mapString: mapString, mediaURL: mediaURL)
            
            DataService.sharedInstance.studentLocations = [studentInformation]
        }
        
        if DataService.sharedInstance.studentLocations.count > 0 {
           completed(success: true)
        } else {
            completed(success: false)
        }
        
    }


}

