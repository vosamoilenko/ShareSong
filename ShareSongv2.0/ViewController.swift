//
//  ViewController.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 09/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import UIKit
import os.log

// func startTrackingSong(link: String) {


//

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var swipeRecognizerDown: UISwipeGestureRecognizer!
    @IBOutlet var swipeRecognizerUP: UISwipeGestureRecognizer!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var decoratorLine: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var textField: UITextField!
    var activityIndicatorView: UIActivityIndicatorView!
    
    var transferManager: SMKSongTransfer?
    
    @IBOutlet weak var blurViewBottomConstrint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var constrainValueBlurView: CGFloat = 0.0
    var constrainValue: CGFloat = 0.0


    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        swipeRecognizerConfiguration()
        configureObservers()
        
        SMKSongTransfer.sharedTransfer.fetchStorefront()
        SMKSongStore.sharedStore.loadSongs()
        
        self.constrainValue = self.bottomConstraint.constant
        self.constrainValueBlurView = self.blurViewBottomConstrint.constant
        
        self.backgroundImageView.image = getBackgroundImage()
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
        self.view.layoutIfNeeded()
    }

}
extension ViewController {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SMKTransitionAnimatorTo()
    }
}

extension ViewController : UIViewControllerTransitioningDelegate {
    func captureScreen() -> UIImage? {
        guard let layer = UIApplication.shared.keyWindow?.layer else { return .none }
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return .none}
        layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return .none }
        UIGraphicsEndImageContext()
        
        return image
    }
    @objc func goToHistoryViewController() {
     
        let viewController = HistoryCollectionViewController.init(collectionViewLayout: UICollectionViewFlowLayout.init())

        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = .custom
        viewController.parentVC = self
        self.present(viewController, animated: true) {
            SMKSongStore.sharedStore.saveChanges()
        }
    }
    func changeYOfConstrain() {
        self.bottomConstraint.constant = self.constrainValue - self.view.frame.size.height
        self.blurViewBottomConstrint.constant = self.constrainValueBlurView + self.view.frame.size.height
        self.decoratorLine.layer.opacity = 1.0
        self.searchButton.layer.opacity = 1.0
        
        UIView.animate(withDuration: 0.08, animations: {
            self.view.layoutIfNeeded()
        })
    }
    func setback() {
        self.bottomConstraint.constant = self.constrainValue
        self.blurViewBottomConstrint.constant = self.constrainValueBlurView
        self.decoratorLine.layer.opacity = 0.6
        self.searchButton.layer.opacity = 0.6
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }
    func getBackgroundImage() -> UIImage? {
        let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archieveUrl = documentDirectory.appendingPathComponent("backgroundImage")
        if let img = NSKeyedUnarchiver.unarchiveObject(withFile: archieveUrl.path) as? UIImage {
            return img
        }
        return UIImage.init(named: "BACK")
    }
    
}
extension ViewController {
    func startLogoAnimation() {
        UIView.animate(withDuration: 1.0, animations: {   
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
                self.logo.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)

            }, completion: nil)
        }
    }
}

extension ViewController {
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
}
extension ViewController {
    func swipeRecognizerConfiguration() {
        self.swipeRecognizerUP.addTarget(self, action: #selector(ViewController.goToHistoryViewController))
        self.swipeRecognizerDown.addTarget(self, action: #selector(ViewController.presentAutoSearchSettingAlertController))
        self.blurView.addGestureRecognizer(self.swipeRecognizerUP)
        self.blurView.addGestureRecognizer(self.swipeRecognizerDown)
    }
    func prepareUI() {
        configureTextField()
        configureActivityIndicatorView()
        self.searchButton.addTarget(self, action: #selector(ViewController.startTrackingSongFromButton(sender:)), for: .touchUpInside)
        self.searchButton.layer.opacity = 0.8
        self.decoratorLine.layer.opacity = 0.6
        self.decoratorLine.layer.cornerRadius = 4

        self.blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
}
extension ViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.resignFirstResponder()
        if self.textField.text != "" {
            self.startTrackingSong(link: self.textField.text!)
        }
        return true;
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            changeHeightOfElementsDependFromKeyboard(up: true, keyboardRectangle: keyboardFrame.cgRectValue)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            changeHeightOfElementsDependFromKeyboard(up: false, keyboardRectangle: keyboardFrame.cgRectValue)
        }
    }
    func changeHeightOfElementsDependFromKeyboard(up: Bool, keyboardRectangle: CGRect) {
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
}
extension ViewController {
    func presentSuccessAlertController(message: String) {
        let alertController = UIAlertController.init(title: "Successs", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction.init(title: "Okay", style: .cancel, handler: { (action) in
            self.goToHistoryViewController()
        }))
        
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
}
extension ViewController {
    func startTrackingSong(link: String) {
        
        self.isUserInteractionEnabled(flag: false)
        self.activityIndicatorView.startAnimating()
        
        // if link wasn't correct
        if !SMKSongTransfer.isProperLink(link: link) {
            self.activityIndicatorView.stopAnimating()
            self.presentWrongLinkAlertController()
            self.textField.text = ""
            self.isUserInteractionEnabled(flag: true)
            return
        }
        
        // if link is already in "db"
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

