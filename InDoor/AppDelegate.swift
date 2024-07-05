//
//  AppDelegate.swift
//  InDoor
//
//  Created by Sachko_AP on 10.06.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//       self.window = UIWindow(frame: UIScreen.main.bounds)
//       let nav1 = UINavigationController()
//       let mainView = NavigationVC()
//       nav1.viewControllers = [mainView]
//       self.window!.rootViewController = nav1
//       self.window?.makeKeyAndVisible()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainView = NavigationVC()
        self.window!.rootViewController = mainView
        self.window?.makeKeyAndVisible()
        
        return true
    }

}


