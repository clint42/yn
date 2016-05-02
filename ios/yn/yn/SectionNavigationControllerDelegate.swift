//
//  CustomNavigationControllerDelegate.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import Foundation
import UIKit

class SectionNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    var masterViewControllerDelegate: MasterViewControllerDelegate!
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if navigationController.viewControllers[0] == toVC {
            masterViewControllerDelegate.enableMainNavigation()
        }
        else {
            masterViewControllerDelegate.disableMainNavigation()
        }

        var transition: UIViewControllerAnimatedTransitioning? = nil
        if operation == UINavigationControllerOperation.Push {
            transition = SlideUpTransitionAnimator()
        }
        else if operation == UINavigationControllerOperation.Pop {
            transition = SlideDownTransitionAnimator()
        }
        return transition
    }
    
    
}
