//
//  CircleTransitionAnimator.swift
//  yn
//
//  Created by Aurelien Prieur on 30/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit

class SlideUpTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var originFrame = CGRect.zero
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        let initialFrame = originFrame
        
        let snapshot = toVC.view.snapshotViewAfterScreenUpdates(true)
        snapshot.frame = initialFrame
        snapshot.layer.masksToBounds = true

        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        
        let duration = transitionDuration(transitionContext)
        
        toVC.view.hidden = false
        toVC.view.alpha = 1
        toVC.view.frame.origin.y = fromVC.view.frame.height
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            fromVC.view.frame.origin.y = (toVC.view.frame.height * -1) + 66
            toVC.view.frame.origin.y = 0
        }) { (success) in
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        UIView.animateWithDuration(duration, animations: {
            
        }) { (success: Bool) in
            
        }
    }
}

class SlideDownTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var originFrame = CGRect.zero
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let containerView = transitionContext.containerView(),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        let initialFrame = originFrame
        
        let snapshot = toVC.view.snapshotViewAfterScreenUpdates(true)
        snapshot.frame = initialFrame
        snapshot.layer.masksToBounds = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        
        let duration = transitionDuration(transitionContext)
        
        toVC.view.hidden = false
        toVC.view.alpha = 1
        toVC.view.frame.origin.y = UIApplication.sharedApplication().statusBarFrame.height - toVC.view.frame.height
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            fromVC.view.frame.origin.y = toVC.view.frame.height - UIApplication.sharedApplication().statusBarFrame.height
            toVC.view.frame.origin.y = 0
        }) { (success) in
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        UIView.animateWithDuration(duration, animations: {
            
        }) { (success: Bool) in
            
        }
    }
}
