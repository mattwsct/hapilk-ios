//
//  AppDelegate.swift
//  Kenko
//
//  Created by David Garcia Tort on 6/17/19.
//  Copyright © 2019 Innovatech Studio Co., LTD. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // IQKeyboardManager init
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 200
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // Background Fetch Interval
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // Firebase
        FirebaseApp.configure()
        
        // Firebase Notifications
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // Check authentication
        if UserDefaults.standard.object(forKey: "userToken") != nil {
            if UserDefaults.standard.object(forKey: "showOnboarding") != nil {
                let onboarding = UIStoryboard(name: "Onboarding", bundle: nil).instantiateInitialViewController()
                self.window?.rootViewController = onboarding
            } else {
                let navigation = UIStoryboard(name: "Navigation", bundle: nil).instantiateInitialViewController()
                self.window?.rootViewController = navigation
            }
        }
        
        // Check version
        if let version = VersionService.checkVersion() {
            let alertController = UIAlertController(title: "バージョン", message: "新しいバージョン\(version)がリリースされました", preferredStyle: .alert)
            let installButton = UIAlertAction(title: "インストール", style: .default, handler: { alert in
                let downloadAddress = "\(Environment.value(for: .hapilkWeb))/download"
                let url = URL(string: downloadAddress)!
                application.open(url, options: [:], completionHandler: nil)
            })
            let cancelButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(installButton)
            alertController.addAction(cancelButton)
            
            DispatchQueue.main.async {
                self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
            }
        }
        
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
        let cache = ImageCache.default
        cache.cleanExpiredMemoryCache()
        cache.cleanExpiredDiskCache()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
        
        // Further handling of the device token if needed by the app
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        // This notification is not auth related, developer should handle it.
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(.newData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        // URL not auth related, developer should handle it.
        return false
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Background health data synchronization
        // Get HealthKit Data
        HealthService.getHealthData(of: [.steps, .calories], for: [Date()], withCompletion: { healthData in
            if healthData.isEmpty {
                Network.request(
                    target: .updateUserHealthData(healthData: healthData),
                    success: { response in
                        completionHandler(.newData)
                    }, error: { error in
                        completionHandler(.failed)
                    }, failure: { error in
                        completionHandler(.failed)
                    })
            } else {
                completionHandler(.noData)
            }
        })
    }
    
}

extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
