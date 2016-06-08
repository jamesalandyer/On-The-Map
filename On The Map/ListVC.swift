//
//  ListVC.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class ListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Stack
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: lightBlueColor], forState: .Selected)
        
        //Listen for new data to refresh the table
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: "newData", object: nil)
        //Listen for post to open the post screen
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showPostScreen), name: "post", object: nil)
        //Listen for logout to show the login screen
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(logout), name: "logout", object: nil)
    }
    
    //MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataService.sharedInstance.studentLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let student = DataService.sharedInstance.studentLocations[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("StudentCell") as? StudentCell {
            
            cell.configureCell(student)
            
            return cell
        } else {
            return StudentCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = DataService.sharedInstance.studentLocations[indexPath.row]
        
        let mediaURL = student.mediaURL
        
        let app = UIApplication.sharedApplication()
        if let url = NSURL(string: mediaURL) {
            if !app.openURL(url) {
                showErrorAlert("Not A Valid Link", msg: "The user has entered an invalid url.")
            } else {
                app.openURL(url)
            }
        }
    }
    
    //MARK: - Adjusting UI
    
    /**
     Shows an alert to the user of an error.
     
     - Parameter title: The header of the alert.
     - Parameter msg: The message of the alert.
     */
    private func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    /**
     Refreshs the table view.
     */
    func reloadData() {
        tableView.reloadData()
    }
    
    /**
     Shows the post screen.
     */
    func showPostScreen() {
        performSegueWithIdentifier("addLocationList", sender: nil)
    }
    
    /**
     Warns the user they are about to logout and then logs the user out of facebook, udacity and deletes their user id from the app.
     */
    func logout() {
        let alert = UIAlertController(title: "Logging Out", message: "Are you sure you want to logout?", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alert.addAction(action)
        let retry = UIAlertAction(title: "Logout", style: .Destructive) { (action) in
            if FBSDKAccessToken.currentAccessToken() != nil {
                FBSDKLoginManager().logOut()
            }
            
            DataService.sharedInstance.logoutUser()
            
            UdacityClient.sharedInstance.taskForDELETEMethod(UdacityClient.Methods.Session, completionHandlerForDelete: { (result, error) in
                performUIUpdatesOnMain {
                    if error == nil {
                        self.performSegueWithIdentifier("logoutScreen", sender: nil)
                        
                    } else {
                        self.showErrorAlert("Unable To Logout", msg: "Please logout again.")
                    }
                }
            })
        }
        alert.addAction(retry)
        presentViewController(alert, animated: true, completion: nil)
    }
}
