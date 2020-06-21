//
//  AppDelegate.swift
//  instagramCopy
//
//  Created by 김광수 on 2020/04/30.
//  Copyright © 2020 김광수. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        window = UIWindow()
        window?.rootViewController = MainTabVC()
    
        return true
    }
}

