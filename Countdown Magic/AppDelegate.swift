//
//  AppDelegate.swift
//  Countdown Magic
//
//  Created by George Potosky 2019.
//  GeozWorld Enterprises (tm). All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //-Text Phrase for Flickr API search
    var phraseText: String!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //-Check if its first time running the app
        //-If its the first time running, clear all notifications before starting new notifications
        if !(UserDefaults.standard.object(forKey: "is_first_time") != nil) {
            application.cancelAllLocalNotifications()
            // Restart the Local Notifications list
            UserDefaults.standard.set(Int(truncating: true), forKey: "is_first_time")
            
            //-Add Splash screen delay
            Thread.sleep(forTimeInterval: 2)
            
            //-Notification settings
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: .badge, categories: nil))
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: .sound, categories: nil))
            return true
            
        } else {
        
        //-Add Splash screen delay
        Thread.sleep(forTimeInterval: 2)
        
        //-Notification settings
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: .badge, categories: nil))
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: .sound, categories: nil))
        
        return true
        }
        
        
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }


}

