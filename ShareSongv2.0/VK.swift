//
//  VK.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 27.11.17.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

//import Foundation
//
//class VK : NSObject {
//    
//    static func parseToDict() -> [[String: Any]] {
//        // TODO: emplty line
//        let file = VK.getStringFromFile("songs")
//        let array = file.split(separator: "\n")
//
//        var counter = 0
//        
//        var array1 = [[String:Any]]()
//        var dictionary = [String: Any]()
//        
//        for let str in array {
//            if counter % 2 == 0 {
//                dictionary["title"] = String(str)
//                
//                counter += 1
//            } else {
//                dictionary["artist"] = String(str)
//                counter += 1
//                
//                array1.append(dictionary)
//            }
//        }
//        return array1
//    }
//    
//    static func getStringFromFile(_ name: String) -> String {
//        if let path = Bundle.main.path(forResource: name, ofType: "txt") {
//            let fm = FileManager()
//            let exists = fm.fileExists(atPath: path)
//            if(exists){
//                let c = fm.contents(atPath: path)
//                let cString = NSString(data: c!, encoding: String.Encoding.utf8.rawValue)
//                let ret = cString! as String
//                return ret
//            }
//        }
//        return ""
//    }
//
//}
//
