//
//  AppDelegate.swift
//  EasyChat
//
//  Created by Talha Çelebi on 29.10.2025.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabbarVC = TabbarVCViewController(nibName: "TabbarVCViewController", bundle: nil)
        window.rootViewController = tabbarVC
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }



}

