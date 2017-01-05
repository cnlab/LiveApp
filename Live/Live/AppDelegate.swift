//
//  AppDelegate.swift
//  Live
//
//  Created by Denis Bohm on 9/9/16.
//  Copyright © 2016 Firefly Design LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Skip normal application startup when running unit tests. -denis
        if NSClassFromString("XCTestCase") != nil {
            return true
        }

        let liveManager = LiveManager.shared
        if !liveManager.unarchive() {
            liveManager.archive()
        }
        liveManager.activate()

        if let launchOptions = launchOptions {
            NSLog("for pre-iOS 10")
            if let notification = launchOptions[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
                NSLog("\(notification.userInfo)")
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        // called with results from registerUserNotificationSettings request
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Swift.Void) {
        NSLog("for pre-iOS 10")
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NSLog("for pre-iOS 10")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        LiveManager.shared.archive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        LiveManager.shared.archive()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

        LiveManager.shared.refresh()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

        LiveManager.shared.archive()
    }

}

