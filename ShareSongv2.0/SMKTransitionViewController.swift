//
//  SMKTransitionViewController.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 12/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import UIKit

class SMKTransitionViewController : UIViewController, UIViewControllerTransitioningDelegate {
    //MARK: - Properties -
    var logo: UIImageView?
    //MARK: - Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logo = UIImageView.init(image: UIImage.init(named: "logo.png"))
        self.logo?.translatesAutoresizingMaskIntoConstraints = false
        if let logo = self.logo {
            self.view.addSubview(logo)
            setConstrains()
        } else {
            fatalError("override func viewDidLoad()")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ViewController.self))
        viewController?.transitioningDelegate = self
        viewController?.modalPresentationStyle = .custom
        self.present(viewController!, animated: true, completion: nil)
    }
    //MARK: - Configure ui -
    func setConstrains() {
        guard let logo = self.logo else {
            fatalError("func setConstrains()")
        }
        logo.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: 75).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 83.5).isActive = true
    }
    //MARK: - Custom transition -
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SMKLoadAnimator()
    }
}


