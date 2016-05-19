//
//  AppDelegate.swift
//  yn
//
//  Created by Aurelien Prieur on 28/04/16.
//  Copyright © 2016 Aurelien Prieur. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let remoteNotificationHandler = RemoteNotificationHandler.sharedInstance

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //TODO: Remove, DEV ONLY !
        //application.unregisterForRemoteNotifications()
        
        let storyboard = UIStoryboard(name: "AuthStoryboard", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        
        window!.rootViewController = navigationController
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        let _ = FBSDKLoginButton()
    
        if launchOptions != nil {
            if let notification = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] {
                print("Notification: \(notification)")
            }
        }
        
        
        // Add any custom logic here.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        return handled
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("didRegisterForRemoveNotification. DeviceToken: \(deviceToken)")
        do {
            try remoteNotificationHandler.registerDevice(deviceToken.hexString)
            print(deviceToken.hexString)
        } catch let error as RemoteNotificationError {
            print("Error while registering device: \(error)")
        } catch let error {
            print("An unexpected error occured: \(error)")
        }
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register for remote notification. Error: \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Notification received")
        remoteNotificationHandler.handleRemoteNotification(userInfo as! Dictionary<String, AnyObject>, appState: application.applicationState)
        completionHandler(UIBackgroundFetchResult.NewData)
    }
}

