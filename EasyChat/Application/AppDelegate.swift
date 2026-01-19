//
//  AppDelegate.swift
//  EasyChat
//
//  Created by Talha Çelebi on 29.10.2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
        print("🔥 Firebase configured:", FirebaseApp.app() != nil)
        print("👤 Current user:", Auth.auth().currentUser as Any)
        let db = Firestore.firestore()
        print("📦 Firestore instance:", db)
        let window = UIWindow(frame: UIScreen.main.bounds)
        if Auth.auth().currentUser != nil {
            let tabbarVC = TabbarVCViewController(nibName: "TabbarVCViewController", bundle: nil)
            window.rootViewController = tabbarVC
        } else {
            let loginVC = LoginVCViewController(nibName: "LoginVCViewController", bundle: nil)
            window.rootViewController = loginVC
        }
        window.makeKeyAndVisible()
        
        self.window = window

        
        return true
    }



}

