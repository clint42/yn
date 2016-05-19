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
    var questionsSections = [String]()
    var questions = [[Question]]()
    var tappedQuestionId = 0
    
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
            try QuestionsApiController.sharedInstance.getAllQuestions(nResults: 20, offset: 0, orderBy: "UserId", orderRule: "ASC", completion: { (result: [String:AnyObject]?, err: ApiError?) in
                if (err == nil && result != nil && result!["questions"] != nil && result!["userid"] != nil) {
                    self.addQuestionsToSectionRowArrays(result!["questions"]! as! [Question], userid: result!["userid"]! as! Int)
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
    
    private func resetQuestionList() {
        var index = 0
        for _ in self.questionsSections {
            self.questions[index].removeAll()
            index += 1
        }
        questionsSections.removeAll()
        questions.removeAll()
    }
    
    private func addQuestionsToSectionRowArrays(_questions: [Question], userid: Int) {
        resetQuestionList()
        for _question in _questions {
            if (_question.ownerId != 0) {
                var section = ""
                if (_question.ownerId == userid) {
                    section = String("owner")
                    if (!questionsSections.contains(section)) {
                        questionsSections.append(section)
                        questions.append([Question]())
                    }
                } else {
                    section = String("others")
                    if (!questionsSections.contains(section)) {
                        questionsSections.append(section)
                        questions.append([Question]())
                    }
                }
                let index = questionsSections.indexOf(section)!
                questions[index].append(_question)
            }
        }
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if questionsSections.count > 0 {
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
        return questionsSections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("answersQuestionsListCell") as! AnswersQuestionsListTableViewCell
        cell.questionLabel.text = questions[indexPath.section][indexPath.row].title
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("answersQuestionsListHeaderCell") as! AnswersQuestionsListTableViewHeaderCell
        headerCell.backgroundColor = UIColor.purpleYn()
        headerCell.headerLabel.textColor = UIColor.whiteColor()
        headerCell.headerLabel.font = UIFont(name: "Sansation", size: 20)
        headerCell.headerLabel.textAlignment = NSTextAlignment.Center
        if (section == questionsSections.indexOf("owner")) {
            headerCell.headerLabel.text = "Your questions";
        } else {
            headerCell.headerLabel.text = "Participated in";
        }
        return headerCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showAnswer") {
            let destination = segue.destinationViewController as? AnswerDetailsViewController
            let section = (tableView.indexPathForSelectedRow?.section)!
            let row = (tableView.indexPathForSelectedRow?.row)!
            destination!.questionId = questions[section][row].id
        }
    }
}

class AnswersQuestionsListTableViewCell: UITableViewCell {
    @IBOutlet weak var questionLabel: UILabel!
}

class AnswersQuestionsListTableViewHeaderCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
}
