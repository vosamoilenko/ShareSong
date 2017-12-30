//
//  SMKFilter.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 15/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved. lmao  big mum's programmer
//

import Foundation

class SMKFilter {
    class func filter(pred: [String: Any], songs: [[String: Any]]) -> [[String: Any]]? {

        var filtred : [[String:Any]]?
        
        let keys = ["artist","album","title"]
        
        for key in keys {
            if pred[key] != nil {
                
                let predicate = pred[key] as? String
                
                if filtred == nil {
                    filtred = songs
                }
                
                filtred = filterByMissing(pred: predicate!, key: key, songs: filtred!)
                
                if filtred == nil {
                    filtred = songs
                }
                
                filtred = filterByHits(pred: predicate!, key: key, songs: filtred!)
                
                if filtred == nil {
                    filtred = filterByNearly(pred: predicate!, key: key, songs: songs)
                } else if filtred?.count == 1 {
                    break
                }
            }
        }
        guard filtred != nil else {
            return nil
        }
        return filtred
    }
    class func filterByHits(pred: String, key: String, songs: [[String: Any]]) -> [[String: Any]]? {
        
        let base = pred.beforeParenthesis().clean()
        var grades = [Int]()
        var songsAfterFiltering : [[String: Any]] = Array()
        
        for song in songs {
            guard let str = song[key] as? String else {
                fatalError("class func filterByHits")
            }
            let components = str.clean().components(separatedBy: " ")
            
            var hits = 0
            
            for component in components {
                if base.contains(component) {
                    hits += 1
                }
            }
            grades.append(hits)
            
        }
        
        let maxHits = base.components(separatedBy: " ").count
        
        for counter in 0..<songs.count {
            if grades[counter] >= maxHits {
                songsAfterFiltering.append(songs[counter])
            }
        }
        if songsAfterFiltering.count > 0 {
            return songsAfterFiltering
        }
        return nil
    }
    class func filterByMissing(pred: String, key: String, songs: [[String: Any]]) -> [[String: Any]]? {
        let base = pred.clean()
        var grades = [Int]()
        var minMisses = 100;
        var songsAfterFiltering : [[String: Any]] = Array()
        
        for song in songs {
            
            guard let str = song[key] as? String else {
                fatalError("error: guard line:91")
            }

            let components = str.clean().components(separatedBy: " ")
            
            var misses = 0
            
            for component in components {
                if !base.contains(component) {
                    misses += 1
                }
            }
            if misses < minMisses {
                minMisses = misses
            }
            grades.append(misses)
        }
        
        for counter in 0..<songs.count {
            if grades[counter] == minMisses {
                songsAfterFiltering.append(songs[counter])
            }
        }
        
        if songsAfterFiltering.count != 0 {
            return songsAfterFiltering
        }
        return nil
    }
    class func filterByNearly(pred: String, key: String, songs: [[String: Any]]) -> [[String: Any]]? {
        let base = pred.clean() //
        var grades = [Int]() //

        for song in songs {
            guard let target = song[key] as? String else {
                fatalError("class func filterByNearly")
            }
            let str = target.clean()
            var hits = 0
            
            for counter in 0..<str.characters.count {
                if counter == base.characters.count {
                    break
                }
                if str[counter] == base[counter] {
                    hits += 1
                } else {
                    break
                }
            }
            grades.append(hits)
        }
        var nearly = 0
        
        for counter in 1..<grades.count {
            if grades[nearly] < grades[counter] {
                nearly = counter
            }
        }
        if nearly != 0 {
            return [songs[nearly]]
        }
        return nil
    }

    class func isEqual(one: [String: Any], to: [String: Any]) -> Bool {
        let title = "title"
        let artist = "artist"
        guard let titleOne = one[title] as? String,
        let titleTo = to[title] as? String,
        let artistOne = one[artist] as? String,
        let artistTo = to[artist] as? String else {
            fatalError("guard error line:163")
        }
        
        let commonOne = titleOne.clean().withoutWhitescapes() + artistOne.clean().withoutWhitescapes()
        let commonTo = titleTo.clean().withoutWhitescapes() + artistTo.clean().withoutWhitescapes()
        
        return commonOne == commonTo
    }
    
}
