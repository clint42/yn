//
//  AskViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 28/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class CreateQuestionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func testButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("testSegue", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    

}
