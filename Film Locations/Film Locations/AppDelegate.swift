//
//  AppDelegate.swift
//  Film Locations
//
//  Created by Jessica Thrasher on 4/23/17.
//  Copyright © 2017 Codepath Spring17. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        let memoryCapacity = 0
        let diskCapacity = 500 * 1024 * 1024
        let cache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDataPath")
        URLCache.shared = cache
        
        GMSServices.provideAPIKey("AIzaSyDkh00P83RkVTjmA98hUI2iACj368aTeGI")
        GMSPlacesClient.provideAPIKey("AIzaSyDkh00P83RkVTjmA98hUI2iACj368aTeGI")
        
        /*
        // This code is needed to test the toggle button, but should be changed when the map and list screen will be integrated
        
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        
        vc1.view.backgroundColor = UIColor.red
        vc2.view.backgroundColor = UIColor.orange
        
        let menu = MenuViewController(nibName: "MenuViewController", bundle: nil)
        menu.firstViewController = vc1
        menu.secondViewController = vc2
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = menu
        window?.makeKeyAndVisible()
        */
        // test code ends here
        
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


}
