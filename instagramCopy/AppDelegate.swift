//
//  AppDelegate.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/04/30.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    FirebaseApp.configure()
    
    window = UIWindow()
    window?.rootViewController = MainTabVC()
    
    attempToRegisterForNotifications(application: application)
    
    return true
  }
  
  func attempToRegisterForNotifications(application: UIApplication) {
    
    Messaging.messaging().delegate = self
    
    UNUserNotificationCenter.current().delegate = self
    
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    
    UNUserNotificationCenter.current().requestAuthorization(options: options) { (authorized, error) in
      if authorized {
        print("DEBUG: Successfully Registered for Notification")
      }
    }
    
    application.registerForRemoteNotifications()
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("DEBUG: Registered for Notification with Deivece Toekn", deviceToken)
  }
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("DEBUG: Registered with FOM Token: ",fcmToken)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler(.alert)
  }
}

