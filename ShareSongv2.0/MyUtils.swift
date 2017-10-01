//
//  MyUtils.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 15/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import Foundation

extension String {
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    func clean() -> String {
        let lowerCase = self.lowercased()
        let str = lowerCase.replacingOccurrences(of: "+", with: " ")
        
        let resultArray = NSMutableArray.init()
        let components = str.components(separatedBy: " ")
        
        for component in components {
            var word = component
            
            word = word.components(separatedBy: .symbols).joined()
            word = word.components(separatedBy: .punctuationCharacters).joined()
            word = word.components(separatedBy: .whitespaces).joined()
            
            if word != "" {
                resultArray.add(word)
            }
        }
        return resultArray.componentsJoined(by: " ")
    }
    func withoutWhitescapes() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    func beforeParenthesis() -> String {
        return self.components(separatedBy: "(").first!
    }
}

extension DispatchQueue {
    private static var onceTracker = [String]()
    
    public class func once(token: String, block: () -> Void ) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
}
