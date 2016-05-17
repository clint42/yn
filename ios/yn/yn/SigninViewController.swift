//
//  SigninViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SigninViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var signinFormViewContainer: UIView!
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signinWithFacebookButton: FBSDKLoginButton!

    @IBOutlet weak var verticalSpaceTopLogo: NSLayoutConstraint!
    @IBOutlet weak var verticalSpaceLogoSigninView: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingSigninViewSignupBtn: NSLayoutConstraint!
    @IBOutlet weak var verticalSpacingSignupBtnBottom: NSLayoutConstraint!
    
    //TODO: REMOVE, DEV ONLY
    private func tmpAutoLog() {
        identifierTextField.text = "test0@test.com"
        passwordTextField.text = "test"
        signin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if Facebook already logged in
        if let token = FBSDKAccessToken.currentAccessToken() {
            if token.hasGranted("email") {
                signinWithFacebook(token)
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        identifierTextField.delegate = self
        passwordTextField.delegate = self
        configureLoginWithFacebook()
        applyStyle()
        addTapGestureRecognizer()
        
        //TODO: Remove, DEV ONLY
        //tmpAutoLog()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        scrollViewSetSize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func scrollViewSetSize() {
        let height = verticalSpaceTopLogo.constant + logo.frame.height + verticalSpaceLogoSigninView.constant + signinFormViewContainer.frame.height + verticalSpacingSigninViewSignupBtn.constant + signupButton.frame.height + verticalSpacingSignupBtnBottom.constant
        scrollView.contentSize = CGSizeMake(view.frame.width, height)
    }
    
    private func applyStyle() {
        //Signin form style
        identifierTextField.borderStyle = UITextBorderStyle.None
        passwordTextField.borderStyle = UITextBorderStyle.None
        signinFormViewContainer.layer.cornerRadius = 8
        signinFormViewContainer.layer.masksToBounds = true
        signinFormViewContainer.layer.borderWidth = 1
        signinFormViewContainer.layer.borderColor = UIColor.purpleYn().CGColor
        
        signinWithFacebookButton.layer.cornerRadius = 8
        
        signupButton.layer.cornerRadius = 8
        signupButton.layer.borderWidth = 1
        signupButton.layer.borderColor = UIColor.purpleYn().CGColor
    }
    
    func configureLoginWithFacebook() {
        signinWithFacebookButton.delegate = self
        signinWithFacebookButton.readPermissions = ["public_profile", "email", "user_friends"]
        signinWithFacebookButton.loginBehavior = FBSDKLoginBehavior.Native
        signinWithFacebookButton.layer.cornerRadius = 8
    }
    
    //MARK: - User interaction handling methods
    private func addTapGestureRecognizer() {
        let gesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        view.addGestureRecognizer(gesturerecognizer)
    }
    
    @objc private func viewTapped(sender: UITapGestureRecognizer) {
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

    //MARK: - Signin
    private func validateForm() -> Bool {
        if identifierTextField.text == nil || identifierTextField.text!.isEmpty {
            let alertController = UIAlertController(title: "Email or phone field required", message: "Please enter your email adress or phone number", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.identifierTextField.becomeFirstResponder()
            }))
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        else if passwordTextField.text == nil || passwordTextField.text!.isEmpty {
            let alertController = UIAlertController(title: "Password field required", message: "Please enter your password", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                self.passwordTextField.becomeFirstResponder()
            }))
            presentViewController(alertController, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
    
    private func signinWithFacebook(accessToken: FBSDKAccessToken) {
        let apiHandler = ApiHandler.sharedInstance
        apiHandler.authenticateWithFacebook(accessToken: accessToken, completion: { (success: Bool, error: ApiError?) in
            if success {
                self.signinSuccess()
            }
            else if  let error = error {
                switch error {
                case .FBUserNotFound:
                    //TODO: Redirect to signup view with fields populated with facebook information
                    print("FB User not found")
                    let alertView = UIAlertController(title: "Not registered", message: "You have never created a YN account", preferredStyle: UIAlertControllerStyle.Alert)
                    alertView.addAction(UIAlertAction(title: "Signup with Facebook", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) in
                        self.performSegueWithIdentifier("signupFbSegue", sender: self)
                    }));
                    self.presentViewController(alertView, animated: true, completion: nil)
                    break
                default:
                    //TODO: Error handling!
                    
                    break
                }
            }
        })
    }
    
    private func signin() {
        if validateForm() {
            let apiHandler = ApiHandler.sharedInstance
            apiHandler.authenticate(identifier: identifierTextField.text!, password: passwordTextField.text!, completion: { (success: Bool) in
                if success {
                    self.signinSuccess()
                }
                else {
                    let alertController = UIAlertController(title: "Authentication failed", message: "Something went wrong, perhaps your credentials are invalid. We are still in beta so we do not have more detail about this error yet", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentViewController(alertController, animated: true, completion: nil)
                    })
                }
            })
        }
        
    }
    
    private func signinSuccess() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateInitialViewController()
        dispatch_async(dispatch_get_main_queue(), {
            self.presentViewController(vc!, animated: true, completion: nil)
        })
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == identifierTextField {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            signin()
        }
        return true
    }
    
    // MARK: - FBSDKLoginButtonDelegate
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("LoginButton didCompleteWithResult")
        if error == nil {
            signinWithFacebook(result.token)
        }
        else {
            print("FBLogin error:  \(error)")
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("loginButton didLogOut");
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        print("loginButton will login");
        return true
    }
    
    // MARK: - @IBActions
    @IBAction func signinButtonTapped(sender: UIButton) {
        signin()
    }
    
    @IBAction func signupButtonTapped(sender: UIButton) {
        performSegueWithIdentifier("signupSegue", sender: self)
    }
    
    @IBAction func signinWithFacebookButton(sender: UIButton) {
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "signupFbSegue" {
            let vc = segue.destinationViewController as! SignupViewController
            vc.bypassToFbSignup = true
            
        }
    }
}
