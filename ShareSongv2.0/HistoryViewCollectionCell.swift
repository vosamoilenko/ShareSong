//
//  HistoryViewCollectionCell.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 10/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation

import UIKit

class HistoryViewCollectionCell : UICollectionViewCell {
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView = UIImageView.init()
        
        guard let imageView = self.imageView else {
            print("override init frame: CGRect")
            return
        }
        
        self.addSubview(imageView)
        setConstrains()
    }
    func fillData(image: UIImage) {
        guard let imageView = self.imageView else {
                fatalError("filldata")
        }
        imageView.image = image
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("has not been implemented")
    }
    
    func setConstrains() {
        guard let imageView = self.imageView else {
                fatalError("func setConstrains")
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }
}
