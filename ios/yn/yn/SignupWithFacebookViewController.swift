//
//  SignupWithFacebookViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 17/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit

class SignupWithFacebookViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var createYnAccountButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var formView: UIView!
    
    var email: String?
    var firstname: String?
    var lastname: String?
    var fbId: String?
    var accessToken: FBSDKAccessToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        
        emailTextField.delegate = self
        emailTextField.userInteractionEnabled = false
        
        phoneTextField.delegate = self
        usernameTextField.delegate = self
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        
        addTapGestureRecognizer()
        applyStyle()
        
        bindData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func bindData() {
        emailTextField.text = email
        firstnameTextField.text = firstname
        lastnameTextField.text = lastname
    }
    
    private func applyStyle() {
        emailTextField.borderStyle = UITextBorderStyle.None
        phoneTextField.borderStyle = UITextBorderStyle.None
        usernameTextField.borderStyle = UITextBorderStyle.None
        firstnameTextField.borderStyle = UITextBorderStyle.None
        lastnameTextField.borderStyle = UITextBorderStyle.None
        
        createYnAccountButton.layer.cornerRadius = 8
        
        signinButton.layer.cornerRadius = 8
        signinButton.layer.borderColor = UIColor.purpleYn().CGColor
        signinButton.layer.borderWidth = 1
        
        formView.layer.cornerRadius = 8
        formView.clipsToBounds = true
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

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            phoneTextField.becomeFirstResponder()
            break
        case phoneTextField:
            usernameTextField.becomeFirstResponder()
            break
        case usernameTextField:
            firstnameTextField.becomeFirstResponder()
            break
        case firstnameTextField:
            lastnameTextField.becomeFirstResponder()
            break
        case lastnameTextField:
            //TODO: call signup method
            break
        default:
            break
        }
        return true
    }
    
    // MARK: - @IBActions
    @objc private func viewTapped(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func createYnAccountButtonTapped(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func signupButtonTapped(sender: UIButton) {
        if accessToken != nil && emailTextField.text != nil && usernameTextField.text != nil {
            let apiHandler = ApiHandler.sharedInstance
            var params = [
                "token": accessToken!.tokenString,
                "email": email!,
                "username": usernameTextField.text!,
                "fbId": fbId
            ]
            if let firstname = firstnameTextField.text {
                params["firstname"] = firstname
            }
            if let lastname = lastnameTextField.text {
                params["lastname"] = lastname
            }
            if let phone = phoneTextField.text {
                params["phone"] = phone
            }
            do {
                try apiHandler.requestAnonymous(.POST, URLString: ApiUrls.getUrl("fbSignup"), parameters: params) { (result: Dictionary<String, AnyObject>?, err: ApiError?) in
                    if err == nil {
                        apiHandler.authenticateWithFacebook(accessToken: self.accessToken!, completion: { (success: Bool, error: ApiError?) in
                            if success {
                                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc = mainStoryboard.instantiateInitialViewController()
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.presentViewController(vc!, animated: true, completion: nil)
                                })
                            }
                            else {
                                print("Auth FB error occured: \(error)")
                            }
                        })
                    }
                    else {
                        print("err: \(err)")
                    }
                }
            } catch let error as ApiError {
                //TODO: Error handling
                print("error: \(error)")
            } catch {
                print("An unexpected error occured")
            }
        }
        
        
    }
    
    @IBAction func signinButtonTapped(sender: UIButton) {
        print("Sigin button tapped")
        let vcs = navigationController?.viewControllers
        for vc in vcs! {
            if vc is SigninViewController {
                navigationController?.popToViewController(vc, animated: true)
                return
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
