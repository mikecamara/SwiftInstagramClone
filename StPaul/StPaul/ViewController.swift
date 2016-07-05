//
//  ViewController.swift
//  StPaul
//
//  Created by Mike Camara on 7/01/2016.
//  Copyright © 2016 Mike Camara. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {
    

    
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    let facebookLogin = FBSDKLoginManager()
    
    var userFirstName: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

        
    }
    
    
    //Segues don't work on viewDidLoad, so we have to create this ViewDidAppear
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
        
        //if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    
    
    @IBAction func fbBtnAPressed(sender: UIButton!) {
        
        
        facebookLogin.logInWithReadPermissions(["public_profile", "email", "user_friends"]) {
            (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            
            
            
        
            
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                
                
                
                
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                
                print("Logged in! \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in!\(authData)")
                        
                        
                        // Get name and picture
                        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
                            let strFirstName: String = (result.objectForKey("first_name") as? String)!
                            
                            self.userFirstName = strFirstName
                            
                            let strLastName: String = (result.objectForKey("last_name") as? String)!
                            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
                            
    
                                                       
                            
                            NSUserDefaults.standardUserDefaults().setObject(strFirstName, forKey: "userName")
                                                    
                        // Create Firebase user
                        let user = ["provider": authData.provider!, "userFirstName": self.userFirstName!]
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        
                        //new end FBSDKGraph request
                        }
                    }
                    
                })
                
            }
        }
        

    }
    
    
   
    
    // Login user if account exists
    @IBAction func attemptLogin(sender: UIButton!) {
        
        var string = emailField.text
        let range = string!.rangeOfString("@")
            let firstPart = string!.substringToIndex(range!.startIndex)
            print(firstPart) // print Hello
             NSUserDefaults.standardUserDefaults().setObject(firstPart, forKey: "userName")
        
        
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != ""{
            
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {error, authData in
                
                if error != nil {
                    print(error)
                    //if account doesn't exist
                    if error.code == STATUS_ACCOUNT_NONEXIST {
                        
                        // Create a user
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problems creating account. Try Something else.")
                            } else {
                                //save the user and log they in
                                NSUserDefaults.standardUserDefaults().setValue(result [KEY_UID], forKey: KEY_UID)
                                NSUserDefaults.standardUserDefaults().setObject(firstPart, forKey: "userName")
                                
                                // Create firebase user with email login
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { err, authData in
                                    
                                    let user = ["provider": authData.provider!, "username": firstPart]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
                                    
                                })
                                
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                                
                            }
                            
                        })
                    } else {
                        
                        self.showErrorAlert("Could not log in", msg: "Please check your username or password.")
                        
                    }
                } else { // if there is not an error
                    
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
                
            })
            
            
        } else {
            showErrorAlert("Email and password required", msg: "You must enter an email and a password")
        }
        

    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
}









