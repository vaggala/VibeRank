//
//  FirebaseService.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 4/3/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class FirebaseService {
    static let shared = FirebaseService()
    let db: Firestore
    
    private init() {
        db = Firestore.firestore()
    }
    
    var authUser: User? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return User(
            uid: user.uid,
            name: user.displayName ?? "",
            hobbies: [],
            personalScore: 0,
            leaderboardRank: 0
        )
    }
    
    func signUp(email: String, password: String, name: String) async -> String? {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let userData: [String: Any] = [
                "name": name, // name is being stored in Firestore
                "hobbies": [],
                "mbti": "",
                "personalScore": 0,
                "leaderboardRank": 0
            ]
            let ref = db.collection("users").document(result.user.uid)
            try await ref.setData(userData)
            return result.user.uid
        } catch {
            print("error with signing up: \(error)")
        }
        return nil
    }
    
    func signIn(email: String, password: String) async -> String? {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        } catch {
            print("error signing in: \(error)")
        }
        return nil
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("error signing out: \(error)")
        }
    }
    
    // potential functions to add:
    // addProfileEntry
    // updateProfileEntry
    // removeProfileEntry (?)
    // getProfileEntry
    // (all of these could maybe be plural e.g. getProfileEntries)
}
