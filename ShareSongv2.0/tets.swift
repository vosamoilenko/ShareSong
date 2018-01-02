////
//////
//////  tets.swift
//////  ShareSongv2.0
//////
//////  Created by Vo1 on 10/09/2017.
//////  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//////
//
//import Foundation
//
//struct Client {
//    let id: String = "785d0dd3031a4594895b8e72ba83548a"
//    let redirect: String = "tranferSpotify://callback"
//    let secret: String = "23ed8ea00a54403baabed39b408fcce8"
//}
//
//func oauth() {
//    let cl = Client.init()
//    let url = URL.init(string: "https://accounts.spotify.com/authorize/?client_id=" + cl.id + "&response_type=code&redirect_uri=" + cl.redirect + "&scope=playlist-modify-public%20playlist-modify-private")
//    let requent = URLRequest.init(url: url!)
//    let session = URLSession.init(configuration: .default)
//    session.dataTask(with: requent) { (data, response, error) in
//        guard error == nil, data != nil else {
//            fatalError("class func search")
//        }
//        print(error)
//        print(data)
//    }.resume()
//
//}
//
//func getSongs() {
//
//    let arr = VK.parseToDict()
//
//
//    print(arr[0])
////    for obj in arr {
//
//
//        SpotifySearch.search(info: arr[1], tokenInfo: [:], repeatCounter: 0, completion: { (result, success, error) in
//            if success {
//                print("YEAH")
//            } else {
//                print(";(")
//            }
//
//        })
////    }
//
//
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////
////import Foundation
////import MediaPlayer
////
/////// Put this two methods in SMKTransferingSong class
//////- (void)testGo:(NSUInteger )counter :(NSArray *)src;
//////+ (NSArray *)test;
/////// And call then them in ViewController in ViewDidLoad
//////NSArray *arr = [SMKTransferingSong test];
//////[[SMKTransferingSong sharedTransfer] testGo:210 :arr];
////
////
/////// Get a playlist on 500-600 songs from apple music
/////// https://itunes.apple.com/ua/playlist/los-favoritos/idpl.3ab18e69e695466198c1110935f2e3fa
/////// And prepare it to needed format
////
////var resultCounter: Int = 0
////
////func myTest(completion: (_ result: [[String:String]]) -> Void) {
////    let playlistQuery = MPMediaQuery.playlists()
////    let playlists = playlistQuery.collections
////
////    var test = [[String:String]]()
////    var myPlaylist: MPMediaPlaylist?
////
////
////    for playlist in playlists! {
////        if playlist.value(forProperty: MPMediaPlaylistPropertyName) as? String == "Los Favoritos" {
////            myPlaylist = playlist as? MPMediaPlaylist
////            break
////        }
////    }
////
////    guard let songs = myPlaylist?.items else {
////        return
////    }
////
////    for song in songs {
////        let title = song.value(forProperty: MPMediaItemPropertyTitle)
////        let artist = song.value(forProperty: MPMediaItemPropertyArtist)
////        let album = song.value(forProperty: MPMediaItemPropertyAlbumTitle)
////
////        let dict = ["title":title,
////                    "artist":artist,
////                    "album":album]
////
////        test.append(dict as! [String : String])
////    }
////
////    completion(test)
////}
////
/////// Test 500 songs for both music services
/////// about 5-10% misses
/////// < 5% cannot find track
/////// < 10% found another song
////
////func startTest(counter: Int, source: [[String:String]]) {
////
////    /// Test apple Music
////
////
//////        AppleMusicSearch.search(info: source[counter], storefrontIdentifier: SMKSongTransfer.sharedTransfer.storefrontIdentifier, repeatCounter: 0) { (result, success, error) in
//////            if success == true {
//////                resultCounter += 1
//////                print(counter)
//////            } else {
//////                print("Error with \(source[counter])")
//////            }
//////            if counter+1 == source.count {
//////                print("RESULT: \(resultCounter)/\(source.count))")
//////                return
//////            }
//////            startTest(counter: counter+1, source: source)
//////        }
////
////    /// Test spotify Music
////
////        SpotifySearch.search(info: source[counter], tokenInfo: SMKSongTransfer.sharedTransfer.tokenInfo, repeatCounter: 0, completion: { (result, success, error) in
////            if success == true {
////                resultCounter += 1
////            } else {
////                print("Error with \(source[counter])")
////            }
////            if counter+1 == source.count {
////                print("RESULT: \(resultCounter)/\(source.count))")
////                return
////            }
////            startTest(counter: counter+1, source: source)
////            print("RESULT: \(resultCounter)/\(source.count))")
////        })
////
////
////
////
////}
////
////
////
////// - (void)testGo:(NSUInteger )counter :(NSArray *)src {
//////if (counter == [src count]) {NSLog(@"SUC: %d/%lu", succ_counter, (unsigned long)[src count]);return;}
////
/////// Test Spotift
////

