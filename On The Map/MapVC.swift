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
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //Properties
    var annotations = [MKPointAnnotation]()
    
    //MARK: - Stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        tabBarController?.navigationItem.title = "ON THE MAP"
        tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: lightBlueColor], forState: .Selected)
        
        refreshData(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        if !DataService.sharedInstance.userLoggedIn {
            performSegueWithIdentifier("loginScreen", sender: nil)
        } else {
            if !hasUserInformation() {
                refreshData(true)
            }
        }
    }
    
    //MARK: - Information Check
    
    /**
     Checks if the app has the users first and last name stored.
     
     - Returns Bool: A Bool of whether we have both the first and last name.
     */
    private func hasUserInformation() -> Bool {
        if DataService.sharedInstance.userFirstName == FIELD_EMPTY || DataService.sharedInstance.userLastName == FIELD_EMPTY {
            return false
        }
        
        return true
    }
    
    /**
     Checks if the app has student location information stored.
     
     - Returns Bool: A Bool of whether we have student location information.
     */
    private func hasLocationInformation() -> Bool {
        if DataService.sharedInstance.studentLocations.count == 0 {
            return false
        }
        
        return true
    }
    
    //MARK: - Getting Infromation
    
    /**
     Gets the user information from Udacity.
     
     - Parameter completed: Handles the code to be executed after the request is complete.
     - Parameter success: A Bool of whether it was successful or not.
     */
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
    
    /**
     Gets student locations from Udacity.
     
     - Parameter completed: Handles the code to be executed after the request is complete.
     - Parameter success: A Bool of whether it was successful or not.
     */
    private func getStudentLocations(completed: (success: Bool) -> Void) {
        
        DataService.sharedInstance.emptyStudentLocations()
        
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
    
    /**
     Creates an array student locations and stores it.
     
     - Parameter students: Takes an array of dictionaries.
     - Parameter completed: Handles the code to be executed after the request is complete.
     - Parameter success: A Bool of whether it was successful or not.
     */
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
    
    /**
     Refreshes data for user first and last name and for student loactions.
     
     - Parameter skipLocations: A Bool whether to skip or download student loacations.
     */
    func refreshData(skipLocations: Bool) {
        
        showNavigatioBar(true, post: false)
        
        var hasName = true
        
        if DataService.sharedInstance.userFirstName == FIELD_EMPTY || DataService.sharedInstance.userLastName == FIELD_EMPTY {
            hasName = false
        }
        
        if !skipLocations {
            getStudentLocations { (success) in
                performUIUpdatesOnMain {
                    if success {
                        //The app must have the users name if they want to post a location
                        if hasName {
                            self.showNavigatioBar(false, post: true)
                        } else {
                            self.showNavigatioBar(false, post: false)
                        }
                        
                        self.setStudentLocationPins()
                        //Alert ListVC of new data
                        NSNotificationCenter.defaultCenter().postNotificationName("newData", object: nil)
                    } else {
                        self.showErrorAlert("Student Locations Couldn't Be Loaded", msg: "You are unable to view student locations.", type: "locations")
                        self.showNavigatioBar(false, post: false)
                    }
                }
            }
        }
        
        if !hasName && DataService.sharedInstance.userLoggedIn {
            getUserInformation { (success) in
                performUIUpdatesOnMain {
                    //The app must have the users name if they want to post a location
                    if success {
                        self.showNavigatioBar(false, post: true)
                    } else {
                        self.showErrorAlert("User Information Couldn't Be Loaded", msg: "You are unable to post a pin.", type: "user")
                        self.showNavigatioBar(false, post: false)
                    }
                }
            }
        }
    }
    
    //MARK: - MapView
    
    /**
     Sets the student location pins on the map.
     */
    private func setStudentLocationPins() {
        let locations = DataService.sharedInstance.studentLocations
        
        mapView.removeAnnotations(self.annotations)
        
        annotations = [MKPointAnnotation]()
        
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
            pinView!.pinTintColor = lightBlueColor
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
    
    //MARK: - Adjusting UI
    
    /**
     Shows an error alert and allows the user to choose whether to retry.
     
     - Parameter title: The header of the error alert.
     - Parameter msg: The message of the error alert.
     - Parameter type: Either user or locations and specifies what to do when the user chooses to retry request.
     */
    private func showErrorAlert(title: String, msg: String, type: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        if let type = type {
            let retry = UIAlertAction(title: "Retry", style: .Default) { (action) in
                if type == "user" {
                    self.refreshData(true)
                } else if type == "locations" {
                    self.refreshData(false)
                }
            }
            alert.addAction(retry)
        }
        performUIUpdatesOnMain { 
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Navigation Bar
    
    /**
     Sets up what the navigation bar looks like.
     
     - Parameter loading: A Bool of whether the navigation bar should be in loading mode.
     - Parameter post: A Bool whether the user should be able to post (The user can't post without a first and last name).
     */
    private func showNavigatioBar(loading: Bool, post: Bool) {
        
        var showNav = [UIBarButtonItem]()
        
        let logoutBarButton = UIBarButtonItem(title: "LOGOUT", style: .Done, target: self, action: #selector(logoutAccount))
        
        if loading {
            let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            loadingIndicator.frame = CGRectMake(0, 0, 26, 30)
            loadingIndicator.startAnimating()
            let loadingButton = UIBarButtonItem()
            loadingButton.customView = loadingIndicator
            
            showNav.append(loadingButton)
        } else {
            let refreshImage = UIImage(named: "Refresh.png")
            let refreshButton = UIButton()
            refreshButton.setImage(refreshImage, forState: .Normal)
            refreshButton.frame = CGRectMake(0, 0, 26, 30)
            refreshButton.addTarget(self, action: #selector(refreshData), forControlEvents: .TouchUpInside)
            let refreshBarButton = UIBarButtonItem()
            refreshBarButton.customView = refreshButton
            
            let postImage = UIImage(named: "post.png")
            let postButton = UIButton()
            postButton.setImage(postImage, forState: .Normal)
            postButton.frame = CGRectMake(0, 0, 26, 30)
            postButton.addTarget(self, action: #selector(postLocation), forControlEvents: .TouchUpInside)
            let postBarButton = UIBarButtonItem()
            postBarButton.customView = postButton
            
            let fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
            fixedSpace.width = 26.0
            
            showNav.append(refreshBarButton)
            showNav.append(fixedSpace)
            showNav.append(postBarButton)
            
            if !post {
                postBarButton.enabled = post
            } else {
                postBarButton.enabled = post
            }
        }
        
        tabBarController?.navigationItem.leftBarButtonItem = logoutBarButton
        tabBarController?.navigationItem.rightBarButtonItems = showNav
    }
    
    /**
     Shows the post screen when the user clicks on post, if the user is in the list tab it will alert the tab to open the post screen.
     */
    func postLocation() {
        let current = "\(tabBarController?.selectedViewController)"
        
        if current.containsString("MapVC") {
            performSegueWithIdentifier("addLocationMap", sender: nil)
        } else {
            //Alert the ListVC to show the post screen
            NSNotificationCenter.defaultCenter().postNotificationName("post", object: nil)
        }
        
    }
    
    /**
     Warns the user they are about to logout and then logs the user out of facebook, udacity and deletes their user id from the app or if the user is in the list tab tells the view to ask to logout.
     */
    func logoutAccount() {
        let current = "\(tabBarController?.selectedViewController)"
        
        if current.containsString("MapVC") {
            let alert = UIAlertController(title: "Logging Out", message: "Are you sure you want to logout?", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addAction(action)
            
            let retry = UIAlertAction(title: "Logout", style: .Destructive) { (action) in
                if FBSDKAccessToken.currentAccessToken() != nil {
                    FBSDKLoginManager().logOut()
                }
                
                DataService.sharedInstance.logoutUser()
                
                UdacityClient.sharedInstance().taskForDELETEMethod(UdacityClient.Methods.Session, completionHandlerForDelete: { (result, error) in
                    performUIUpdatesOnMain {
                        if error == nil {
                            self.performSegueWithIdentifier("loginScreen", sender: nil)
                        } else {
                            self.showErrorAlert("Unable To Logout", msg: "Please logout again.", type: nil)
                        }
                    }
                })
            }
            
            alert.addAction(retry)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            //Alert the ListVC to show the login screen
            NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
        }
    }

}

