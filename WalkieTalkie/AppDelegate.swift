//
//  AppDelegate.swift
//  WalkieTalkie
//
//  Created by Ярослав Косарев on 11.11.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        let nc = UINavigationController(rootViewController: StartVC())
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        return true
    }
}

