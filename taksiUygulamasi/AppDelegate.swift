
//  AppDelegate.swift
//  taksiUygulamasi
//
//  Created by Tülay MAYUNCUR on 26.04.2023.
//

import SwiftUI
import UIKit
import Firebase
import FirebaseAuth

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool{
        FirebaseApp.configure()
        return true
    }
}

@main
struct Testing_SwiftUI2App: App {

    // inject into SwiftUI life-cycle via adaptor !!!
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
 

