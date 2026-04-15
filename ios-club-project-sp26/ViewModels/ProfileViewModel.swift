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
        if let _ = await service.signUp(email: email, password: password, name: name) {
            await loadAllData()
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        if let _ = await service.signIn(email: email, password: password) {
            await loadAllData()
            return true
        }
        return false
    }

    func signOut() {
        service.signOut()
        user = nil
    }
    
    func loadAllData() async {
        if let fetchedUser = await service.fetchMyProfile() {
            user = fetchedUser
        } else {
            print("error")
            user = nil
        }
    }
    
    func updateName(name: String) async {
        let success = await service.updateProfile(name: name)
        
        if success {
            user?.name = name
        }
    }
    
    func updateMBTI(mbti: String) async {
        let success = await service.updateProfile(mbti: mbti)
        
        if success {
            user?.mbti = mbti
        }
    }
    
    func updateRizzHobbies(_ hobbies: [String]) async {
        let success = await service.updateProfile(rizzHobbies: hobbies)

        if success {
            user?.rizzHobbies = hobbies
        }
    }
    
    func updateAnthem(anthem: String) async {
        let success = await service.updateProfile(anthem: anthem)

        if success {
            user?.anthem = anthem
        }
    }

    func updateRoutine(routine: String) async {
        let success = await service.updateProfile(routine: routine)

        if success {
            user?.routine = routine
        }
    }

    func updateHomeTurf(homeTurf: String) async {
        let success = await service.updateProfile(homeTurf: homeTurf)

        if success {
            user?.homeTurf = homeTurf
        }
    }

    func updateMajor(major: String) async {
        let success = await service.updateProfile(major: major)

        if success {
            user?.major = major
        }
    }

    func updateCoreVibe(coreVibe: String) async {
        let success = await service.updateProfile(coreVibe: coreVibe)

        if success {
            user?.coreVibe = coreVibe
        }
    }

    func updateFunFact(funFact: String) async {
        let success = await service.updateProfile(funFact: funFact)

        if success {
            user?.funFact = funFact
        }
    }
}

