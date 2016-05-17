//
//  QuestionsListViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: UInt = 5

class QuestionsListViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
    
    private var dataSource: Array<UIImage> = {
        var array: Array<UIImage> = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        kolodaView.dataSource = self
        kolodaView.delegate = self

        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal

        // Do any additional setup after loading the view.
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
        if (direction == SwipeResultDirection.Left) {
            print("left")
        }
        else if (direction == SwipeResultDirection.Right) {
            print("right")
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
        dataSource.insert(UIImage(named: "Card_like_6")!, atIndex: kolodaView.currentCardIndex - 1)
        let position = kolodaView.currentCardIndex
        kolodaView.insertCardAtIndexRange(position...position, animated: true)
    }
}

//MARK: KolodaViewDataSource
extension QuestionsListViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(koloda:KolodaView) -> UInt {
        return UInt(dataSource.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        let card: QuestionCard = QuestionCard.instanceFromNib() as! QuestionCard
        
//        card.setCardTitle("tutu")
//        card.setCardQuestion("tutu")
        card.setCardImage(dataSource[Int(index)])
        return card
//        return UIImageView(image: dataSource[Int(index)])
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView",
                                                  owner: self, options: nil)[0] as? OverlayView
    }


}
