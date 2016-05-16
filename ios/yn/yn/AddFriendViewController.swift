//
//  AddFriendViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 05/05/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import Alamofire
import Contacts

protocol ResultCellProtocol: class {
    func addFriendButtonDidTapped(identifier: String)
    func searchUsers(identifier: String)
}

class AddFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ResultCellProtocol {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let apiHandler = ApiHandler.sharedInstance
    var searchRequest: Request?
    var searchText: String?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        getFriendsFromPhone()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell")! as! ResultCell
        cell.applyStyle()
        cell.usernameLabel.text = users[indexPath.row].username
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange _searchText: String) {
        //TODO: Cancel search request if any
        searchRequest?.cancel()
        searchText = _searchText
        
        //TODO: Perform new search request
        searchUsers(searchText!)
        
    }
    
    
    // MARK: - Data processing methods
    func searchUsers(identifier: String) {
        do {
            searchRequest = try UsersApiController.sharedInstance.searchByIdentifier(identifier) { (users: [User]?, err: ApiError?) in
                if (err == nil && users != nil) {
                    self.users = users!
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
                else {
                    print("err: \(err)")
                }
            }
        } catch let error as ApiError {
            print("error: \(error)")
        } catch {
            print("Unexpected error")
        }
    }
    
    func addFriendButtonDidTapped(identifier: String) {
        let confirmClosure: ((UIAlertAction!) -> Void)! = { action in
            self.searchBar.text = ""
            self.users.removeAll()
            self.tableView.reloadData()
        }
        let alert = UIAlertController(title: "Add request", message: "Your request has been sent to " + identifier, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: confirmClosure))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getFriendsFromPhone() {
        let store = CNContactStore()
        store.requestAccessForEntityType(.Contacts) { granted, error in
            guard granted else {
                print("erroooooooor")
                return
            }
            
            // get the contacts
            
            var contacts = [CNContact]()
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey, CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey])
            do {
                try store.enumerateContactsWithFetchRequest(request) { contact, stop in
                    contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            // do something with the contacts array (e.g. print the names)
            
            let formatter = CNContactFormatter()
            formatter.style = .FullName
            for contact in contacts {
                if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                    for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                        let a = phoneNumber.value as! CNPhoneNumber
                        print("\(formatter.stringFromContact(contact)) : +\(a.valueForKey("countryCode") as! String) \(a.valueForKey("digits") as! String)")
                    }
                }
                //print(formatter.stringFromContact(contact))
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

class ResultCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    var delegate: ResultCellProtocol?
    
    func applyStyle() {
        addFriendButton.layer.cornerRadius = 4
        addFriendButton.layer.borderColor = UIColor.whiteColor().CGColor
        addFriendButton.layer.borderWidth = 1
    }
    
    @IBAction func addFriendButtonTapped(sender: UIButton) {
        do {
            try FriendsApiController.sharedInstance.addFriend(usernameLabel.text!) { (success: Bool?, err: ApiError?) in
                if (err == nil && success == true) {
                    self.delegate?.addFriendButtonDidTapped(self.usernameLabel.text!)
                }
                else {
                    print("err: \(err)")
                }
            }
            
        } catch let error as ApiError {
            print("error: \(error)")
        } catch {
            print("Unexpected error")
        }
    }
}
