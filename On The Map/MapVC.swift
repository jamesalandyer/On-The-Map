//
//  MapVC.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        tabBarController?.navigationItem.title = "On The Map"
    }
    
    override func viewWillAppear(animated: Bool) {
        if !hasLocationInformation() {
            getStudentLocations { (success) in
                if success {
                    performUIUpdatesOnMain({ 
                        self.setStudentLocationPins()
                    })
                } else {
                    self.showErrorAlert("Student Locations Couldn't Be Loaded", msg: "You are unable to view student locations.", type: "locations")
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if !userIsLoggedIn() {
            performSegueWithIdentifier("loginScreen", sender: nil)
        } else {
            if !hasUserInformation() {
                getUserInformation { (success) in
                    if success {
                        
                    } else {
                        self.showErrorAlert("User Information Couldn't Be Loaded", msg: "You are unable to post a pin.", type: "user")
                    }
                }
            }
        }
    }
    
    private func userIsLoggedIn() -> Bool {
        if DataService.sharedInstance.userId == "not_authorized" {
            return false
        }
        
        return true
    }
    
    private func hasUserInformation() -> Bool {
        if DataService.sharedInstance.userFirstName != "not_authorized" || DataService.sharedInstance.userLastName != "not_authorized" {
            return false
        }
        
        return true
    }
    
    private func hasLocationInformation() -> Bool {
        if DataService.sharedInstance.studentLocations.count == 0 {
            return false
        }
        
        return true
    }
    
    private func getUserInformation(completed: (success: Bool) -> Void) {
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
    
    private func getStudentLocations(completed: (success: Bool) -> Void) {
        
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
    
    private func createStudentLocationsArray(students: [[String: AnyObject]], completed: (success: Bool) -> Void) {
        
        for student in students {
            let studentInformation = StudentInformation(student: student)
            DataService.sharedInstance.studentLocations = [studentInformation]
        }
        
        if DataService.sharedInstance.studentLocations.count > 0 {
            completed(success: true)
        } else {
            completed(success: false)
        }
        
    }
    
    private func setStudentLocationPins() {
        let locations = DataService.sharedInstance.studentLocations
        
        var annotations = [MKPointAnnotation]()
        
        for location in locations {
            
            let lat = CLLocationDegrees(location.latitude)
            let long = CLLocationDegrees(location.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = location.firstName
            let last = location.lastName
            let mediaURL = location.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor(red: 90 / 255, green: 200 / 255, blue: 250 / 255, alpha: 1.0)
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                if let url = NSURL(string: toOpen) {
                    if !app.openURL(url) {
                        showErrorAlert("Not A Valid Link", msg: "The user has entered an invalid url.", type: nil)
                    } else {
                        app.openURL(url)
                    }
                }
            }
        }
    }
    
    private func showErrorAlert(title: String, msg: String, type: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        if let type = type {
            let retry = UIAlertAction(title: "Retry", style: .Default) { (action) in
                if type == "user" {
                    self.getUserInformation({ (success) in
                        if !success {
                            print(1)
                            self.showErrorAlert("User Information Couldn't Be Loaded", msg: "You are unable to post a pin.", type: "user")
                        }
                    })
                } else if type == "locations" {
                    self.getStudentLocations({ (success) in
                        if !success {
                            print(0)
                            self.showErrorAlert("Student Locations Couldn't Be Loaded", msg: "You are unable to view student locations.", type: "locations")
                        }
                    })
                }
            }
            alert.addAction(retry)
        }
        alert.addAction(action)
        performUIUpdatesOnMain { 
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    

}

