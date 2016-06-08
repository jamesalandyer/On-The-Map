//
//  LoginVC.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var udacityLoginButton: CustomButton!
    @IBOutlet weak var udacitySignupButton: UIButton!
    @IBOutlet weak var facebookLoginButton: CustomButton!
    
    //Properties
    let facebookReadPermissions = ["public_profile", "email"]
    
    //MARK: - Stack
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        setUIEnabled(true)
    }
    
    //MARK: - Actions
    
    @IBAction func udacityLoginButtonPressed(sender: AnyObject) {
        
        guard let emailAddress = emailAddressTextField.text where emailAddress != "" && isValidEmail(emailAddress) else {
            showErrorAlert("Invalid Email Address", msg: "Please enter a valid email address.")
            return
        }
        
        guard let password = passwordTextField.text where password != "" else {
            showErrorAlert("Invalid Password", msg: "Please enter a password.")
            return
        }
        
        setUIEnabled(false)
        
        let parameter = UdacityClient.Methods.Session
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(emailAddress)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        UdacityClient.sharedInstance().taskForPOSTMethod(parameter, jsonBody: jsonBody) { (result, error) in
            
            func displayError(title: String, msg: String) {
                performUIUpdatesOnMain {
                    self.showErrorAlert(title, msg: msg)
                    self.setUIEnabled(true)
                }
            }
            
            guard error == nil else {
                displayError("Invalid Email Or Password", msg: "Please check your credentials and login again.")
                return
            }
            
            guard let result = result else {
                displayError("Error Retrieving Data", msg: "Please login again.")
                return
            }
            
            guard let account = result[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] else {
                displayError("Unable To Verify Account", msg: "Please login again.")
                return
            }
            
            guard let user = account[UdacityClient.JSONResponseKeys.UserKey] as? String else {
                displayError("Unable To Find User", msg: "Please login again.")
                return
            }
            
            DataService.sharedInstance.userId = user
            
            performUIUpdatesOnMain {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func facebookLoginButtonPressed(sender: AnyObject) {
        setUIEnabled(false)
        
        loginToFacebookWithSuccess(self, successBlock: {
            performUIUpdatesOnMain {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            }) { (error) in
                performUIUpdatesOnMain {
                    self.showErrorAlert("Facebook Was Not Authenicated", msg: "Please login again")
                }
        }
    }
    
    @IBAction func udacitySignupButtonPressed(sender: AnyObject) {
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //MARK: - UI
    
    /**
    Sets the UI for the login screen for both enabling and to change the alpha.
     
    - Parameter enable: A Bool of whether to enable the UI.
    */
    private func setUIEnabled(enable: Bool) {
        emailAddressTextField.enabled = enable
        passwordTextField.enabled = enable
        udacityLoginButton.enabled = enable
        udacitySignupButton.enabled = enable
        facebookLoginButton.enabled = enable
        
        var alpha: CGFloat!
        
        alpha = enable ? 1.0 : 0.5
        
        emailAddressTextField.alpha = alpha
        passwordTextField.alpha = alpha
        udacityLoginButton.alpha = alpha
        udacitySignupButton.alpha = alpha
        facebookLoginButton.alpha = alpha
    }
    
    /**
     Checks whether a string is a valid email address.
     
     - Parameter testStr: The string that needs to be tested.
     
     - Returns: A Bool whether it is valid.
     */
    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
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
     Shows an alert to the user of an error.
     
     - Parameter callingViewController: The ViewController that is calling the method.
     - Parameter successBlock: Handles the code to be executed when the request is successful.
     - Parameter andFailure: Handles the code to be executed when the request has an error.
     */
    private func loginToFacebookWithSuccess(callingViewController: UIViewController, successBlock: () -> (), andFailure failureBlock: (NSError?) -> ()) {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            return
        }
        
        FBSDKLoginManager().logInWithReadPermissions(facebookReadPermissions, fromViewController: callingViewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                FBSDKLoginManager().logOut()
                failureBlock(error)
            } else if result.isCancelled {
                FBSDKLoginManager().logOut()
                failureBlock(nil)
            } else {
                
                var allPermsGranted = true
                
                let grantedPermissions = Array(result.grantedPermissions).map( {"\($0)"} )
                for permission in self.facebookReadPermissions {
                    if !grantedPermissions.contains(permission) {
                        allPermsGranted = false
                        break
                    }
                }
                
                if allPermsGranted {
                    
                    let fbToken = result.token.tokenString
                    
                    let parameter = UdacityClient.Methods.Session
                    let jsonBody = "{\"facebook_mobile\": {\"access_token\": \"\(fbToken)\"}}"
                    
                    UdacityClient.sharedInstance().taskForPOSTMethod(parameter, jsonBody: jsonBody, completionHandlerForPost: { (result, error) in
                        if error != nil {
                            failureBlock(error)
                        } else {
                            guard let result = result else {
                                failureBlock(nil)
                                return
                            }
                            
                            guard let account = result[UdacityClient.JSONResponseKeys.Account] as? [String: AnyObject] else {
                                failureBlock(nil)
                                return
                            }
                            
                            guard let user = account[UdacityClient.JSONResponseKeys.UserKey] as? String else {
                                failureBlock(nil)
                                return
                            }
                            
                            DataService.sharedInstance.userId = user
                            successBlock()
                        }
                    })
                    
                } else {
                    failureBlock(nil)
                }
            }
        })
    }
    
    //MARK: - TextField
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Touches
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailAddressTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
}
