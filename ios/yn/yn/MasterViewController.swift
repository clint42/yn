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

class MasterViewController: UIViewController, MasterViewControllerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var answersButton: UIView!
    
    private var previousPage = 1
    
    var askNavigationController: UINavigationController!
    var friendsNavigationController: UINavigationController!
    var questionsNavigationController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        let friendsStoryboard = UIStoryboard(name: "Friends", bundle: nil)
        friendsNavigationController = friendsStoryboard.instantiateInitialViewController() as! UINavigationController
        var friendsFrame = friendsNavigationController.view.frame
        friendsFrame.origin.x = 0
        friendsFrame.origin.y = 0
        friendsFrame.size.height = view.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height
        friendsNavigationController.view.frame = friendsFrame
        (friendsNavigationController.delegate as! SectionNavigationControllerDelegate).masterViewControllerDelegate = self
        
        
        let askStoryboard = UIStoryboard(name: "Ask", bundle: nil)
        askNavigationController = askStoryboard.instantiateInitialViewController() as! UINavigationController
        var askFrame = askNavigationController.view.frame
        askFrame.origin.x = view.frame.size.width
        askFrame.origin.y = 0
        askFrame.size.height = view.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height
        askNavigationController!.view.frame = askFrame
        (askNavigationController.delegate as! SectionNavigationControllerDelegate).masterViewControllerDelegate = self
        
        let questionsStoryboard = UIStoryboard(name: "Questions", bundle: nil)
        questionsNavigationController = questionsStoryboard.instantiateInitialViewController() as! UINavigationController
        var questionsFrame = questionsNavigationController.view.frame
        questionsFrame.origin.x = view.frame.size.width * 2
        questionsFrame.origin.y =  0
        questionsFrame.size.height = view.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height
        questionsNavigationController.view.frame = questionsFrame
        (questionsNavigationController.delegate as! SectionNavigationControllerDelegate).masterViewControllerDelegate = self
        
        scrollView.contentSize = CGSizeMake(view.frame.size.width * 3, view.frame.size.height - UIApplication.sharedApplication().statusBarFrame.height)
        
        scrollView.setContentOffset(CGPointMake(askFrame.origin.x, 0), animated: false)
        
    }

    override func viewDidLayoutSubviews() {
        
        
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
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        let page = lround(Double(fractionalPage))
        if (previousPage != page) {
            previousPage = page
            if (page == 1) {
                answersButton.hidden = false
            }
            else {
                answersButton.hidden = true
            }
        }
    }
    
    //MARK: - @IBActions
    @IBAction func answersButtonTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Answers", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        presentViewController(vc!, animated: true, completion: nil)
    }
    
    
}

