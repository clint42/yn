//
//  QuestionsListViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: UInt = 0

class QuestionsListViewController: UIViewController {

    @IBOutlet var questionView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var kolodaView: KolodaView!
    
    private let questionsApiController = QuestionsApiController.sharedInstance
    
    private var dataSource: Array<UIImage> = {
        var array: Array<UIImage> = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        return array
    }()
    var questions = [Question]()
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadNewQuestion), name: InternalNotificationForRemote.newQuestion.rawValue, object: nil)
        super.viewDidLoad()
        self.buttonView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }
    
    //MARK: - Notification handlers
    @objc private func loadNewQuestion(notification: NSNotification) {
        do {
            let questionId = notification.userInfo!["questionId"] as! Int
            try questionsApiController.getQuestion(questionId, completion: { (question, err) in
                if err == nil {
                    self.questions.insert(question!, atIndex: 0)
                    self.kolodaView.resetCurrentCardIndex()
                }
                else {
                    //TODO: Error handling
                    print("An error occurred: \(err)")
                }
            })
        } catch let error as ApiError {
            print("An error occured: \(error)")
        } catch {
            print("An unexpected error occurred")
        }
    }
    
    private func loadData() {
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        fetchQuestions()
    }
    
    private func fetchQuestions() {
        do {
            try questionsApiController.getQuestionsAsked(nResults: 20, offset: 0, orderBy: "createdAt", orderRule: "DESC", completion: { (questions: [Question]?, err: ApiError?) in
                if (err == nil && questions != nil) {
                    numberOfCards = UInt(questions!.count)
                    self.questions = questions!
                    if (numberOfCards > 0) {
                        self.buttonView.hidden = false
                    }
                    self.kolodaView.reloadData()
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

    @IBAction func leftButtonTapped(sender: AnyObject) {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped(sender: AnyObject) {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func koloda(koloda: KolodaView, didSwipeCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        var answer: Bool = false
        if (direction == SwipeResultDirection.Left) {
            answer = false
        }
        else if (direction == SwipeResultDirection.Right) {
            answer = true
        }
        do {
            try QuestionsApiController.sharedInstance.answerToQuestion(questions[Int(index)].id, answer: answer, completion: { (success: Bool?, err: ApiError?) in
                if (err == nil && success == true) {
                    print(success)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.questions.removeAtIndex(Int(index))
                        self.kolodaView.resetCurrentCardIndex()
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: KolodaViewDelegate
extension QuestionsListViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        self.buttonView.hidden = true
    }
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return false
    }
}

//MARK: KolodaViewDataSource
extension QuestionsListViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda:KolodaView) -> UInt {
        return UInt(questions.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let card: QuestionCard = QuestionCard.instanceFromNib() as! QuestionCard
        let question = self.questions[Int(index)]
        if (index < UInt(questions.count)) {
            card.setCardTitle(question.title)
            if question.description != nil {
                card.setCardQuestion(question.description!)
            }
            else {
                card.setCardQuestion("")
            }
            do {
                if question.imageUrl != nil {
                    try card.setCardImageFromUrl(ApiUrls.getUrl("images") + "/" + question.imageUrl!)
                }
                else {
                    card.setCardImageFromImage(UIImage(named: "yn_logo")!)
                }
                
            } catch let error as ApiError {
                print("An error occurred: \(error)")
            } catch {
                print("An unexpected error occurred")
            }
        }
        return card
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }


}
