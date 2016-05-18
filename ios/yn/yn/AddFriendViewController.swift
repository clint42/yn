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
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    let apiHandler = ApiHandler.sharedInstance
    var searchRequest: Request?
    var searchText: String?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarTopConstraint.constant = self.navigationController!.navigationBar.frame.height
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        getFriendsFromPhone()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text = "No friends using YN\nin your contacts"
            noDataLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            noDataLabel.numberOfLines = 2
            noDataLabel.textColor = UIColor.lightGrayColor()
            noDataLabel.textAlignment = NSTextAlignment.Center
            noDataLabel.font = UIFont(name: "Sansation", size: 30)
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
        }
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
        if (searchText != "") {
            searchUsers(searchText!)
        } else {
            self.users.removeAll()
            self.getFriendsFromPhone()
        }
        
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
            self.getFriendsFromPhone()
        }
        let alert = UIAlertController(title: "Add request", message: "Your request has been sent to " + identifier, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: confirmClosure))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func getFriendsFromPhone() {
        let store = CNContactStore()
        store.requestAccessForEntityType(.Contacts) { granted, error in
            guard granted else {
                return
            }
            
            // Fetching fullname, phone numbers and email addresses from phone contacts
            var contacts = [CNContact]()
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey, CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName), CNContactPhoneNumbersKey, CNContactEmailAddressesKey])
            do {
                try store.enumerateContactsWithFetchRequest(request) { contact, stop in
                    contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            var numbersOrEmails = [String]();
            
            // Browsing contacts to store phone numbers and email addresses in an array 
            // which will be sent to the API to get users informations if they are using YN
            for contact in contacts {
                if (contact.isKeyAvailable(CNContactPhoneNumbersKey)) {
                    for phoneNumber:CNLabeledValue in contact.phoneNumbers {
                        let a = phoneNumber.value as! CNPhoneNumber
                        numbersOrEmails.append(a.valueForKey("digits") as! String)
                    }
                }
                if (contact.isKeyAvailable(CNContactEmailAddressesKey)) {
                    for emailAddress: CNLabeledValue in contact.emailAddresses {
                        numbersOrEmails.append(emailAddress.value as! String)
                    }
                }
            }
            do {
                try FriendsApiController.sharedInstance.findFriends(numbersOrEmails) { (friends: [User]?, err: ApiError?) in
                    if (err == nil && friends != nil) {
                        self.users.removeAll()
                        self.users = friends!
                        self.users.sortInPlace({ $0.username < $1.username })
                        self.tableView.reloadData()
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
