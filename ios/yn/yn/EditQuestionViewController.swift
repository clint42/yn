//
//  EditQuestionViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 12/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import Alamofire

class EditQuestionViewController: UIViewController, UITextViewDelegate, FriendsListViewControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var sendButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonBottomContraint: NSLayoutConstraint!
    
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
    
    var friendsPickerVC: FriendsListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame.size.height -= UIApplication.sharedApplication().statusBarFrame.height
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
            self.cancelButtonBottomContraint.constant = self.cancelButtonBottomContraint.constant + keyboardFrame.size.height
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
        self.cancelButtonBottomContraint.constant = 0
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
        
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.redColor().CGColor
        //self.sendButtonBottomConstraint.constant = UIApplication.sharedApplication().statusBarFrame.height
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
        let friendsStoryboard = UIStoryboard(name: "Friends", bundle: nil)
        friendsPickerVC = friendsStoryboard.instantiateViewControllerWithIdentifier("friendsListViewController") as? FriendsListViewController
        
        friendsPickerVC!.delegate = self
        friendsPickerVC!.presentationOption = FriendsListViewControllerPresentationOption.Picker
        friendsPickerVC!.view.frame.size.height -= UIApplication.sharedApplication().statusBarFrame.height
        //navigationController!.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.navigationController!.pushViewController(friendsPickerVC!, animated: true)
        
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        print("Cancel buttontapped")
        self.navigationController!.popViewControllerAnimated(true)

    }
    
    private func displayAlertError() {
        let alertView = UIAlertController(title: "An error occurred", message: "Your question has not been send", preferredStyle: UIAlertControllerStyle.Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    // MARK: - FriendsListViewControllerDelegate
    func friendsList(didSelectFriends friends: [User]?) {
        self.navigationController!.popViewControllerAnimated(true)
        do {
            let apiHandler = ApiHandler.sharedInstance
            if friends != nil {
                var friendsId = [Int]()
                for friend in friends! {
                    friendsId.append(friend.id)
                }
                let friendsData = try NSJSONSerialization.dataWithJSONObject(friendsId, options: NSJSONWritingOptions.PrettyPrinted)
                let friendsJsonString = NSString(data: friendsData, encoding: NSUTF8StringEncoding)!
                let params = ["title": titleTextField.text!, "question": questionTextView.text!, "friends": String(friendsJsonString)]
                if imageData != nil {
                    let image = ["image": imageData!]
                    try apiHandler.uploadMultiPartJpegImage(.POST, URLString: ApiUrls.getUrl("askQuestion"), parameters: params, images: image) { (request, error) in
                        if error == nil {
                            request?.responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                                if response.result.isSuccess {
                                    if let result = response.result.value as? Dictionary<String, AnyObject> {
                                        if result["success"] as? Bool == true {
                                            self.navigationController?.popToRootViewControllerAnimated(true)
                                            return
                                        }
                                    }
                                }
                                print("Wrong data received, assuming question is not sent")
                                self.displayAlertError()
                            })
                        }
                        else {
                            print("Error response: \(error)")
                            self.displayAlertError()
                        }
                    }
                }
                else {
                    try apiHandler.request(.POST, URLString: ApiUrls.getUrl("askQuestion"), parameters: params, completion: { (result, err) in
                        if err == nil {
                            if result!["success"] as? Bool == true {
                                self.navigationController?.popToRootViewControllerAnimated(true)
                                return
                            }
                            else {
                                print("An error occurred")
                            }
                        }
                        else {
                            print("error: \(err)")
                        }
                    })
                }
            }
        } catch let error as ApiError {
            //TODO: Error Handling
            print("Error exceptions: \(error)")
            displayAlertError()
        } catch {
            print("An unexpected error occured")
            displayAlertError()
        }
        //friendsPickerVC?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func cancel() {
        self.navigationController!.popViewControllerAnimated(true)
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
