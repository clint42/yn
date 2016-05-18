//
//  AnswersQuestionsListViewController.swift
//  yn
//
//  Created by Julie FRANEL on 5/17/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class AnswersQuestionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    private func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        fetchQuestions()
    }
    
    private func fetchQuestions() {
        do {
            try FriendsApiController.sharedInstance.getFriends(nResults: 10, offset: 0, orderBy: "username", orderRule: "ASC", completion: { (users: [User]?, err: ApiError?) in
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
                print("on passe par laaaaa")
                print(friends[index].last!.username)
                friends[index].sortInPlace({ $0.username < $1.username })
            }
        }
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
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answersQuestionsListCell") as! AnswersQuestionsListTableViewCell
        cell.questionLabel.text = friends[indexPath.section][indexPath.row].username
        return cell
    }


}

class AnswersQuestionsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
}
