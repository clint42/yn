//
//  EditQuestionViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 12/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class EditQuestionViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionTextView: UITextView!
    
    var imageData: NSData? {
        willSet {
            if imageView != nil && newValue != nil {
                imageView.image = UIImage(data: newValue!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)
        if imageData != nil {
            imageView.image = UIImage(data: imageData!)
        }
    }

    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSizeMake(view.frame.width, 1200)
    }
    
    // MARK: - Keyboard scrollview handlers
    @objc private func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        print("KeyboardContentInsetBottom: \(keyboardFrame.size.height)")
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInset
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - @IBActions
    @IBAction func sendButtonTapped(sender: UIButton) {
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
