//
//  QuestionCard.swift
//  yn
//
//  Created by Grégoire Lafitte on 5/16/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class QuestionCard: UIView {

    @IBOutlet weak var image: UIImageView?
    @IBOutlet weak var title: UILabel?
    @IBOutlet weak var question: UILabel?

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CardView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    func setCardImage(img: UIImage) {
        self.image?.image = img;
    }
    
    func setCardTitle(tit: String) {
        self.title?.text = tit
    }

    func setCardQuestion(quest: String) {
        self.question?.text = quest
    }
}