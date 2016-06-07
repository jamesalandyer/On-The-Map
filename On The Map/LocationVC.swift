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
        setUI(false)
        guard let text = locationTextField.text where text != "" else {
            showAlert("Invalid Location", msg: "Please enter a location.", update: nil)
            return
        }
        geocodeAddress(text) { (success) in
            if success {
                self.userInformation["firstName"] = DataService.sharedInstance.userFirstName
                self.userInformation["lastName"] = DataService.sharedInstance.userLastName
                self.userInformation["mapString"] = text
                
                performUIUpdatesOnMain {
                    self.setUI(true)
                    self.urlScreenHidden(false)
                    self.setLocationPin()
                }
            } else {
                self.showAlert("Unable To Find Location", msg: "Please double check your location and try again.", update: nil)
            }
        }
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        setUI(false)
        guard let text = urlTextField.text where text != "" else {
            showAlert("Invalid Url", msg: "Please enter a url.", update: nil)
            return
        }
        userInformation["mediaURL"] = text
        
        checkIfPostExists { (success) in
            if success {
                self.showAlert("You Already Have Posted", msg: "Do you want to update your post?", update: true)
            } else {
                self.sendPost(ParseClient.Methods.Post, path: nil, completed: { (success) in
                    performUIUpdatesOnMain {
                        if success {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            self.showAlert("Unable To Send Post", msg: "Your post was unable to send. Please try again.", update: false)
                        }
                    }
                })
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "userPin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
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
        annotation.title = "YOU"
        
        locationMapView.addAnnotation(annotation)
    }
    
    func urlScreenHidden(hidden: Bool) {
        urlView.hidden = hidden
        urlTextField.hidden = hidden
        submitButton.hidden = hidden
        locationMapView.hidden = hidden
    }
    
    func setUI(enable: Bool) {
        
        if enable {
            loadingIndicator.removeFromSuperview()
        } else {
            loadingIndicator.center = view.center
            view.addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
        }
        locationTextField.enabled = enable
        findOnMapButton.enabled = enable
        urlTextField.enabled = enable
        submitButton.enabled = enable
    }
    
    func checkIfPostExists(completed: (success: Bool) -> Void) {
        let parameter = [
            "where": "{\"uniqueKey\":\"\(DataService.sharedInstance.userId)\"}"
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
    
    func sendPost(method: String, path: String?, completed: (success: Bool) -> Void) {
        let student = StudentInformation(student: userInformation)
        let jsonBody = "{\"uniqueKey\": \"\(DataService.sharedInstance.userId)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"\(student.mapString)\", \"mediaURL\": \"\(student.mediaURL)\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}"
        
        ParseClient.sharedInstance().taskForPOSTMethod(method, jsonBody: jsonBody, path: (path ?? "")) { (result, error) in
            if error != nil {
                completed(success: false)
                return
            }
            
            if method == ParseClient.Methods.Post {
                guard (result["objectId"] as? String) != nil else {
                    completed(success: false)
                    return
                }
            } else {
                guard (result["updatedAt"] as? String) != nil else {
                    completed(success: false)
                    return
                }
            }
            
            
            completed(success: true)
        }
    }
    
    private func showAlert(title: String, msg: String, update: Bool?) {
        var button = "Ok"
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        if update != nil {
            let send = UIAlertAction(title: "Update", style: .Default) { (action) in
                self.sendPost(ParseClient.Methods.Put, path: "/\(self.previousPostObjectId)", completed: { (success) in
                    performUIUpdatesOnMain {
                        if success {
                           self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            self.showAlert("Unable To Update Post", msg: "Please try again", update: true)
                        }
                    }
                })
            }
            alert.addAction(send)
            button = "Cancel"
        }
        let action = UIAlertAction(title: button, style: .Default, handler: nil)
        alert.addAction(action)
        performUIUpdatesOnMain {
            self.presentViewController(alert, animated: true, completion: nil)
            self.setUI(true)
        }
    }
}
