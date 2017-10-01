//
//  AppleMusicSearch.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 15/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation

fileprivate typealias Helpers = AppleMusicSearch

fileprivate let kAppleMusicSearchURL = "https://itunes.apple.com/search?"

class AppleMusicSearch {
    class func search(info: [String: Any], storefrontIdentifier: String, repeatCounter: Int, completion: @escaping ([String:Any]?, Bool, Error?) -> Void) {
        
        var infoForFilter = info
        
        infoForFilter.removeValue(forKey: "spotifyUri")
        
        guard let artist = info["artist"] as? String, let title = info["title"] as? String else {
            assertionFailure("error while unwrapping artist and title from incoming dictionary")
            // TODO: enum for errors and categotize errors
            completion(nil,false,nil)
            return
        }
        
        guard let encodeAtrist = encode(artist), let encodeTitle = encode(title) else {
            completion(nil,false,nil)
            return
        }
        
        let maybeRequestString: String?
        switch repeatCounter {
            case 0: maybeRequestString = buildRequestString(from: encodeTitle + "+" + encodeAtrist, storefrontIdentifier: storefrontIdentifier)
            case 1: maybeRequestString = buildRequestString(from: encodeTitle, storefrontIdentifier: storefrontIdentifier)
            case 2: maybeRequestString = buildRequestString(from: title.beforeParenthesis(), storefrontIdentifier: storefrontIdentifier)
            default: maybeRequestString = nil
        }
        
        guard let requestString = maybeRequestString, let url = URL(string: requestString) else {
            completion(nil, false, nil)
            return
        }
        
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: url) { (data, respone, error) in
            
            guard error == nil, data != nil else {
                assertionFailure("error != nil or data == nil")
                completion(nil,false,nil)
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any] else {
                print("error try?")
                completion(nil,false,nil)
                return
            }

            if let count = json["resultCount"] as? Int,
                count == 0 {
                search(info: info, storefrontIdentifier: storefrontIdentifier, repeatCounter: repeatCounter+1, completion: completion)
                return
            }
            
            guard let filtred = SMKFilter.filter(pred: infoForFilter, songs: parseJSON(json: json)) else {
                completion(nil, false, nil)
                return
            }

            
            if filtred.isEmpty {
                completion(nil, false, nil)
            } else {
                var song = filtred.first!
                song["spotifyUri"] = info["spotifyUri"]
                completion(song, true, nil)
            }
        }.resume()
    }

    class func storefrontIdentidierFromLink(link:String) -> String {
        return link.components(separatedBy: "/")[3]
    }
    class func songInfo(link: String, completion: @escaping ([String:Any]?, Bool, Error?) -> Void) {
        let trackIdentifier = AppleMusicSearch.trackIdentifier(link: link)
        let storefrontIdentifier = AppleMusicSearch.storefrontIdentidierFromLink(link: link)
        let url = configureLookupURL(trackIdentifier: trackIdentifier, storefrontIdentifier: storefrontIdentifier)
        let session = URLSession.init(configuration: .default)
        let request = URLRequest.init(url: url)
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil, data != nil else {
                fatalError("class func songInfo")
            }
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            
            guard json["resultCount"] as! Int != 0 else {
                fatalError("resultCount = 0")
            }
            
            completion(song(info: json), true, nil)
            }.resume()
        }
    class func song(info: [String:Any]) -> [String: Any] {
        guard let results = info["results"] as? [Any],
            let firstResult = results.first as? [String: Any],
            let title = firstResult["trackName"] as? String,
            let artist = firstResult["artistName"] as? String,
            let album = firstResult["collectionName"] as? String else {
                fatalError("class func song:")
        }

        return ["title": title, "artist": artist, "album": album]
    }
    class func configureFilterPredicate(repeatCounter: Int, info: [String: Any]) -> [String:Any] {
        let title = "title"
        switch repeatCounter {
        case 0:
            return info
        case 1:
            return [title: info[title]!]
        default:
            let titleWithoutParenthesis = (info["title"] as? String)!.beforeParenthesis()
            return [title: titleWithoutParenthesis]
        }
    }
    class func parseJSON(json: [String:Any]) -> [[String:Any]] {
        
        guard let songs = json["results"] as? [[String:Any]] else {
            fatalError("parseJSON:")
        }
        
        var finishArray : [[String: Any]] = Array()
        
        for song in songs {
            guard let imageLinkBadQuality = song["artworkUrl100"] as? String,
                let urlFull = song["trackViewUrl"] as? String,
                let title = song["trackName"] as? String,
                let artist = song["artistName"] as? String,
                let album = song["collectionName"] as? String else {
                    fatalError("get array with songs")
            }
            
            let imageLink = imageLinkBadQuality.replacingOccurrences(of: "100x100bb", with: "300x300bb")
            let componentsFromUrl = urlFull.components(separatedBy: "&")
            let url = componentsFromUrl[0]
            

            let dict: [String: String] = ["imageLink": imageLink,
                                          "url": url,
                                          "artist": artist,
                                          "title": title,
                                          "album": album,
                                          ]
            finishArray.append(dict)

        }
        return finishArray
    }
    class func isAppleMusic(link: String) -> Bool {
        let first = "https://itun."
        let second = "https://itunes."
        if link.contains(first) || link.contains(second) {
            return true
        }
        return false
    }
    class func configureLookupURL(trackIdentifier:String, storefrontIdentifier: String) -> URL {
        let base = "https://itunes.apple.com/"
        let requestString = base + storefrontIdentifier + "/lookup?id=" + trackIdentifier + "&entity=song"
        guard let url = URL.init(string: requestString) else {
            fatalError("class func configureLookupURL")
        }
        return url
    }
    class func trackIdentifier(link: String) -> String {
        
        var components = link.components(separatedBy: "=")
        var trackId = String()
        
        for counter in 0..<components.count {
            if components[counter].contains("?i") {
                trackId = components[counter+1]
            }
        }
        
        if trackId.contains("&") {
            components = trackId.components(separatedBy: "&")
            trackId = components.first!
        }
        
        if trackId == "" {
            fatalError("class func trackIdentifier")
        }
        
        return trackId
    }
    class func storefrontIdentidier(link: String) -> String {
        return link.components(separatedBy: "/")[3]
    }
    class func getStorefrontFrom(response: String) -> String {
        let countryCode = response.components(separatedBy: "-").first!
        guard let path = Bundle.main.path(forResource: "StorefrontCountries", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
            let storefront = plist[countryCode] as? String
        else {
                fatalError("getStorefrontFrom:")
        }
        return storefront
    }
}

fileprivate extension Helpers {
    class func encode(_ stringToEncode:String) -> String? {
        return stringToEncode.clean().lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
    class func buildRequestString(from encodedString: String, storefrontIdentifier: String) -> String {
        return kAppleMusicSearchURL + "term=" + encodedString + "&entity=song&s=" + storefrontIdentifier
    }
}
