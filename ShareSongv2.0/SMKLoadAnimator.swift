//
//  SMKLoadAnimator.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 12/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import UIKit

class SMKLoadAnimator: NSObject ,UIViewControllerAnimatedTransitioning {
    //MARK: - Custom animating transition -
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? SMKTransitionViewController else {
            fatalError()
        }
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            fatalError()
        }
        let inView = transitionContext.containerView
        
        
        inView.addSubview(toViewController.view)
        toViewController.view.alpha = 0.0

        UIView.animateKeyframes(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: {
            UIView.animateKeyframes(withDuration: 0.6/1.0, delay: 0, options: UIViewKeyframeAnimationOptions(rawValue: 0), animations: { 
fromViewController.logo?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            }, completion: { (Bool) in
                UIView.animateKeyframes(withDuration: 0.4/1.0, delay: 0.6/1.0, options: .calculationModeLinear, animations: {
                    fromViewController.logo?.transform = CGAffineTransform.init(scaleX: 70.0, y: 70.0)
                    toViewController.view.alpha = 1.0
                }, completion: { (Bool) in
                    transitionContext.completeTransition(true)
                })
            })
        }) { (Bool) in }
    }
}
