//
//  HistoryViewController.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 10/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import UIKit

class HistoryCollectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var count: Int = 0
    func getColor() -> UIColor {
        count += 1
        switch count % 5 {
        case 0:
            return .green
        case 1:
            return .yellow
        case 2:
            return .red
        case 3:
            return .blue
        default:
            return .gray
        }
    }
    // MARK: - Properties -
    var dissmissButton: UIButton?
    var overlayView: UIView?
    var blurView: UIVisualEffectView?

    var appleMusicLink: String?
    var spotifyLink: String?
    var appleUri: String?
    var spotifyUri: String?
    
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var artistLabel: UILabel?
    var spotifyLinkToPasteboardButton: UIButton?
    var appleMusicLinkToPasteboardButton: UIButton?

    // MARK: - View life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureUI()
        
        let x = UISwipeGestureRecognizer.init()
        x.direction = .down
        x.addTarget(self, action: #selector(dissmiss))
        self.view.addGestureRecognizer(x)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch = touches.first!
        
        if let overlayView = self.overlayView {
            if let blurView = self.blurView {
                if (touch.view == blurView) {
                    clearSongInfo()
                    hideOverlayView()
                }
            } else {
                if touch.view == overlayView {
                    clearSongInfo()
                    hideOverlayView()
                }
            }
        }
    }
    // MARK: - Datasource & Delegate -
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SMKSongStore.sharedStore.count()
//        return 50
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HistoryViewCollectionCell.self), for: indexPath) as! HistoryViewCollectionCell
        guard let image = SMKSongStore.sharedStore.songAt(index: indexPath.item).image else {
            fatalError("no song for index")
        }
        cell.backgroundColor = getColor()
        
        cell.fillData(image: image)
        

        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let song = SMKSongStore.sharedStore.songAt(index: indexPath.item)
        guard let title = song.title,
            let artist = song.artist,
            let spotifyLink = song.spotifyLink,
            let appleLink = song.appleLink,
            let image = song.image,
            let spotifyUri = song.spotifyUri,
            let appleUri = song.appleUri else {
                fatalError("no song for index")
        }
        setSongInfo(title: title, artist: artist, image: image, spotifyLink: spotifyLink, appleLink: appleLink, spotifyUri: spotifyUri, appleUri: appleUri)
        showOverlayView()
    }
    // MARK: - Configure ui -
    func configureUI() {
        confgureBackgroundColor()
        configureDissmissButton()
        configureBlurView()
        configureOverlayAfterDidSelectItem()
    }
    func confgureBackgroundColor() {
        self.collectionView!.backgroundColor = .white
    }
    func configureDissmissButton() {
        self.dissmissButton = .init()
        self.dissmissButton?.addTarget(self, action:#selector(HistoryCollectionViewController.dissmiss) , for: .touchUpInside)
        self.dissmissButton?.setImage(UIImage.init(named: "down"), for: .normal)
        self.view.addSubview(self.dissmissButton!)
        setConstrinsToDissmissButton()
    }
    func setConstrinsToDissmissButton() {
        self.dissmissButton?.translatesAutoresizingMaskIntoConstraints = false
        self.dissmissButton?.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 1).isActive = true
        self.dissmissButton?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        self.dissmissButton?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        self.dissmissButton?.imageView?.translatesAutoresizingMaskIntoConstraints = false
        self.dissmissButton?.imageView?.bottomAnchor.constraint(equalTo: self.dissmissButton!.bottomAnchor, constant: -15).isActive = true
        
        self.dissmissButton?.imageView?.heightAnchor.constraint(equalToConstant: 22).isActive = true
        self.dissmissButton?.imageView?.widthAnchor.constraint(equalToConstant: 36).isActive = true
    }
    func configureBlurView() {
        self.overlayView = UIView.init(frame: self.view.frame)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect.init(style: .dark)
            self.blurView = UIVisualEffectView.init(effect: blurEffect)
            self.blurView?.frame = self.view.bounds
            
            self.overlayView?.addSubview(self.blurView!)
        } else {
            let color: UIColor = UIColor.init(red: 198/255.0, green: 235/255.0, blue: 255/255.0, alpha: 1.0)
            self.overlayView?.backgroundColor = color
        }
        self.overlayView?.isHidden = true
    
    }
    func configureImageView() {
        self.imageView = UIImageView.init()
        self.imageView?.image = UIImage.init(named: "spotifyButtom")
        self.imageView?.contentMode = .scaleAspectFill
        self.imageView?.isHidden = true
        self.imageView?.translatesAutoresizingMaskIntoConstraints = false
    }
    func configureTitleLabel() {
        self.titleLabel = UILabel.init()
        self.titleLabel?.isHidden = true
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.textColor = .white
        self.titleLabel?.textAlignment = .center
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    func configureArtistLabel() {
        self.artistLabel = UILabel.init()
        self.artistLabel?.isHidden = true
        self.artistLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.artistLabel?.numberOfLines = 0
        self.artistLabel?.textColor = .white
        self.artistLabel?.textAlignment = .center
    }
    func configureSpotifyLinkButton() {
        self.spotifyLinkToPasteboardButton = UIButton.init()
        self.spotifyLinkToPasteboardButton?.tag = 0
        self.spotifyLinkToPasteboardButton?.isHidden = true
        self.spotifyLinkToPasteboardButton?.translatesAutoresizingMaskIntoConstraints = false
        self.spotifyLinkToPasteboardButton?.backgroundColor = .clear
        self.spotifyLinkToPasteboardButton?.setImage(UIImage.init(named: "spotifyButtonImage"), for: .normal)
        self.spotifyLinkToPasteboardButton?.addTarget(self, action: #selector(presentShareAlertControllerBy(sender:)), for: .touchUpInside)
    }
    func configureAppleLinkButton() {
        self.appleMusicLinkToPasteboardButton = UIButton.init()
        self.spotifyLinkToPasteboardButton?.tag = 1
        self.appleMusicLinkToPasteboardButton?.isHidden = true
        self.appleMusicLinkToPasteboardButton?.translatesAutoresizingMaskIntoConstraints = false
        self.appleMusicLinkToPasteboardButton?.backgroundColor = .clear
        self.appleMusicLinkToPasteboardButton?.setImage(UIImage.init(named: "appleButtonImage"), for: .normal)
        self.appleMusicLinkToPasteboardButton?.addTarget(self, action: #selector(presentShareAlertControllerBy(sender:)), for: .touchUpInside)
    }
    @objc func presentShareAlertControllerBy(sender: UIButton) {
        
        let alertController = UIAlertController.init(title: "Share", message: "", preferredStyle: .actionSheet)
        
        var copyAction: UIAlertAction?
        var redirectToAppAction: UIAlertAction?
        var cancelAction: UIAlertAction?
        
        if sender.tag == 0 {
            copyAction = UIAlertAction.init(title: "Copy to clipboard", style: .default) { (copy) in
                UIPasteboard.general.string = self.appleMusicLink
                self.hideOverlayView()
            }
            redirectToAppAction = UIAlertAction.init(title: "Open in Apple Music", style: .destructive, handler: { (openInApp) in
                guard let link = self.appleUri,
                let url = URL.init(string: link) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                self.hideOverlayView()
            })
        } else {
            copyAction = UIAlertAction.init(title: "Copy to clipboard", style: .default) { (copy) in
                UIPasteboard.general.string = self.spotifyLink
                self.hideOverlayView()
            }
            redirectToAppAction = UIAlertAction.init(title: "Open in Spotify", style: .destructive, handler: { (openInApp) in
                guard let link = self.spotifyUri,
                    let url = URL.init(string: link) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                self.hideOverlayView()
            })
        }

        cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
        
        guard let copy = copyAction,
        let redirect = redirectToAppAction,
        let cancel = cancelAction else { return }
        
        alertController.addAction(redirect)
        alertController.addAction(copy)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func configureOverlayAfterDidSelectItem() {
        
        configureImageView()
        configureTitleLabel()
        configureArtistLabel()
        configureSpotifyLinkButton()
        configureAppleLinkButton()

        self.view.addSubview(self.overlayView!)
        self.view.addSubview(self.imageView!)
        self.view.addSubview(self.spotifyLinkToPasteboardButton!)
        self.view.addSubview(self.appleMusicLinkToPasteboardButton!)
        self.view.addSubview(self.titleLabel!)
        self.view.addSubview(self.artistLabel!)
        self.appleMusicLinkToPasteboardButton?.isHidden = true
        
        setConstrainsToOverlayView()
    }
    func setConstrainsToOverlayView() {
        
        let margin: UILayoutGuide = self.view.layoutMarginsGuide
        let distanceBetweenButtons = self.view.frame.size.width / 6.5
        let paddingBottomInView: CGFloat = 100.0
        
        self.imageView?.topAnchor.constraint(equalTo: margin.topAnchor, constant: 80).isActive = true
        self.imageView?.leftAnchor.constraint(greaterThanOrEqualTo: margin.leftAnchor, constant: 50).isActive = true
        self.imageView?.centerXAnchor.constraint(equalTo: margin.centerXAnchor).isActive = true
        self.imageView?.heightAnchor.constraint(equalTo: self.imageView!.widthAnchor, multiplier: 1.0).isActive = true
        
        self.titleLabel?.topAnchor.constraint(equalTo: self.imageView!.bottomAnchor, constant: 30).isActive = true
        self.titleLabel?.centerXAnchor.constraint(equalTo: self.imageView!.centerXAnchor).isActive = true
        self.titleLabel?.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.8).isActive = true

        self.artistLabel?.topAnchor.constraint(equalTo: self.titleLabel!.bottomAnchor, constant: 20).isActive = true
        self.artistLabel?.centerXAnchor.constraint(equalTo: self.titleLabel!.centerXAnchor).isActive = true
        self.artistLabel?.widthAnchor.constraint(equalTo: margin.widthAnchor, multiplier: 0.8).isActive = true
        
        self.spotifyLinkToPasteboardButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.spotifyLinkToPasteboardButton?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.appleMusicLinkToPasteboardButton?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.appleMusicLinkToPasteboardButton?.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.spotifyLinkToPasteboardButton?.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -paddingBottomInView).isActive = true
        self.appleMusicLinkToPasteboardButton?.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -paddingBottomInView).isActive = true
        
        self.spotifyLinkToPasteboardButton?.rightAnchor.constraint(equalTo: margin.centerXAnchor, constant: -distanceBetweenButtons).isActive = true
        self.appleMusicLinkToPasteboardButton?.leftAnchor.constraint(equalTo: margin.centerXAnchor, constant: distanceBetweenButtons).isActive = true
    }
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: configureFlowLayout())
        collectionView.register(HistoryViewCollectionCell.self, forCellWithReuseIdentifier: String(describing: HistoryViewCollectionCell.self))
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView = collectionView
    }
    func configureFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        let itemWidth = self.view.frame.size.width/3
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = .init(top: 50, left: 0, bottom: 0, right: 0)
        return flowLayout
    }
    // MARK: - Actions -
    func showOverlayView() {
        
        self.overlayView?.layer.opacity = 0.0
        self.overlayView?.isHidden = false
        UIView.animate(withDuration: 0.2, animations: {
            self.overlayView!.layer.opacity = 1.0
        }) { (Bool) in
            self.showOrHideImageViewButtonsLabels(true)
        }
    }
    func hideOverlayView() {
        showOrHideImageViewButtonsLabels(false)
        UIView.animate(withDuration: 0.3, animations: { 
              self.overlayView?.layer.opacity = 0.0
        }) { (Bool) in
                self.overlayView?.isHidden = true
        }
    }
    func showOrHideImageViewButtonsLabels(_ flag: Bool) {
        let hidden: Bool = !flag
        self.imageView?.isHidden = hidden
        self.titleLabel?.isHidden = hidden
        self.artistLabel?.isHidden = hidden
        self.appleMusicLinkToPasteboardButton?.isHidden = hidden
        self.spotifyLinkToPasteboardButton?.isHidden = hidden
    }
    @objc func dissmiss() {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: - Set song - 
    func setSongInfo(title: String, artist: String, image: UIImage, spotifyLink: String, appleLink: String, spotifyUri: String, appleUri: String) {
        self.appleMusicLink = appleLink
        self.spotifyLink = spotifyLink
        self.imageView?.image = image
        self.titleLabel?.text = title
        self.artistLabel?.text = artist
        self.spotifyUri = spotifyUri
        self.appleUri = appleUri
    }
    
    func clearSongInfo() {
        self.artistLabel?.text = ""
        self.titleLabel?.text = ""
        self.imageView?.image = nil
        self.appleMusicLink = ""
        self.spotifyLink = ""
        self.spotifyUri = ""
        self.appleUri = ""
    }
    
    
}
