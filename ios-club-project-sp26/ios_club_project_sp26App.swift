//
//  ios_club_project_sp26App.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 3/16/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct ios_club_project_sp26App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
//            ContentView()
//            AuthView() // for testing purposes
            RootView()
        }
    }
}
