//
//  WhoAnsweredWhatViewController.swift
//  yn
//
//  Created by Julie FRANEL on 5/19/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class WhoAnsweredWhatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var friends = [[User]]()
    var friendsSections = [String]()
    var chosenSection = String()
    var questionId = Int()
    
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
    
    private func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        fetchFriendsAnswers()
    }
    
    private func resetFriendsList() {
        var index = 0
        for _ in self.friendsSections {
            self.friends[index].removeAll()
            index += 1
        }
        friendsSections.removeAll()
        friends.removeAll()
    }
    
    private func addFriendsToSectionRowArrays(users: [User]) {
        for user in users {
            if (user.answer == self.chosenSection) {
                var index = 0
                if !friendsSections.contains(chosenSection) {
                    friendsSections.append(chosenSection)
                    friends.append([User]())
                    index = friendsSections.count - 1
                }
                else {
                    index = friendsSections.indexOf(chosenSection)!
                }
                friends[index].append(user)
                friends[index].sortInPlace({ $0.username < $1.username })
            }
        }
    }
    
    private func fetchFriendsAnswers() {
        do {
            try QuestionsApiController.sharedInstance.getAnswers(questionId) { (users: [User]?, err: ApiError?) in
                if (err == nil && users != nil) {
                    self.resetFriendsList()
                    self.addFriendsToSectionRowArrays(users!)
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if friendsSections.count > 0 {
            tableView.hidden = false
            noDataLabel.hidden = true
        } else {
            tableView.hidden = true
            noDataLabel.hidden = false
        }
        return friendsSections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answerListCell") as! WhoAnsweredWhatTableViewCell
        cell.cellLabel.text = friends[indexPath.section][indexPath.row].username
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("answerListHeaderCell") as! WhoAnsweredWhatTableViewHeaderCell
        headerCell.backgroundColor = UIColor.purpleYn()
        headerCell.headerLabel.textColor = UIColor.whiteColor()
        headerCell.headerLabel.font = UIFont(name: "Sansation", size: 20)
        headerCell.headerLabel.textAlignment = NSTextAlignment.Center
        headerCell.headerLabel.text = "Who answered " + self.chosenSection + "?";
        return headerCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

class WhoAnsweredWhatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
}

class WhoAnsweredWhatTableViewHeaderCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
}
