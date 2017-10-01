//
//  SMKSongStore.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 12/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import UIKit
import os.log

// TODO: add spotify URI and apple URI
class SMKSongStore {
    //MARK: - Propperties -
    var store: [SMKSong]
    //MARK: - Singeltone -
    static let sharedStore = SMKSongStore()
    
    private init() {
    //FIX: Why?
        
        let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archieveUrl = documentDirectory.appendingPathComponent("song")
        
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: archieveUrl.path) as? [SMKSong] {
            self.store = data
        } else {
            self.store = [SMKSong]()
        }
    }
    
    //MARK: - Internal methods -
    func songAt(index: Int) -> SMKSong {
        return self.store[index]
    }
    func count() -> Int {
        return store.count
    }
    func isMember(link: String) -> Bool {
        // FIX: rewrite checking by id or name
        for song in store {
            
            guard let spotifyLink = song.spotifyLink, let appleLink = song.appleLink else {
                continue
            }
            if spotifyLink.contains(link) || appleLink.contains(link) {
                return true
            }
        }
        return false
    }
    func addSong(dict: [String:String]) {
        guard let title = dict["title"],
            let artist = dict["artist"],
            let album = dict["album"],
            let imageLink = dict["imageLink"],
            let spotifyLink = dict["spotifyLink"],
            let appleLink = dict["appleLink"],
            let appleUri = dict["appleUri"],
            let spotifyUri = dict["spotifyUri"] else {
                fatalError("addSong")
        }
        
        let url = URL.init(string: imageLink)
        var image: UIImage?
        do {
            image = try UIImage.init(data: Data.init(contentsOf: url!))
        } catch {
            image = UIImage.init(named: "logo")
        }

        let song = SMKSong.init(title: title,
                                artist: artist,
                                album: album,
                                imageLink: imageLink,
                                spotifyLink: spotifyLink,
                                appleLink: appleLink,
                                image: image!,
                                spotifyUri: spotifyUri,
                                appleUri: appleUri)
        if count() >= 50 {
            self.store.remove(at: count())
        }
        store.insert(song, at: 0)
    }
    func songByLink(link: String) -> SMKSong? {
        for song in store {
            guard let spotifyLink = song.spotifyLink, let appleLink = song.appleLink else {
                continue
            }
            if spotifyLink.contains(link) || appleLink.contains(link) {
                return song
            }
        }
        return nil
    }
    
    //MARK: - Archiving object -
    func saveChanges() -> Bool {
        return NSKeyedArchiver.archiveRootObject(store, toFile: archivePath())
    }
    func loadSongs() {
        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: archivePath()) as? [SMKSong] {
            self.store = data
        } else {
            self.store = [SMKSong]()
        }
        
    }
    func archivePath() -> String {
        let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let archieveUrl = documentDirectory.appendingPathComponent("song")
        return archieveUrl.path
    }
    // test
    func clearStore() {
        self.store.removeAll()
    }
    
}
