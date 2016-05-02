//
//  ViewController.swift
//  yn
//
//  Created by Aurelien Prieur on 28/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

protocol MasterViewControllerDelegate {
    func disableMainNavigation()
    func enableMainNavigation()
}

class MasterViewController: UIViewController, MasterViewControllerDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    
    var askNavigationController: UINavigationController!
    var friendsNavigationController: UINavigationController!
    var questionsNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let friendsStoryboard = UIStoryboard(name: "Friends", bundle: nil)
        friendsNavigationController = friendsStoryboard.instantiateInitialViewController() as! UINavigationController
        var friendsFrame = friendsNavigationController.view.frame
        friendsFrame.origin.x = 0;
        friendsFrame.origin.y = -UIApplication.sharedApplication().statusBarFrame.height
        friendsNavigationController.view.frame = friendsFrame
        (friendsNavigationController.delegate as! SectionNavigationControllerDelegate).masterViewControllerDelegate = self
        
        
        let askStoryboard = UIStoryboard(name: "Ask", bundle: nil)
        askNavigationController = askStoryboard.instantiateInitialViewController() as! UINavigationController
        var askFrame = askNavigationController.view.frame
        askFrame.origin.x = view.frame.size.width
        askFrame.origin.y = -UIApplication.sharedApplication().statusBarFrame.height
        askNavigationController!.view.frame = askFrame
        (askNavigationController.delegate as! SectionNavigationControllerDelegate).masterViewControllerDelegate = self
        
        let questionsStoryboard = UIStoryboard(name: "Questions", bundle: nil)
        questionsNavigationController = questionsStoryboard.instantiateInitialViewController() as! UINavigationController
        var questionsFrame = questionsNavigationController.view.frame
        questionsFrame.origin.x = view.frame.size.width * 2
        questionsFrame.origin.y = -UIApplication.sharedApplication().statusBarFrame.height
        questionsNavigationController.view.frame = questionsFrame
        (questionsNavigationController.delegate as! SectionNavigationControllerDelegate).masterViewControllerDelegate = self
        
        scrollView.contentSize = CGSizeMake(view.frame.size.width * 3, view.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height)
        scrollView.setContentOffset(CGPointMake(askFrame.origin.x, askFrame.origin.y), animated: false)
    }

    override func viewDidAppear(animated: Bool) {
        addChildViewController(friendsNavigationController)
        scrollView.addSubview(friendsNavigationController.view)
        friendsNavigationController.didMoveToParentViewController(self)
        
        addChildViewController(askNavigationController)
        scrollView.addSubview(askNavigationController.view)
        askNavigationController.didMoveToParentViewController(self)
        
        addChildViewController(questionsNavigationController)
        scrollView.addSubview(questionsNavigationController.view)
        friendsNavigationController.didMoveToParentViewController(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - MasterViewControllerDelegate
    
    func disableMainNavigation() {
        scrollView.scrollEnabled = false
    }
    
    func enableMainNavigation() {
        scrollView.scrollEnabled = true
    }
    
}

