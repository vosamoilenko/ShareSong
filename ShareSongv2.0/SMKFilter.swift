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



class JWDistance {
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
    
    class func distance(first: String, second: String) -> Double {
        
        if (first.isEmpty || second.isEmpty) {
            //exception? string shouldn't be empty
            // fisrt and second are not optionals, no exceptions because of nil ;)
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
        
        // to lower register
        mins = mins.lowercased()
        maxs = maxs.lowercased()
        
        
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
    
}

class Holder {
    var song: [String:Any]
    var distance: Array<Double>
    
    init(_ song:[String:Any],_ pred:[String:Any] ) {
        self.song = song
        self.distance = Array.init()
        self.fillDistance(pred: pred)
    }
    func fillDistance(pred:[String:Any]) {
        // title, artist, album
        for (key, value) in pred {
            guard var str1 = value as? String,var str2 = song[key] as? String else { fatalError("nil") }
            str1 = str1.clean()
            str2 = str2.clean()
            
            self.distance.append(JWDistance.distance(first: str1, second: str2))
        }
    }
    func sum() -> Double {
        return distance[0] + distance[1]
    }
    func sumFull() -> Double {
        return distance[0] + distance[1] + distance[2]
    }
    var description: String {
        var x : String = "\(distance[0]) \(distance[1]) \(distance[2])\n"
        x += "\(song["title"]!) \(song["artist"]!) \(song["album"]!)"
        return x
    }
}

class SMKFilter {
    class func filter(pred: [String: Any], songs: [[String: Any]]) -> [[String: Any]]? {

        var sorted: Array<Holder>?
        var holders = Array<Holder>()
        let filtred: [[String:Any]]?
        
        for song in songs {
            holders.append(Holder.init(song, pred))
        }
        
        sorted = holders.sorted(by: { (a, b) -> Bool in
            return a.sumFull() > b.sumFull()
        })

        guard sorted != nil else { fatalError("nil") }
        
        filtred = SMKFilter.extract(from: sorted!, by: [2.9, 2.4])
        return filtred
    }
    
    static func extract(from holders: Array<Holder>, by limits: Array<Double>) -> [[String:Any]]? {
        var extracted = [[String:Any]]()
        var buffer = Array<Holder>()
        
        
        for limit in limits {
            
            for holder in holders {
                if holder.sumFull() >= limit {
                    buffer.append(holder)
                }
            }
            
            if buffer.count == 1 {
                extracted.append(buffer[0].song)
                return extracted
            }
            
            if buffer.count >= 1 {
                for holder in buffer {
                    extracted.append(holder.song)
                }
                return extracted
            }
        }
        return nil
    }
}


