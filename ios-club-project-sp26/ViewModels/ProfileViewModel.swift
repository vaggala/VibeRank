//
//  ProfileViewModel.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 4/8/26.
//

import Foundation
import SwiftUI

@Observable
class ProfileViewModel {
    var user: User? = nil
    var service: FirebaseService
    
    init(service: FirebaseService = FirebaseService.shared) {
        self.service = service
        if let user = service.authUser {
            self.user = user
        }
        Task {
            await loadAllData()
        }
    }
    
    func signUp(email: String, password: String, name: String) async {
        if let id = await service.signUp(email: email, password: password, name: name) {
            await loadAllData()
        }
    }
    
    func signIn(email: String, password: String) async {
        if let _ = await service.signIn(email: email, password: password) {
            await loadAllData()
        }
    }

    func signOut() {
        service.signOut()
        user = nil
    }
    
    func loadAllData() async {
        if let fetchedUser = await service.fetchProfile() {
            user = fetchedUser
        } else {
            print("error")
            user = nil
        }
    }
}

