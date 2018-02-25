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
    var imageView: UIImageView?
    //MARK: - Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView = UIImageView.init(frame: .zero)
        self.imageView?.image = UIImage.init()
        self.view.addSubview(self.imageView!)
        
        self.logo = UIImageView.init(image: UIImage.init(named: "logo.png"))
        
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
        self.logo?.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.imageView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.imageView?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.imageView?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
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


