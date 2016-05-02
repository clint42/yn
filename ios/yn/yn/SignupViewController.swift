//
//  SignupViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signupFormContainer: UIView!
    @IBOutlet weak var identifierTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var signinBtn: UIButton!
    @IBOutlet weak var signupWithFacebookBtn: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        identifierTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        addTapGestureRecognizer()
        applyStyle()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSizeMake(view.frame.width, contentView.frame.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func applyStyle() {
        identifierTextField.borderStyle = UITextBorderStyle.None
        passwordTextField.borderStyle = UITextBorderStyle.None
        confirmPasswordTextField.borderStyle = UITextBorderStyle.None
        firstnameTextField.borderStyle = UITextBorderStyle.None
        lastnameTextField.borderStyle = UITextBorderStyle.None
        
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
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case identifierTextField:
            passwordTextField.becomeFirstResponder()
            break
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
            //TODO: Call signup method
            break
        default:
            print("An Error occured")
        }
        return true
    }
    
    //MARK: - @IBAction
    @IBAction func signinButtonTapped(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func signupButtonTapped(sender: UIButton) {
        //TODO: Call signup method
    }
    
    @IBAction func signupWithFacebookTapped(sender: UIButton) {
    }
    
}