//
//  SongViewController.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 01.01.18.
//  Copyright © 2018 Samoilenko Volodymyr. All rights reserved.
//
import UIKit
import Foundation

class SongViewController : UIViewController {
    var appleMusicLink = String()
    var spotifyLink = String()
    var appleUri = String()
    var spotifyUri = String()
    var backgroundImageView = UIImageView()
    var blurView = UIVisualEffectView()
    
    var imageView = UIImageView.init(frame: .zero)
    var titleLabel = UILabel.init(frame: .zero)
    var artistLabel = UILabel.init(frame: .zero)
    var spotifyButton = UIButton.init(frame: .zero)
    var appleButton = UIButton.init(frame: .zero)
    var song: SMKSong?
    
    override func viewDidLoad() {
        addViews()
        configureButtons()
        configureSwipeRecognizer()
        setConstrains()
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
        
        self.appleMusicLink = song.appleLink!
        self.appleUri = song.appleUri!
        
        self.spotifyLink = song.spotifyLink!
        self.spotifyUri = song.spotifyUri!
        self.imageView.image = song.image
        
        titleLabel.text = song.title
        self.titleLabel.textAlignment = .center
        self.artistLabel.textAlignment = .center
        artistLabel.text = song.artist
    }
    fileprivate func setConstrains() {
        let margin: UILayoutGuide = self.view.layoutMarginsGuide
        let distanceBetweenButtons = self.view.frame.size.width / 6.5
        let paddingBottomInView: CGFloat = 100.0
        
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
        
        self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 30).isActive = true
        self.titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        self.titleLabel.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.8).isActive = true
        
        self.artistLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20).isActive = true
        self.artistLabel.centerXAnchor.constraint(equalTo: self.titleLabel.centerXAnchor).isActive = true
        self.artistLabel.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.8).isActive = true
        
        self.spotifyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.spotifyButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.appleButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.appleButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        self.spotifyButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -paddingBottomInView).isActive = true
        self.appleButton.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -paddingBottomInView).isActive = true

        self.spotifyButton.rightAnchor.constraint(equalTo: margin.centerXAnchor, constant: -distanceBetweenButtons).isActive = true
        self.appleButton.leftAnchor.constraint(equalTo: margin.centerXAnchor, constant: distanceBetweenButtons).isActive = true
        
        
    }
    @objc  fileprivate func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc fileprivate func presentShareAlertControllerBy(sender: UIButton) {
        
        let alertController = UIAlertController.init(title: "Share", message: "", preferredStyle: .actionSheet)
        
        var copyAction: UIAlertAction?
        var redirectAction: UIAlertAction?
        var cancelAction: UIAlertAction?
        
        print(sender.tag)
        if sender.tag == 0 {
            copyAction = UIAlertAction.init(title: "Copy to clipboard", style: .default) { (copy) in
                UIPasteboard.general.string = self.appleMusicLink
                self.dismiss(animated: true, completion: nil)
            }

            redirectAction = UIAlertAction.init(title: "Open in Apple Music", style: .destructive, handler: { (openInApp) in
                let url = URL.init(string:self.appleUri)
                UIApplication.shared.open(url!, options: [:], completionHandler: { (b) in
                    self.dismiss(animated: true, completion: nil)
                })
            })
        } else {
            copyAction = UIAlertAction.init(title: "Copy to clipboard", style: .default) { (copy) in
                UIPasteboard.general.string = self.spotifyLink
                self.dismiss(animated: true, completion: nil)
            }
            redirectAction = UIAlertAction.init(title: "Open in Spotify", style: .destructive, handler: { (openInApp) in
                let url = URL.init(string:self.spotifyUri)
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
