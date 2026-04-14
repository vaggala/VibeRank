//
//  ios_club_project_sp26App.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 3/16/26.
//

import SwiftUI

import FirebaseCore

@main
struct ios_club_project_sp26App: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

