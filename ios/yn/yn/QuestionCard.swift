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

    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                print(response?.suggestedFilename ?? "")
                print("Download Finished")
                self.image!.image = UIImage(data: data)
            }
        }
    }
    
    func setCardImageFromUrl(imgUrl: String) {
        if let checkedUrl = NSURL(string: imgUrl) {
            self.image!.contentMode = .ScaleAspectFit
            downloadImage(checkedUrl)
        }
    }
    
    func setCardImageFromImage(img: UIImage) {
        self.image?.image = img;
    }
    
    func setCardTitle(tit: String) {
        self.title?.text = tit
    }

    func setCardQuestion(quest: String) {
        self.question?.text = quest
    }
}