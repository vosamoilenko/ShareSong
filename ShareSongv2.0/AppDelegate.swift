//
//  AppDelegate.swift
//  ShareSongv2.0
//
//  Created by Vo1 on 09/08/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "autoSearch") == nil {
            userDefaults.set(false, forKey: "autoSearch")
        }
        return true
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "autoSearch")))
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        if !SMKSongStore.sharedStore.saveChanges() {
            fatalError("not saved")
        }
    }
}
