//
//  FriendsRequestsViewController.swift
//  yn
//
//  Created by Julie FRANEL on 5/16/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class FriendsRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    let apiHandler = ApiHandler.sharedInstance
    
    var paginationOffset: Int = 0
    var friendsSections = [String]()
    var friends = [[User]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.fetchPendingRequests), name: InternalNotificationForRemote.friendRequest.rawValue, object: nil)
        // Do any additional setup after loading the view.
    }
    
    func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        fetchPendingRequests()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if friendsSections.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text = "No pending request"
            noDataLabel.textColor = UIColor.lightGrayColor()
            noDataLabel.textAlignment = NSTextAlignment.Center
            noDataLabel.font = UIFont(name: "Sansation", size: 30)
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .None
        }
        return friendsSections.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alertController: UIAlertController
        if (!(friends[indexPath.section][indexPath.row].firstname ?? "").isEmpty && !(friends[indexPath.section][indexPath.row].lastname ?? "").isEmpty) {
            alertController = UIAlertController(title: friends[indexPath.section][indexPath.row].username, message: "\(friends[indexPath.section][indexPath.row].firstname!) \(friends[indexPath.section][indexPath.row].lastname!)", preferredStyle: .Alert)
        } else {
            alertController = UIAlertController(title: friends[indexPath.section][indexPath.row].username, message: "", preferredStyle: .Alert)
        }
        
        let acceptAction = UIAlertAction(title: "Accept", style: .Default) { (action:UIAlertAction!) in
            self.acceptRequest(self.friends[indexPath.section][indexPath.row].username, accept: true, indexPath: indexPath)
        }
        alertController.addAction(acceptAction)
        
        let denyAction = UIAlertAction(title: "Deny", style: .Default) { (action:UIAlertAction!) in
            self.acceptRequest(self.friends[indexPath.section][indexPath.row].username, accept: false, indexPath: indexPath)
        }
        alertController.addAction(denyAction)
        
        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(CancelAction)
        
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendsRequestsCell") as! FriendsRequestsTableViewCell
        cell.usernameLabel.text = friends[indexPath.section][indexPath.row].username
        return cell
    }
    
    //MARK: - Data processing methods
    private func countRequestsNumber() -> Int {
        var count = 0;
        for friend in friends {
            count += friend.count
        }
        return count
    }
    
    private func setTabBarBadgeValue() {
        let count = countRequestsNumber()
        if count > 0 {
            tabBarController!.tabBar.items![1].badgeValue = String(count)
        } else {
            tabBarController!.tabBar.items![1].badgeValue = nil
        }
    }
    // UPDATE `Friends` SET `status` = 'PENDING' WHERE `UserId` = 13
    
    private func resetRequestsList() {
        var index = 0
        for _ in self.friendsSections {
            self.friends[index].removeAll()
            index += 1
        }
        friendsSections.removeAll()
        friends.removeAll()
    }
    
    @objc private func fetchPendingRequests() {
        resetRequestsList()
        do {
            try FriendsApiController.sharedInstance.getFriendsRequests(nResults: 20, offset: 0, orderBy: "username", orderRule: "ASC", completion: { (users: [User]?, err: ApiError?) in
                if (err == nil && users != nil) {
                    self.addFriendsToSectionRowArrays(users!)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                        self.setTabBarBadgeValue()
                    }
                }
                else {
                    print("error: \(err)")
                }
            })
        } catch let error as ApiError {
            print("error: \(error)")
        } catch {
            print("Unexpected error")
        }
    }
    
    private func acceptRequest(friendUsername: String, accept: Bool, indexPath: NSIndexPath) {
        do {
            try FriendsApiController.sharedInstance.answerRequest(friendUsername, answer: accept, completion: { (res: Bool?, err: ApiError?) in
                if (err == nil && res == true) {
                    self.friends[indexPath.section].removeAtIndex(indexPath.row)
                    self.fetchPendingRequests()
                }
                else {
                    print("error: \(err)")
                }
            })
        } catch let error as ApiError {
            print("error: \(error)")
        } catch {
            print("Unexpected error")
        }
    }
    
    private func addFriendsToSectionRowArrays(users: [User]) {
        for user in users {
            if (!user.username.isEmpty) {
                let firstChar = user.username[user.username.startIndex]
                var index = 0
                if !friendsSections.contains(String(firstChar)) {
                    friendsSections.append(String(firstChar))
                    friends.append([User]())
                    index = friendsSections.count - 1
                }
                else {
                    index = friendsSections.indexOf(String(firstChar))!
                }
                friends[index].append(user)
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

class FriendsRequestsTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
}
