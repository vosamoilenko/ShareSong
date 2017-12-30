//
//  SMKFilter.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 15/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

//TO DO:
//- JWAlgorithm - to return double value of similarity - DONE
//- check data on definite match. yes - return. no:
//- function to receive JWA-values for all values in songs, display x most similar

import Foundation

class SMKFilter {
    class func filter(pred: [String: Any], songs: [[String: Any]]) -> [[String: Any]]? {
//        print(JWDistance(first: "", second:""))             // = 0.0
//        print(JWDistance(first: "",second:"a"))            //  = 0.0
//        print(JWDistance(first: "aaapppp", second:""))   //    = 0.0
//        print(JWDistance(first: "frog", second:"fog"))     //  = 0.93
//        print(JWDistance(first: "fly", second:"ant"))    //    = 0.0
//        print(JWDistance(first: "elephant",second: "hippo")) //= 0.44
//        print(JWDistance(first: "hippo", second:"elephant"))// = 0.44
//        print(JWDistance(first: "hippo", second:"zzzzzzzz")) //= 0.0
//        print(JWDistance(first: "hello", second:"hallo"))  //  = 0.88
//        print(JWDistance(first: "ABC Corporation", second:"ABC Corp")) //= 0.93
//        print(JWDistance(first: "D N H Enterprises Inc", second:"D &amp; H Enterprises, Inc.")) //= 0.95
//        print(JWDistance(first: "My Gym Children's Fitness Center",second: "My Gym. Childrens Fitness"))// = 0.92
//        print(JWDistance(first: "PENNSYLVANIA",second: "PENNCISYLVNIA"))  //  = 0.88
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
    
    class func JWDistance(first: String, second: String) -> Double {
        if (first.isEmpty || second.isEmpty) {
            //exception? string shouldn't be empty
            return 0.0
        }
        
        var mins, maxs: String
        if (first.count > second.count) {
            mins = second
            maxs = first
        } else {
            mins = first
            maxs = second
        }
        let range = Int(max(maxs.count / 2 - 1, 0))
        var matchIndexes = Array(repeating: -1, count: mins.count)
        var matchFlags = Array(repeating: false, count: maxs.count)
        var matches = 0
        
        //finding the char matches within the range in the strings
        //memorizing the index of a char which has a match
        //memorizing that index has a match
        for (mi, c) in mins.enumerated() {
            var xi = max(mi - range, 0)
            let xn = min(mi + range + 1, maxs.count)
            while (xi < xn) {
                if (!matchFlags[xi] && c == maxs[xi]) {
                    matchIndexes[mi] = xi
                    matchFlags[xi] = true
                    matches += 1
                    xi += 1;
                    break;
                }
                xi += 1;
            }
        }

        var ms1 = [Character]()
        var ms2 = [Character]()
        //filling matches in min string
        for (i, mi) in matchIndexes.enumerated() {
            if (mi != -1) {
                ms1.append(mins[i])
            }
        }
        //filling matches in max string
        for (i, _) in maxs.enumerated() {
            if (matchFlags[i]) {
                ms2.append(maxs[i])
            }
        }
        //counting transpositions
        var transpositions = 0
        for (i, c) in ms1.enumerated() {
            if (c != ms2[i]) {
                transpositions += 1
            }
        }
        //counting prefix
        var prefix = 0
        for (i, _) in mins.enumerated() {
            if (first[i] == second[i]) {
                prefix += 1
            } else {
                break;
            }
        }
        
        //calculating the result
        if (matches == 0) {
            return 0.0
        }
        
        let md = Double(matches)
        let jaroValue = (md/Double(first.count) +
                                md/Double(second.count) +
                                (md - Double(transpositions))/md) / 3.0
        
        let scalingFactor = 0.1
        let threshold = 0.7
        let jaroWinklerValue = jaroValue < threshold ?
            jaroValue :
            jaroValue + min(scalingFactor, 1.0/Double(maxs.count) * Double(prefix) * (1.0 - jaroValue))
        
        return jaroWinklerValue
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
