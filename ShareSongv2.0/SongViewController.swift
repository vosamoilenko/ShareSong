//
//  SongViewController.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 01.01.18.
//  Copyright © 2018 Samoilenko Volodymyr. All rights reserved.
//
import UIKit
import Foundation


class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setGradient(colors: [CGColor]) {
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = colors
    }
}

class SongViewController : UIViewController {
    var backgroundImageView = UIImageView()
    var blurView = UIVisualEffectView()
    
    var imageView = UIImageView.init(frame: .zero)
    var titleLabel = UILabel.init(frame: .zero)
    var artistLabel = UILabel.init(frame: .zero)
    var spotifyButton = UIButton.init(frame: .zero)
    var appleButton = UIButton.init(frame: .zero)

    var song: SMKSong?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        configureButtons()
        configureSwipeRecognizer()
        setConstrains()
        
        
        self.titleLabel.numberOfLines = 3
        self.titleLabel.font = UIFont.init(name: "Helvetica", size: 20)
        self.artistLabel.font = UIFont.init(name: "Helvetica", size: 18)
        
        self.titleLabel.textColor = .white
        self.artistLabel.textColor = .white
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderColor = UIColor.white.cgColor
        self.imageView.layer.borderWidth = 8
        
        startImageAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func startImageAnimation() {
        UIView.animate(withDuration: 1.0, animations: {
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            }, completion: nil)
        }
    }
    
    fileprivate func addViews() {
        self.view.addSubview(backgroundImageView)
        configureBlurView()
        self.view.addSubview(titleLabel)
        self.view.addSubview(artistLabel)
        self.view.addSubview(imageView)
        self.view.addSubview(spotifyButton)
        self.view.addSubview(appleButton)
    }
    
    fileprivate func configureButtons() {
        self.appleButton.setImage(UIImage.init(named: "appleButton"), for: .normal)
        self.spotifyButton.setImage(UIImage.init(named: "spotifyButton"), for: .normal)
        
        self.appleButton.addTarget(self, action: #selector(presentShareAlertControllerBy), for: UIControlEvents.touchUpInside)
        self.spotifyButton.addTarget(self, action: #selector(presentShareAlertControllerBy), for: UIControlEvents.touchUpInside)
        
        self.spotifyButton.tag = 0
        self.appleButton.tag = 1
    }
    
    fileprivate func configureSwipeRecognizer() {
        let down = UISwipeGestureRecognizer.init()
        let up = UISwipeGestureRecognizer.init()
        
        down.direction = .down
        up.direction = .up
        
        down.addTarget(self, action: #selector(dissmiss))
        up.addTarget(self, action: #selector(dissmiss))
        
        self.view.addGestureRecognizer(down)
        self.view.addGestureRecognizer(up)
    }
    fileprivate func configureBlurView() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect.init(style: .dark)
            self.blurView.effect = blurEffect
            self.view.addSubview(self.blurView)
        } else {
            let color: UIColor = UIColor.init(red: 198/255.0, green: 235/255.0, blue: 255/255.0, alpha: 1.0)
            self.view.backgroundColor = color
        }
    }
    func set(_ song: SMKSong) {
        self.song = song
        self.imageView.image = song.image
        
        titleLabel.text = song.title
        self.titleLabel.textAlignment = .center
        self.artistLabel.textAlignment = .center
        artistLabel.text = song.artist
    }
    fileprivate func setConstrains() {
        let margin: UILayoutGuide = self.view.layoutMarginsGuide
        let distanceBetweenButtons = self.view.frame.size.width / 6.5
        
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.artistLabel.translatesAutoresizingMaskIntoConstraints = false
        self.spotifyButton.translatesAutoresizingMaskIntoConstraints = false
        self.appleButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.backgroundImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.backgroundImageView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.blurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.blurView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.blurView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

        self.imageView.topAnchor.constraint(equalTo: margin.topAnchor, constant: 80).isActive = true
        self.imageView.leftAnchor.constraint(greaterThanOrEqualTo: margin.leftAnchor, constant: 50).isActive = true
        self.imageView.centerXAnchor.constraint(equalTo: margin.centerXAnchor).isActive = true
        self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor, multiplier: 1.0).isActive = true

        self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: self.view.frame.size.height * 0.1).isActive = true
        self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.titleLabel.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.8).isActive = true

        self.artistLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
        self.artistLabel.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor).isActive = true
        self.artistLabel.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.8).isActive = true

        self.spotifyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.spotifyButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.appleButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.appleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        self.spotifyButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -self.view.frame.size.height * 0.1).isActive = true
        self.appleButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -self.view.frame.size.height * 0.1).isActive = true

//        self.spotifyButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: self.view.frame.size.height * 0.1).isActive = true
//        self.appleButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: self.view.frame.size.height * 0.1).isActive = true
        
        
        self.spotifyButton.rightAnchor.constraint(equalTo: margin.centerXAnchor, constant: -distanceBetweenButtons).isActive = true
        self.appleButton.leftAnchor.constraint(equalTo: margin.centerXAnchor, constant: distanceBetweenButtons).isActive = true

        
    }
    @objc  fileprivate func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc fileprivate func presentShareAlertControllerBy(sender: UIButton) {
        
        let alertController = UIAlertController.init(title: "Share", message: "\(self.titleLabel.text?.description ?? "")", preferredStyle: .actionSheet)
        
        var copyAction: UIAlertAction?
        var redirectAction: UIAlertAction?
        var cancelAction: UIAlertAction?
        
        print(sender.tag)
        if sender.tag == 1 {
            copyAction = UIAlertAction.init(title: "Copy to clipboard", style: .default) { (copy) in
                UIPasteboard.general.string = self.song?.appleLink
                self.dismiss(animated: true, completion: nil)
            }

            redirectAction = UIAlertAction.init(title: "Open in Apple Music", style: .default, handler: { (openInApp) in
                let url = URL.init(string:(self.song?.appleUri)!)
                UIApplication.shared.open(url!, options: [:], completionHandler: { (b) in
                    self.dismiss(animated: true, completion: nil)
                })
            })
        } else {
            copyAction = UIAlertAction.init(title: "Copy to clipboard", style: .default) { (copy) in
                UIPasteboard.general.string = self.song?.spotifyLink
                self.dismiss(animated: true, completion: nil)
            }
            redirectAction = UIAlertAction.init(title: "Open in Spotify", style: .default, handler: { (openInApp) in
                let url = URL.init(string:(self.song?.spotifyUri)!)
                UIApplication.shared.open(url!, options: [:], completionHandler: { (b) in
                self.dismiss(animated: true, completion: nil)
                })
            })
        }
        
        cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(redirectAction!)
        alertController.addAction(copyAction!)
        alertController.addAction(cancelAction!)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
