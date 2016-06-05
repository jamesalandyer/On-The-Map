//
//  LoginVC.swift
//  On The Map
//
//  Created by James Dyer on 6/4/16.
//  Copyright © 2016 James Dyer. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var udacityLoginButton: CustomButton!
    @IBOutlet weak var udacitySignupButton: UIButton!
    @IBOutlet weak var facebookLoginButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        setUIEnabled(true)
    }

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
        
        let jsonBody = "{\"\(UdacityClient.JSONBodyKeys.Udacity)\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(emailAddress)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
        
        let parameter = UdacityClient.Methods.Session
        
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
            
            DataService.sharedInstance.setUser(user)
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
    
    func setUIEnabled(enable: Bool) {
        emailAddressTextField.enabled = enable
        passwordTextField.enabled = enable
        udacityLoginButton.enabled = enable
        udacitySignupButton.enabled = enable
        facebookLoginButton.enabled = enable
        
        var alpha: CGFloat!
        
        if enable {
            alpha = 1.0
        } else {
            alpha = 0.5
        }
        
        emailAddressTextField.alpha = alpha
        passwordTextField.alpha = alpha
        udacityLoginButton.alpha = alpha
        udacitySignupButton.alpha = alpha
        facebookLoginButton.alpha = alpha
    }
    
    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    private func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    let facebookReadPermissions = ["public_profile", "email"]
    
    func loginToFacebookWithSuccess(callingViewController: UIViewController, successBlock: () -> (), andFailure failureBlock: (NSError?) -> ()) {
        
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
                            
                            DataService.sharedInstance.setUser(user)
                            successBlock()
                        }
                    })
                    
                } else {
                    failureBlock(nil)
                }
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailAddressTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
}
