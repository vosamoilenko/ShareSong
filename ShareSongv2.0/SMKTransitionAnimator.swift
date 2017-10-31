//
//  SMKTransitionAnimator.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 30/10/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import UIKit

class SMKTransitionAnimatorTo: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? ViewController else {
            fatalError()
        }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            fatalError()
        }
        let inView = transitionContext.containerView

        inView.addSubview(toViewController.view)
        toViewController.view.alpha = 0.0
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: {
            UIView.animateKeyframes(withDuration: 0.99, delay: 0.0, options: .calculationModeLinear, animations: {
                fromViewController.changeYOfConstrain()
            }, completion: { (true) in
                 UIView.animateKeyframes(withDuration: 0.01, delay: 0.0, options: .calculationModeLinear, animations: {
                     toViewController.view.alpha = 1.0
                 }, completion: { (true) in
                    
                    transitionContext.completeTransition(true)
                 })
            })
        }, completion: nil)
    }
}

class SMKTransitionAnimatorBack: NSObject ,UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? HistoryCollectionViewController else {
            fatalError()
        }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? ViewController else {
            fatalError()
        }
        let inView = transitionContext.containerView
        
        inView.addSubview(fromViewController.view)
        toViewController.view.alpha = 1.0
        
        
        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: {
            UIView.animateKeyframes(withDuration: 0.99, delay: 0.0, options: .calculationModeLinear, animations: {
                fromViewController.view.alpha = 0.0
                
                toViewController.setback()
            }, completion: { (true) in
                UIView.animateKeyframes(withDuration: 0.01, delay: 0.0, options: .calculationModeLinear, animations: {
                    
                }, completion: { (true) in
                    transitionContext.completeTransition(true)
                })
            })
        }, completion: nil)
    }

    
    
}
