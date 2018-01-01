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
    
    var dissmissButton: UIButton?
    var parentVC: ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        configureUI()
        configuewSwipeRecognizer()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.saveBackgroundImage() {
            self.parentVC?.backgroundImageView.image = self.captureScreen()
        }
    }
}

extension HistoryCollectionViewController {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
          return SMKTransitionAnimatorBack()
    }
}

extension HistoryCollectionViewController: UIViewControllerTransitioningDelegate {
    @objc func dissmiss() {
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        self.dismiss(animated: true, completion: nil)
    }
    func captureScreen() -> UIImage? {
        guard let layer = UIApplication.shared.keyWindow?.layer else { return .none }
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return .none}
        layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return .none }
        UIGraphicsEndImageContext()
        
        return image
    }
    func saveBackgroundImage() -> Bool {
        return NSKeyedArchiver.archiveRootObject(self.captureScreen()!, toFile: archivePath())
    }
    func archivePath() -> String {
        let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archieveUrl = documentDirectory.appendingPathComponent("backgroundImage")
        return archieveUrl.path
    }

}
extension HistoryCollectionViewController {

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
    func configureUI() {
        confgureBackgroundColor()
        configureDissmissButton()
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
    
    func configuewSwipeRecognizer() {
        let x = UISwipeGestureRecognizer.init()
        x.direction = .down
        x.addTarget(self, action: #selector(dissmiss))
        self.view.addGestureRecognizer(x)
    }
}
extension HistoryCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SMKSongStore.sharedStore.count()
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HistoryViewCollectionCell.self), for: indexPath) as! HistoryViewCollectionCell
        guard let image = SMKSongStore.sharedStore.songAt(index: indexPath.item).image else {
            fatalError("no song for index")
        }
        cell.fillData(image: image)
        
        
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let song = SMKSongStore.sharedStore.songAt(index: indexPath.item)
        
        let vc = SongViewController()
        vc.set(song)
        vc.backgroundImageView.image = captureScreen()
        present(vc,animated: true,completion: nil)
    }
}

