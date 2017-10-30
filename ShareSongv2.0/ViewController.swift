//
//  ViewController.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 09/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController, UITextFieldDelegate {
    

    
    @IBOutlet weak var decoratorLine: UIImageView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var textField: UITextField!
    var activityIndicatorView: UIActivityIndicatorView!
    var transferManager: SMKSongTransfer?
    var constrainValue: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        configureObservers()
        SMKSongTransfer.sharedTransfer.fetchStorefront()
        SMKSongStore.sharedStore.loadSongs()
        self.constrainValue = self.bottomConstraint.constant
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let autoSearchStatus = UserDefaults.standard.object(forKey: "autoSearch") as? Bool,
            autoSearchStatus,
            let url = UIPasteboard.general.string {
                DispatchQueue.once(token: "primary-search", block: {
                    startTrackingSong(link: url)
                })
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textField.resignFirstResponder()
    }
    
    func t() {
       myTest { (result) in
        startTest(counter: 120,source: result)
        }
    }
    
    func prepareUI() {
        configureTextField()
        configureActivityIndicatorView()
        self.searchButton.addTarget(self, action: #selector(ViewController.startTrackingSongFromButton(sender:)), for: .touchUpInside)
        self.searchButton.layer.opacity = 0.8
        self.decoratorLine.layer.opacity = 0.6
        self.decoratorLine.layer.cornerRadius = 4
    }
    func configureTextField() {
        self.textField.delegate = self
        self.textField.backgroundColor = .clear
        self.textField.textAlignment = .center
    }
    func configureActivityIndicatorView() {
        self.activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.activityIndicatorView.center = self.view.center
        self.view.addSubview(self.activityIndicatorView)
    }
    
    


//    func configureSettingsButton() {
//        self.settingButton.addTarget(self, action: #selector(presentAutoSearchSettingAlertController), for: .touchUpInside)
//        self.settingButton.addTarget(self, action: #selector(t), for: .touchUpInside)
//    }
    // alertControllers
    func presentSuccessAlertController(message: String) {
        let alertController = UIAlertController.init(title: "Successs", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction.init(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentFailAlertController() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.title = "Error"
        alertController.addAction(UIAlertAction.init(title: "Noooo", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
    func presentWrongLinkAlertController() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.title = "Oooops"
        alertController.message = " Your link is wrong"
        alertController.addAction(UIAlertAction.init(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
    @objc func presentAutoSearchSettingAlertController() {
        var autoSearchStatus: Bool?
        
        if let status = UserDefaults.standard.object(forKey: "autoSearch") as? Bool {
            autoSearchStatus = status
        } else {
            autoSearchStatus = false
        }
        
        let alertController = UIAlertController.init(title: "Auto-search", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let actionTitle = titleForAutoSearchSettingsAlertControllerAction(!autoSearchStatus!)
        let action = UIAlertAction.init(title: actionTitle, style: .default) { (action) in
            
            UserDefaults.standard.set(!autoSearchStatus!, forKey: "autoSearch")
        }
        
        let message = "Auto-search is \(titleForAutoSearchSettingsAlertControllerAction(autoSearchStatus!))"
        alertController.message = message
        alertController.addAction(action)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func titleForAutoSearchSettingsAlertControllerAction(_ autoSearchStatus: Bool) -> String {
        switch autoSearchStatus {
        case true:
            return "Enable"
        default:
            return "Disable"
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        if self.textField.text != "" {
            self.startTrackingSong(link: self.textField.text!)
        }
        return true;
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            changeYOfTextField(up: true, keyboardRectangle: keyboardFrame.cgRectValue)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            changeYOfTextField(up: false, keyboardRectangle: keyboardFrame.cgRectValue)
        }
    }
    func changeYOfTextField(up: Bool, keyboardRectangle: CGRect) {
        let distanceForAnimtion = keyboardRectangle.height * 0.6
        if up {
            self.bottomConstraint.constant = self.constrainValue - distanceForAnimtion
            self.decoratorLine.layer.opacity = 1.0
            self.searchButton.layer.opacity = 1.0
        } else {
        self.bottomConstraint.constant = self.constrainValue
            self.decoratorLine.layer.opacity = 0.6
            self.searchButton.layer.opacity = 0.6
        }

        UIView.animate(withDuration: 0.08, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTrackingSongFromNotification(notification:)), name: NSNotification.Name(rawValue: "autoSearch"), object: nil)
    }
    func completionWhenSongIsAlreadyInStore(song: SMKSong) {
        
        guard let title = song.title,
            let artist = song.artist,
            let appleLink = song.appleLink,
            let spotifyLink = song.spotifyLink,
            let pasteboardLink = UIPasteboard.general.string else { return }
        
        
        DispatchQueue.global().async {
            DispatchQueue.main.async {
        self.presentSuccessAlertController(message: "\"\(title)\" by \(artist) was found! Link already in your copyboard!")
                self.activityIndicatorView.stopAnimating()
            }
        }
        
        if SpotifySearch.isSpotify(link: pasteboardLink) {
            UIPasteboard.general.string = appleLink
        } else {
            UIPasteboard.general.string = spotifyLink
        }
        self.isUserInteractionEnabled(flag: true)
    }

    func isUserInteractionEnabled(flag: Bool) {
        self.textField.isUserInteractionEnabled = flag;
    }
    
    func startTrackingSong(link: String) {
        
        self.isUserInteractionEnabled(flag: false)
        self.activityIndicatorView.startAnimating()
        
        
        if !SMKSongTransfer.isProperLink(link: link) {
            self.activityIndicatorView.stopAnimating()
            self.presentWrongLinkAlertController()
            self.textField.text = ""
            self.isUserInteractionEnabled(flag: true)
            return
        }
        
        if let presenceSong = SMKSongStore.sharedStore.songByLink(link: link) {
            self.completionWhenSongIsAlreadyInStore(song: presenceSong)
            return
        }
            
        SMKSongTransfer.sharedTransfer.transfer(link: link, completion: { (info) in
            
            guard let info = info as? [String:String],
            let title = info["title"],
            let artist = info["artist"],
            let album = info["album"],
            let imageLink = info["imageLink"],
            let url = info["url"] else {
                print("func startTrackingSong")
                return
            }
            
            var spotifyLink, appleLink, spotifyUri, appleUri: String?
            
            if SpotifySearch.isSpotify(link: url) {
                // apple -> spotify
                guard let uri = info["spotifyUri"],
                    let link = UIPasteboard.general.string else {
                        return
                }
                spotifyLink = url
                spotifyUri = uri
                appleLink = link
                appleUri = link + "&app=music"
            } else {
                // spotify -> apple
                appleLink = url
                appleUri = url + "&app=music"
                spotifyUri = info["spotifyUri"]
                spotifyLink = UIPasteboard.general.string
            }
            let song = ["title":title,
                        "artist":artist,
                        "album":album,
                        "spotifyLink":spotifyLink!,
                        "appleLink":appleLink,
                        "imageLink":imageLink,
                        "spotifyUri":spotifyUri,
                        "appleUri":appleUri]
            
            SMKSongStore.sharedStore.addSong(dict: song as! [String : String])
            
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    self.presentSuccessAlertController(message: "\"\(title)\" by \(artist) was found! Link already in your copyboard!")
                    self.activityIndicatorView.stopAnimating()
                    self.isUserInteractionEnabled(flag: true)
                }
            }
            UIPasteboard.general.string = url

        }, failure: { (error) in
            
            DispatchQueue.global().async {
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.presentFailAlertController()
                    self.isUserInteractionEnabled(flag: true)
                }
            }
        })
    }
    @objc func startTrackingSongFromNotification(notification: Notification) {
        
        guard let url = UIPasteboard.general.string,
            let autoSearch = UserDefaults.standard.object(forKey: "autoSearch") as? Bool else { return }
        if autoSearch {
            self.startTrackingSong(link: url)
        }
        
    }
    @objc func startTrackingSongFromButton(sender: AnyObject) {
        guard let url = UIPasteboard.general.string else { return }
        self.startTrackingSong(link: url)
    }
}


