//
//  SignupViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit

class SignupViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupFormContainer: UIView!
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var signupWithFacebookBtn: FBSDKLoginButton!
    
    @IBOutlet weak var contentView: UIView!
    
    var bypassToFbSignup: Bool?
    
    var fbEmail: String? = nil
    var fbFirstname: String? = nil
    var fbLastname: String? = nil
    var fbAccessToken: FBSDKAccessToken? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        identifierTextField.delegate = self
        phoneTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        configureFacebookButton()
        addTapGestureRecognizer()
        applyStyle()
        if bypassToFbSignup == true {
            if let token = FBSDKAccessToken.currentAccessToken() {
                signupWithFacebook(token)
            }
            else {
                signupWithFacebookBtn.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSizeMake(view.frame.width, contentView.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configureFacebookButton() {
        signupWithFacebookBtn.delegate = self
        signupWithFacebookBtn.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    private func applyStyle() {
        identifierTextField.borderStyle = UITextBorderStyle.None
        passwordTextField.borderStyle = UITextBorderStyle.None
        confirmPasswordTextField.borderStyle = UITextBorderStyle.None
        firstnameTextField.borderStyle = UITextBorderStyle.None
        lastnameTextField.borderStyle = UITextBorderStyle.None
        phoneTextField.borderStyle = UITextBorderStyle.None
        usernameTextField.borderStyle = UITextBorderStyle.None
        signupFormContainer.layer.cornerRadius = 8
        signupFormContainer.layer.masksToBounds = true
        signupFormContainer.layer.borderWidth = 1
        signupFormContainer.layer.borderColor = UIColor.purpleYn().CGColor
        
        signinBtn.layer.borderWidth = 1
        signinBtn.layer.borderColor = UIColor.purpleYn().CGColor
        signinBtn.layer.cornerRadius = 8
        
        signupWithFacebookBtn.layer.cornerRadius = 8
    }
    
    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapGestureHandler(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInset
    }
    
    private func validateForm() -> Bool {
        if (identifierTextField.text == nil && phoneTextField.text == nil) || (identifierTextField.text?.isEmpty == true && phoneTextField.text?.isEmpty == true) {
            let alertController = UIAlertController(title: "Email or phone required", message: "Please enter your email address and/or your phone number.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.identifierTextField.becomeFirstResponder()
            }))
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        else if usernameTextField.text == nil || usernameTextField.text?.isEmpty == true {
            let alertController = UIAlertController(title: "Username required", message: "Please choose an username.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.usernameTextField.becomeFirstResponder()
            }))
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        else if passwordTextField.text == nil || passwordTextField.text?.isEmpty == true {
            let alertController = UIAlertController(title: "Password required", message: "Please choose a password", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.passwordTextField.becomeFirstResponder()
            }))
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        else if passwordTextField.text != confirmPasswordTextField.text {
            let alertController = UIAlertController(title: "Password does not match", message: "Password and password confirmation does not match. Please try again", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.confirmPasswordTextField.becomeFirstResponder()
            }))
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    private func signup() {
        if validateForm() {
            var identifier: String = ""
            var params = [
                "username": usernameTextField.text!,
                "password": passwordTextField.text!,
                "confirmPassword": confirmPasswordTextField.text!,
            ]
            if (identifierTextField.text?.isEmpty == false) {
                params["email"] = identifierTextField.text!
                identifier = params["email"]!
            }
            if (phoneTextField.text?.isEmpty == false) {
                params["phone"] = phoneTextField.text!
                identifier = params["phone"]!
            }
            if (firstnameTextField.text?.isEmpty == false) {
                params["firstname"] = firstnameTextField.text!
            }
            if (lastnameTextField.text?.isEmpty == false) {
                params["lastname"] = lastnameTextField.text!
            }
            do {
                try Alamofire.request(.POST, ApiUrls.getUrl("signup"), parameters: params).responseJSON(completionHandler: { (response) in
                    let apiHandler = ApiHandler.sharedInstance
                    let password = params["password"]!
                    apiHandler.authenticate(identifier: identifier, password: password, completion: { (success: Bool) in
                        if success {
                            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = mainStoryboard.instantiateInitialViewController()
                            dispatch_async(dispatch_get_main_queue(), {
                                self.presentViewController(vc!, animated: true, completion: nil)
                            })
                        }
                        else {
                            let alertController = UIAlertController(title: "An error occured", message: "Sorry, something went wrong. Our tech team work on this issue, please try again later", preferredStyle: UIAlertControllerStyle.Alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            dispatch_async(dispatch_get_main_queue(), {
                                self.presentViewController(alertController, animated: true, completion: nil)
                            })
                        }
                    })
                })
            } catch let error as ApiError {
                print("error: \(error)")
            } catch {
                print("Unexpected error")
            }
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case identifierTextField:
            phoneTextField.becomeFirstResponder()
            break
        case phoneTextField:
            usernameTextField.becomeFirstResponder()
            break
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
            break
        case confirmPasswordTextField:
            firstnameTextField.becomeFirstResponder()
            break
        case firstnameTextField:
            lastnameTextField.becomeFirstResponder()
            break
        case lastnameTextField:
            signup()
            break
        default:
            print("An Error occured")
        }
        return true
    }
    
    private func signupWithFacebook(token: FBSDKAccessToken) {
        let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name"], tokenString: token.tokenString, version: nil, HTTPMethod: "GET")
        req.startWithCompletionHandler({ (requestConnection: FBSDKGraphRequestConnection!, object: AnyObject!, error: NSError!) in
            if error == nil {
                let graphResult = object as! Dictionary<String, AnyObject>
                self.fbEmail = graphResult["email"] as? String
                self.fbFirstname = graphResult["first_name"] as? String
                self.fbLastname = graphResult["last_name"] as? String
                self.fbAccessToken = token
                if self.fbFirstname != nil && self.fbFirstname != nil && self.fbLastname != nil && self.fbAccessToken != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.performSegueWithIdentifier("signupWithFacebook", sender: self)
                    }
                }
                else {
                    let alertView = UIAlertController(title: "An error occured", message: "Unable to fetch some information from Facebook", preferredStyle: UIAlertControllerStyle.Alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default
                        , handler: nil))
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
            }
            else {
                print("error: \(error)")
            }
        })
    }
    
    // MARK: - FBSDKLoginButtonDelegate
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            signupWithFacebook(result.token)
        }
        else {
            //TODO: Error handling
            print("error: \(error)")
        }
    }
    //MARK: - @IBAction
    @IBAction func signinButtonTapped(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func signupButtonTapped(sender: UIButton) {
        //TODO: Call signup method
        signup()
    }
    
    @IBAction func signupWithFacebookButtonTapped(sender: FBSDKLoginButton) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signupWithFacebook" {
            let vc = segue.destinationViewController as! SignupWithFacebookViewController
            vc.email = fbEmail
            vc.firstname = fbFirstname
            vc.lastname = fbLastname
            vc.accessToken = fbAccessToken
        }
    }
    
}