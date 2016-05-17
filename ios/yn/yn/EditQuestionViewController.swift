//
//  EditQuestionViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 12/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import Alamofire

class EditQuestionViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    
    var originContentInset: UIEdgeInsets!
    
    var questionTextViewIsEdited = false
    var keyboardIsVisible = false
    
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
        
        questionTextView.delegate = self
        
        applyStyle()
        
        addTapGestureRecognizer()
    }

    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSizeMake(view.frame.width, contentView.frame.size.height)
        originContentInset = scrollView.contentInset
    }
    
    // MARK: - Keyboard scrollview handlers
    @objc private func keyboardWillShow(notification: NSNotification) {
        if !keyboardIsVisible {
            keyboardIsVisible = true
            var userInfo = notification.userInfo!
            var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
            keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
            
            self.sendButtonBottomConstraint.constant = self.sendButtonBottomConstraint.constant + keyboardFrame.size.height
            UIView.animateWithDuration(1) {
                self.view.layoutIfNeeded()
            }
            
            
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height
            scrollView.contentInset = contentInset
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        keyboardIsVisible = false
        scrollView.contentInset = originContentInset
        
        self.sendButtonBottomConstraint.constant = 0
        UIView.animateWithDuration(1) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func viewTapped() {
        view.endEditing(true)
    }
    
    private func applyStyle() {
        setQuestionTextViewPlaceholder()
        
        titleTextField.borderStyle = UITextBorderStyle.None
        
        sendButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
    }
    
    private func setQuestionTextViewPlaceholder() {
        questionTextView.text = "Ask something..."
        questionTextView.textColor = UIColor.lightGrayColor()
        questionTextViewIsEdited = false
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidBeginEditing(textView: UITextView) {
        if !questionTextViewIsEdited && textView == questionTextView {
            questionTextViewIsEdited = true
            questionTextView.textColor = UIColor.blackColor()
            questionTextView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView == questionTextView && textView.text.isEmpty {
            setQuestionTextViewPlaceholder()
        }
    }
    
    
    // MARK: - @IBActions
    @IBAction func sendButtonTapped(sender: UIButton) {
        if imageData != nil {
            print("imageData is not nil")
            let apiHandler = ApiHandler.sharedInstance
            do {
                try apiHandler.uploadMultiPartJpegImage(.POST, URLString: ApiUrls.getUrl("askQuestion"), parameters: nil, images: ["image": imageData!]) { (request, error) in
                    if error != nil {
                        request?.responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                            if response.result.isSuccess {
                                print("Response result success")
                                print(response.result.value)
                            }
                            else {
                                print("Response isSuccess is false")
                            }
                        })
                    }
                    else {
                        print("Error response: \(error)")
                    }
                }
            } catch let error as ApiError {
                //TODO: Error Handling
                print("Error exceptions: \(error)")
            } catch {
                print("An unexpected error occured")
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
