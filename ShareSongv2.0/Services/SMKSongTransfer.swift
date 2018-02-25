//
//  SMKSongTransfer.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 15/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

class SMKSongTransfer : NSObject, MPMediaPickerControllerDelegate {
    
    var storefrontIdentifier: String
    var tokenInfo: [String:Any]

    static let sharedTransfer = SMKSongTransfer()
    private override init() {
        self.tokenInfo = [String:Any]()
        self.storefrontIdentifier = String()
    }
    func transfer(link: String, completion: @escaping ([String:Any]?) -> Void, failure: @escaping ([String:Any]?) -> Void) {
        if SpotifySearch.isSpotify(link: link) {
            spotifyToApple(link: link, completion: completion, failure: failure)
        } else {
            appleToSpotify(link: link, completion: completion, failure: failure)
        }
    }
    func spotifyToApple(link: String, completion: @escaping ([String:Any]?) -> Void, failure: @escaping ([String:Any]?) -> Void) {
        let trackIdentifier = SpotifySearch.trackIdentefier(link: link)
        SpotifySearch.songInfo(trackIdentifier: trackIdentifier, tokenInfo: self.tokenInfo) { (result, success, error) in
            if result == nil  {
                failure(nil)
                return
            }
            
            AppleMusicSearch.search(info: result!, storefrontIdentifier: self.storefrontIdentifier, repeatCounter: 0, completion: { (song, success, error) in
                guard error == nil, song != nil else {
                    print("Error class func spotifyToApple")
                    failure(song)
                    return
                }
                if success {
                    completion(song)
                } else {
                    failure(nil)
                    return
                }
            })
        }
    }
    func appleToSpotify(link: String, completion: @escaping ([String:Any]?) -> Void, failure: @escaping ([String:Any]?) -> Void) {
        
        AppleMusicSearch.songInfo(link: link) { (result, success, error) in
            if result == nil  {
                failure(nil)
                return
            }
            SpotifySearch.search(info: result!, tokenInfo: self.tokenInfo, repeatCounter: 0, completion: { (song, success, error) in
                guard error == nil, song != nil else {
                    failure(nil)
                    return
                }
                if success {
                    completion(song)
                } else {
                    failure(nil)
                    return
                }
            })
        }
    }
    func fetchStorefront() -> Void {
        let serviceController = SKCloudServiceController()
        MPMediaLibrary.requestAuthorization { (status) in
            print("Status: \(status)")
            if status == MPMediaLibraryAuthorizationStatus.authorized || status == MPMediaLibraryAuthorizationStatus.restricted {
                    serviceController.requestStorefrontIdentifier(completionHandler: { (storefrontIdentifier, error) in
                        guard error == nil, storefrontIdentifier != nil else {
                            fatalError("class func fetchStorefront()")
                        }
                        self.storefrontIdentifier = AppleMusicSearch.getStorefrontFrom(response: storefrontIdentifier!)
                    })
            } else {
                self.fetchStorefront()
                return
            }
        }
    }
    
    class func isProperLink(link: String) -> Bool {
        if AppleMusicSearch.isAppleMusic(link: link) || SpotifySearch.isSpotify(link: link) {
            return true
        }
        return false
    }
    func countryCode(identifier: String) -> String {
        
        guard let url = Bundle.main.url(forResource: "StorefrontCountries", withExtension: "plist"),
            let dict = NSDictionary.init(contentsOf: url),
            let countryCode = dict.object(forKey: identifier) as? String
            else {
                fatalError("class func countryCode")
        }
        return countryCode
    }
}
