//
//  FriendsListViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class FriendsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!

    let apiHandler = ApiHandler.sharedInstance
    
    var paginationOffset: Int = 0
    var friendsSections = [String]()
    var friends = [[User]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    private func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        fetchFriends()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if friendsSections.count > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text = "No friends"
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
            alertController = UIAlertController(title: friends[indexPath.section][indexPath.row].username, message: "\(friends[indexPath.section][indexPath.row].firstname) \(friends[indexPath.section][indexPath.row].lastname)", preferredStyle: .Alert)
        } else {
            alertController = UIAlertController(title: friends[indexPath.section][indexPath.row].username, message: "", preferredStyle: .Alert)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default) { (action:UIAlertAction!) in
            self.deleteFriend(self.friends[indexPath.section][indexPath.row].username, indexPath: indexPath)
        }
        alertController.addAction(deleteAction)
        
        let BlockAction = UIAlertAction(title: "Block", style: .Default) { (action:UIAlertAction!) in
            self.deleteFriend(self.friends[indexPath.section][indexPath.row].username, indexPath: indexPath)
        }
        alertController.addAction(BlockAction)

        let CancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action:UIAlertAction!) in
        }
        alertController.addAction(CancelAction)


        presentViewController(alertController, animated: true, completion: nil)
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell") as! FriendTableViewCell
        cell.usernameLabel.text = friends[indexPath.section][indexPath.row].username
        return cell
    }

    //MARK: - Data processing methods
    private func resetFriendsList() {
        var index = 0
        for _ in self.friendsSections {
            self.friends[index].removeAll()
            index += 1
        }
        friendsSections.removeAll()
        friends.removeAll()
    }
    
    private func fetchFriends() {
        resetFriendsList()
        do {
            try FriendsApiController.sharedInstance.getFriends(nResults: 20, offset: 0, orderBy: "username", orderRule: "ASC", completion: { (users: [User]?, err: ApiError?) in
                if (err == nil && users != nil) {
                    self.addFriendsToSectionRowArrays(users!)
                    self.tableView.reloadData()
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
    
    private func deleteFriend(friendUsername: String, indexPath: NSIndexPath) {
        do {
            try FriendsApiController.sharedInstance.deleteFriend(friendUsername, completion: { (res: Bool?, err: ApiError?) in
                if (err == nil && res == true) {
                    self.friends[indexPath.section].removeAtIndex(indexPath.row)
                    self.tableView.reloadData()
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
                friends[index].sortInPlace({ $0.username < $1.username })
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

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
}
