//
//  SMKSong.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 12/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SMKSong: NSObject, NSCoding {
    //MARK: - Properties -
    var title: String?
    var artist: String?
    var album: String?
    var spotifyLink: String?
    var appleLink: String?
    var imageLink: String?
    var image: UIImage?
    var spotifyUri: String?
    var appleUri: String?
    //MARK: - Initializer -
    init(title: String, artist: String, album: String, imageLink: String, spotifyLink: String, appleLink: String, image: UIImage, spotifyUri: String?, appleUri: String?) {
        super.init()
        self.title = title
        self.artist = artist
        self.album = album
        self.imageLink = imageLink
        self.spotifyLink = spotifyLink
        self.appleLink = appleLink
        self.image = image
        self.spotifyUri = spotifyUri ?? ""
        self.appleUri = appleUri ?? ""
    }
    //MARK: - Decoding/Encoding -
    required convenience init?(coder aDecoder: NSCoder) {
        guard let song = aDecoder.decodeObject(forKey: "song") as? [String:Any?],
            let title = song["title"] as? String,
            let artist = song["artist"] as? String,
            let album = song["album"] as? String,
            let imageLink = song["imageLink"] as? String,
            let spotifyLink = song["spotifyLink"] as? String,
            let appleLink = song["appleLink"] as? String,
            let image = song["image"] as? UIImage,
            let appleUri = song["appleUri"] as? String,
            let spotifyUri = song["spotifyUri"] as? String else {
            os_log("Unable to decode the song.", log: OSLog.default, type: .debug)
            fatalError("required init?(coder aDecoder: NSCoder)")
        }
        self.init(title: title, artist: artist, album: album, imageLink: imageLink, spotifyLink: spotifyLink, appleLink: appleLink, image: image, spotifyUri: spotifyUri, appleUri: appleUri)
        
    }
    func encode(with aCoder: NSCoder) {
        guard let title = self.title,
            let artist = self.artist,
            let album = self.album,
            let imageLink = self.imageLink,
            let spotifyLink = self.spotifyLink,
            let appleLink = self.appleLink,
            let image = self.image,
            let appleUri = self.appleUri,
            let spotifyUri = self.spotifyUri else {
            fatalError("func encode(with aCoder: NSCoder)")
        }
        let song: [String: Any] = ["title": title,
                                      "artist": artist,
                                      "album": album,
                                      "imageLink": imageLink,
                                      "spotifyLink": spotifyLink,
                                      "appleLink": appleLink,
                                      "image": image,
                                      "spotifyUri": spotifyUri,
                                      "appleUri": appleUri
                                    ];
        aCoder.encode(song, forKey: "song")
    }
}
