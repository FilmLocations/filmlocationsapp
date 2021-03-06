//
//  AppDelegate.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/23/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import LyftSDK
import Fabric
import Crashlytics
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
                
        UILabel.appearance().defaultFont =  UIFont(name: "Apple SD Gothic Neo", size: 15)
                
        let memoryCapacity = 0
        let diskCapacity = 500 * 1024 * 1024
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDataPath")
        URLCache.shared = cache
        
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else {
            print("Keys file not found!")
            return false
        }
        
        let keys = NSDictionary(contentsOfFile: path)!
        
        let twitterConsumerKey = keys["TwitterConsumerKey"] as! String
        let twitterConsumerSecret = keys["TwitterConsumerSecret"] as! String
        
        TWTRTwitter.sharedInstance().start(withConsumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        
        let gmsServicesAPIKey = keys["GMSServicesAPIKey"] as! String
        let gmsPlacesClientAPIKey = keys["GMSPlacesClientAPIKey"] as! String
        
        GMSServices.provideAPIKey(gmsServicesAPIKey)
        GMSPlacesClient.provideAPIKey(gmsPlacesClientAPIKey)

        let lyftConfigToken = keys["LyftConfigToken"] as! String
        let lyftClientID = keys["LyftClientID"] as! String
        
        LyftConfiguration.developer = (token: lyftConfigToken, clientId: lyftClientID)
        
        UIApplication.shared.statusBarStyle = .lightContent

        Fabric.with([Answers.self, Crashlytics.self])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    }
}
