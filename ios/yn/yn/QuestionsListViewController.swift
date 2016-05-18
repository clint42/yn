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
    @IBOutlet weak var kolodaView: KolodaView!
    
    private var dataSource: Array<UIImage> = {
        var array: Array<UIImage> = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        return array
    }()
    var questions = [Question]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }
    
    private func loadData() {
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        fetchQuestions()
    }
    
    private func fetchQuestions() {
        do {
            try QuestionsApiController.sharedInstance.getQuestionsAsked(nResults: 20, offset: 0, orderBy: "updatedAt", orderRule: "ASC", completion: { (questions: [Question]?, err: ApiError?) in
                if (err == nil && questions != nil) {
                    numberOfCards = UInt(questions!.count)
                    self.questions = questions!
                    self.dataSource = {
                        var array: Array<UIImage> = []
                        for index in 0..<numberOfCards {
                            array.append(UIImage(named: "Card_like_\(index + 1)")!)
                        }
                        return array
                    }()
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
        print(index)
        if (direction == SwipeResultDirection.Left) {
//            print("left")
        }
        else if (direction == SwipeResultDirection.Right) {
//            print("right")
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
//        print(kolodaView.currentCardIndex - 1)
//        dataSource.insert(UIImage(named: "Card_like_6")!, atIndex: kolodaView.currentCardIndex - 1)
//        let position = kolodaView.currentCardIndex
//        kolodaView.insertCardAtIndexRange(position...position, animated: true)
        
        let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, questionView.bounds.size.width, questionView.bounds.size.height))
        noDataLabel.text = "No questions"
        noDataLabel.textColor = UIColor.lightGrayColor()
        noDataLabel.textAlignment = NSTextAlignment.Center
        noDataLabel.font = UIFont(name: "Sansation", size: 30)
        questionView.addSubview(noDataLabel)
    }
}

//MARK: KolodaViewDataSource
extension QuestionsListViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda:KolodaView) -> UInt {
        return UInt(questions.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let card: QuestionCard = QuestionCard.instanceFromNib() as! QuestionCard
        if (index < UInt(questions.count)) {
            card.setCardTitle(self.questions[Int(index)].title)
            card.setCardQuestion(self.questions[Int(index)].description!)
//            card.setCardImageFromUrl(self.questions[Int(index)].imageUrl!)
            card.setCardImageFromImage(self.dataSource[Int(index)])
        }
        return card
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }


}
