//
//  taksiUygulamasiApp.swift
//  taksiUygulamasi
//
//  Created by Tülay MAYUNCUR on 10.04.2023.
//

import SwiftUI
struct taksiUygulamasiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
