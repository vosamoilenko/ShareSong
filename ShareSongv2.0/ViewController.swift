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
    
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var roundedBackgroundLogo: UIView!
    @IBOutlet weak var logoImage: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backgroundBlueView: UIView!
    @IBOutlet weak var goToHistoryViewControllerButton: UIButton!
    @IBOutlet weak var biggerDecoratingView: UIView!
    @IBOutlet weak var smallerDecoratingView: UIView!
    var activityIndicatorView: UIActivityIndicatorView!
    var transferManager: SMKSongTransfer?
    @IBOutlet weak var textFieldTopConstr: NSLayoutConstraint!
    var constrainValue: CGFloat = 0.0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        configureSettingsButton()
        configureObservers()
        SMKSongTransfer.sharedTransfer.fetchStorefront()
        SMKSongStore.sharedStore.loadSongs()
        self.constrainValue = self.textFieldTopConstr.constant
        

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
        configureRoundedBackgroundLogo()
        configureTextField()
        configureDecoratorLines()
        configureActivityIndicatorView()
        configureBottomButtonImage()
        configureBackgroundBlueView()
    }
    func configureRoundedBackgroundLogo() {
        self.roundedBackgroundLogo.layer.cornerRadius = self.roundedBackgroundLogo.frame.width/2.0
    }
    func configureBackgroundBlueView() {
        self.backgroundBlueView.layer.cornerRadius = 15
    }
    func configureTextField() {
        self.textField.delegate = self
        
        self.textField.layer.cornerRadius = 6;
        self.textField.layer.borderWidth = 3;
        self.textField.layer.borderColor = UIColor.init(red: 247/255.0, green: 150/255.0, blue: 150/255.0, alpha: 1.0).cgColor
        self.textField.textAlignment = .center
        self.textField.clearButtonMode = .whileEditing;
    }
    func configureDecoratorLines() {
        self.biggerDecoratingView.layer.cornerRadius = 2
        self.smallerDecoratingView.layer.cornerRadius = 2;
    }
    func configureActivityIndicatorView() {
        self.activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.activityIndicatorView.center = self.view.center
        self.view.addSubview(self.activityIndicatorView)
    }
    func configureBottomButtonImage() {
        self.goToHistoryViewControllerButton.setImage(UIImage(named: "up"), for: .normal)
        setConstrainsToBottomButtonImageView();
    }
    func setConstrainsToBottomButtonImageView() {
        self.goToHistoryViewControllerButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
        self.goToHistoryViewControllerButton.imageView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
            self.goToHistoryViewControllerButton.imageView?.widthAnchor.constraint(equalToConstant: 36).isActive = true
        self.goToHistoryViewControllerButton.imageView?.centerXAnchor.constraint(equalTo: self.goToHistoryViewControllerButton.centerXAnchor).isActive = true
        self.goToHistoryViewControllerButton.imageView?.centerYAnchor.constraint(equalTo: self.goToHistoryViewControllerButton.centerYAnchor).isActive = true
    }
    func setMaskToBackgroundBlueView() {
        let maskLayer: CAShapeLayer = CAShapeLayer.init()
        let maskRect: CGRect = CGRect.init(x: 0, y: 0, width: self.backgroundBlueView.frame.size.width,
                                           height: self.backgroundBlueView.frame.size.height)
        let path: UIBezierPath = UIBezierPath.init()

        let proportionMultiplierCostantForMask: CGFloat = 0.737
        path.move(to: CGPoint(x:0, y:0))
        path.addLine(to: CGPoint(x:maskRect.size.width, y:0))
        path.addLine(to: CGPoint(x:maskRect.size.width, y:maskRect.size.height * proportionMultiplierCostantForMask ))
        path.addLine(to: CGPoint(x:0, y:maskRect.size.height))
        path.move(to: CGPoint(x:0, y:0))
        path.close()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path.cgPath
        self.backgroundBlueView.layer.mask = maskLayer
    }               
    func configureSettingsButton() {
        self.settingButton.addTarget(self, action: #selector(presentAutoSearchSettingAlertController), for: .touchUpInside)
//        self.settingButton.addTarget(self, action: #selector(t), for: .touchUpInside)
    }
    func setConstrainsToBackgroundBlueView() {
        self.backgroundBlueView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundBlueView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        self.backgroundBlueView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 10).isActive = true
        self.backgroundBlueView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        self.backgroundBlueView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 133).isActive = true
        
        
    }
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
        self.textFieldTopConstr.constant = self.constrainValue - distanceForAnimtion
        } else {
        self.textFieldTopConstr.constant = self.constrainValue
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
        self.settingButton.isUserInteractionEnabled = flag;
        self.goToHistoryViewControllerButton.isUserInteractionEnabled = flag;
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
}
