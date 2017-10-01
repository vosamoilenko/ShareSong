//
//  SpotifySearch.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 13/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation
import os.log

let kSpotifYURLSearchWithTrackID: String = "https://api.spotify.com/v1/tracks/"
let kSpotifYURLSearchWithTemp: String = "https://api.spotify.com/v1/search?"
let maxRepeatSearchCount = 3
let onlyValidBearerAuthenticationSupported = 400


class SpotifySearch  {
    struct Client {
        let id: String = "785d0dd3031a4594895b8e72ba83548a"
        let secret: String = "23ed8ea00a54403baabed39b408fcce8"
    }
    class func search(info: [String: Any], tokenInfo: [String:Any], repeatCounter: Int, completion: @escaping ([String:Any]?, Bool, Error?) -> Void) {
        guard let artist = info["artist"] as? String,
            let title = info["title"] as? String else {
                fatalError("class func search")
        }
        
        let encodeArtist = artist.clean().lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let encodeTitle = title.clean().lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        var requestString = String()
        
        switch repeatCounter {
        case 0:
            requestString = kSpotifYURLSearchWithTemp + "q=" + encodeTitle! + "+" + encodeArtist! + "&type=track&limit=50"
        case 1:
            requestString = kSpotifYURLSearchWithTemp + "q=" + encodeTitle! + "&type=track&limit=50"
        case 2:
            let encodeTitleBeforeParenthesis = title.beforeParenthesis().clean().lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            requestString = kSpotifYURLSearchWithTemp + "q=" + encodeTitleBeforeParenthesis! + "&type=track&limit=50"
        default:
            return completion(nil, false, nil)
        }
        
        let url = URL.init(string: requestString)
        let request = configureRequest(url: url, tokenInfo: tokenInfo)
        
        let session = URLSession.init(configuration: .default)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil, data != nil else {
                fatalError("class func search")
            }
            
            let json = try! JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
            guard json != nil else {
                fatalError("session.dataTask")
            }
            
            if isNeedToUpdateToken(tokenInfo: json) {
                updateToken(response: json, completion: { (token) in
                    search(info: info, tokenInfo: token, repeatCounter: 0, completion: completion)
                })
                return
            }
            
            if let length = (json?["tracks"] as? [String:Any])?["total"] as? Int,
                length == 0 {
                search(info: info, tokenInfo: tokenInfo, repeatCounter: repeatCounter+1, completion:completion)
                return
            }
            
            guard let filtred = SMKFilter.filter(pred: info, songs: parseJSON(json: json!)) else {
                completion(nil, false, nil)
                return
            }
            
            if filtred.count != 0 {
                completion(filtred.first!, true, nil)
            } else {
                completion(nil, false, nil)
            }
            
        }.resume()
    }
    class func configureSongByJSONFromTrackID(json: [String:Any]) -> [String:Any] {
        guard let title = json["name"] as? String,
        let artists = json["artists"] as? [Any],
        let artistNames = artists[0] as? [String:Any],
        let artist = artistNames["name"] as? String,
        let albumsNames = json["album"] as? [String:Any],
        let album = albumsNames["name"] as? String,
        let uri = json["uri"] as? String else {
            fatalError("configureSongByJSONFromTrackID")
        }
        return ["title": title.replacingOccurrences(of: " ", with: "+"),
                "artist": artist.replacingOccurrences(of: " ", with: "+"),
                "album":  album.replacingOccurrences(of: " ", with: "+"),
                "spotifyUri": uri]
    }
    class func songInfo(trackIdentifier: String, tokenInfo: [String:Any], completion: @escaping ([String:Any]?,Bool,Error?) -> Void) {
        if tokenInfo.count == 0 {
            getToken(completion: { (token) in
                songInfo(trackIdentifier: trackIdentifier, tokenInfo: token, completion: completion)
            })
            return
        }
        let spotifyURL = kSpotifYURLSearchWithTrackID
        guard let url = URL.init(string: spotifyURL + trackIdentifier) else {
            fatalError("class func searchBy")
        }
        
        let session = URLSession.init(configuration: .default)
        let request = configureRequest(url: url, tokenInfo: tokenInfo)
        
        session.dataTask(with: request) { (data, respone, error) in
            guard error == nil, data != nil else {
                fatalError("class func searchBy")
            }
            let json = try? JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            
            // if token is empty we are calling
            guard json != nil else {
                fatalError("session.dataTask")
            }
            
            if isNeedToUpdateToken(tokenInfo: json) {
                updateToken(response: json!, completion: { (token) in
                    songInfo(trackIdentifier: trackIdentifier, tokenInfo: token, completion: completion)
                })
                return
            }
            
            // parse json to needed view
            let song = SpotifySearch.configureSongByJSONFromTrackID(json: json!)
            
            completion(song,true,nil)
            
            
        }.resume()
    }
    
    
    class func isNeedToUpdateToken(tokenInfo: [String:Any]?) -> Bool {
        guard tokenInfo != nil else {  
            fatalError("class func updateToken")
        }
        if tokenInfo?["error"] != nil {
            return true
        }
        return false
    }
    class func updateToken(response: [String:Any]?, completion: @escaping ([String:Any])->Void) {
        guard response != nil else {
            fatalError("class func updateToken")
        }
        if let tokenError = response?["error"] as? [String:Any] {
            if tokenError["status"] as! Int == onlyValidBearerAuthenticationSupported {
                getToken(completion: { (token) in
                    completion(token)
                })
            }
        } else {
            return
        }
    }
    class func configureFilterPredicate(repeatCounter: Int, info: [String: Any]) -> [String:Any] {
        switch repeatCounter {
        case 0:
            return info
        case 1:
            return ["title": info["title"]!]
        default:
            let titleWithoutParenthesis = (info["title"] as? String)!.beforeParenthesis()
            return ["title": titleWithoutParenthesis]
        }
    }
    class func configureRequest(url: URL?, tokenInfo: [String:Any]?) -> URLRequest {
        guard let url = url,
            let tokenInfo = tokenInfo else {
            fatalError("class func configureRequest")
        }
        let accessToken = tokenInfo["access_token"] ?? ""
        let tokenType = tokenInfo["token_type"] ?? ""
        let header = (tokenType as? String)! + " " + (accessToken  as? String)!
        
        var request = URLRequest.init(url: url)
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        return request;
    }
    class func getToken(completion: @escaping (([String:Any]) -> Void) ) {
        let body = "grant_type=client_credentials"
        let postData = body.data(using: .utf8)
//        let postData = body.data(using: .ascii, allowLossyConversion: true)
        
        let client = Client()
        let clientData: String = client.id + ":" + client.secret
        let data = clientData.data(using: .utf8)
        let base64 = data?.base64EncodedString()
        
        guard base64 != nil else {
            fatalError("base64")
        }

        let header = "Basic " + base64!
        
        let url = URL.init(string: "https://accounts.spotify.com/api/token")
        var request = URLRequest.init(url: url!)
        request.httpBody = postData
        request.httpMethod = "POST"
        request.setValue(header, forHTTPHeaderField: "Authorization")
        
        let session: URLSession = URLSession.init(configuration: .default)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data,response,error) in
            
            if error != nil {
                
                
                fatalError("class func getToken")
            } else {
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    guard let token = json else {
                        fatalError("guard let token = json")
                    }
                    completion(token!)
                }
            }
        }
        task.resume()
    }
    
    class func parseJSON(json: [String: Any]) -> [[String:Any]] {
        
        var finishArray : [[String:Any]] = Array()
        
        if let songs = (json["tracks"] as? [String:Any])?["items"] as? [[String: Any]] {
            for song in songs {
                //TODO:  save uri to open song in the app!!
                guard let info = song["album"] as? [String:Any],
                    let title = song["name"] as? String,
                    let album = info["name"] as? String,
                    let artist = ((info["artists"] as? [Any])?[0] as? [String:Any])?["name"] as? String,
                    let url = (song["external_urls"] as? [String:Any])?["spotify"] as? String,
                    let spotifyUri = song["uri"] as? String,
                    let imageLink = ((info["images"] as? [Any])?[0] as? [String: Any])?["url"] as? String
                    else {
                        fatalError("class func parseJSON")
                }
                
                let item : [String:Any] = [
                    "title": title,
                    "artist": artist,
                    "url": url,
                    "imageLink": imageLink,
                    "album": album,
                    "spotifyUri": spotifyUri
                ]
                finishArray.append(item)
            }
        } else {
        
        }
        return finishArray
    }

    class func isSpotify(link: String) -> Bool {
        if link.contains("https://open.spotify.com/") { return true }; return false
    }
    class func trackIdentefier(link: String) -> String {
        let url = "https://open.spotify.com/track/"
        let length = url.characters.count
        let index = link.index(link.startIndex, offsetBy:length)
//        return link.substring(from: index)
        return String(link.suffix(from: index))
    }

}
