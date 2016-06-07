//
//  LocationVC.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit
import MapKit

class LocationVC: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var findOnMapButton: CustomButton!
    @IBOutlet weak var submitButton: CustomButton!
    
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    var previousPostObjectId: String!
    var userInformation = [String: AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationTextField.delegate = self
        urlTextField.delegate = self
        locationMapView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        urlScreenHidden(true)
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnMapButtonPressed(sender: AnyObject) {
        setUI(false, locationScreen: true)
        guard let text = locationTextField.text where text != "" else {
            //print error
            return
        }
        geocodeAddress(text) { (success) in
            if success {
                self.userInformation["firstName"] = DataService.sharedInstance.userFirstName
                self.userInformation["lastName"] = DataService.sharedInstance.userLastName
                self.userInformation["mapString"] = text
                
                performUIUpdatesOnMain {
                    self.setUI(true, locationScreen: true)
                    self.urlScreenHidden(false)
                    self.setLocationPin()
                }
            } else {
                //show error
            }
        }
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        guard let text = urlTextField.text where text != "" else {
            //print error
            return
        }
        userInformation["mediaURL"] = text
        
        let student = StudentInformation(student: userInformation)
        let jsonBody = "{\"uniqueKey\": \"\(DataService.sharedInstance.userId)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}"
        
        checkIfPostExists { (success) in
            if success {
                
            } else {
                print("NO")
                print(jsonBody)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "userPin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = lightBlueColor
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        let pin = views[0].annotation?.coordinate
        
        let span = MKCoordinateSpanMake(0.1, 0.1)
        
        let region = MKCoordinateRegionMake(pin!, span)
        locationMapView.setRegion(region, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        locationTextField.resignFirstResponder()
        urlTextField.resignFirstResponder()
    }
    
    func geocodeAddress(address: String, completed: (success: Bool) -> Void) {
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if error != nil {
                print("ERROR")
                completed(success: false)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks![0]
                guard let location = placemark.location else {
                    completed(success: false)
                    return
                }
                let coordinate = location.coordinate
                self.userInformation["longitude"] = coordinate.longitude
                self.userInformation["latitude"] = coordinate.latitude
                
                completed(success: true)
            } else {
                print("ERROR")
                completed(success: false)
            }
        }
    }
    
    func setLocationPin() {
        let lat = CLLocationDegrees(userInformation["latitude"] as! Double)
        let long = CLLocationDegrees(userInformation["longitude"] as! Double)
            
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        locationMapView.addAnnotation(annotation)
    }
    
    func urlScreenHidden(hidden: Bool) {
        urlView.hidden = hidden
        urlTextField.hidden = hidden
        submitButton.hidden = hidden
        locationMapView.hidden = hidden
    }
    
    func setUI(enable: Bool, locationScreen: Bool) {
        
        if enable {
            loadingIndicator.removeFromSuperview()
        } else {
            loadingIndicator.center = view.center
            view.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
        }
        if locationScreen {
            locationTextField.enabled = enable
            findOnMapButton.enabled = enable
        } else {
            urlTextField.enabled = enable
            submitButton.enabled = enable
        }
    }
    
    func checkIfPostExists(completed: (success: Bool) -> Void) {
        let parameter = [
            "where": "%7B%22uniqueKey%22%3A%22\(DataService.sharedInstance.userId)%22%7D"
        ]
        ParseClient.sharedInstance().taskForGETMethod(parameter) { (result, error) in
            if error != nil {
                completed(success: false)
                return
            }
            
            guard let result = result["results"] as? [[String: AnyObject]] else {
                completed(success: false)
                return
            }
            
            guard let object = result[0]["objectId"] as? String else {
                completed(success: false)
                return
            }
            
            self.previousPostObjectId = object
            completed(success: true)
        }
    }
    
    func createPost(information: StudentInformation, jsonBody: String, completed: (success: Bool) -> Void) {
        ParseClient.sharedInstance().taskForPOSTMethod("POST", parameters: [String: AnyObject](), jsonBody: jsonBody) { (result, error) in
            if error != nil {
                completed(success: false)
                return
            }
            
            guard (result["objectId"] as? String) != nil else {
                completed(success: false)
                return
            }
            
            completed(success: true)
        }
    }
    
    func updatePost(information: StudentInformation, jsonBody: String, completed: (success: Bool) -> Void) {
        
    }
}
