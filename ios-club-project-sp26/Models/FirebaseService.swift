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
            rizzHobbies: [],
            mbti: "",
            anthem: "",
            routine: "",
            homeTurf: "",
            major: "",
            coreVibe: "",
            funFact: "",
            smashCount: 0,
            passCount: 0,
            personalScore: 0,
            leaderboardRank: 0
        )
    }
    
    func signUp(email: String, password: String, name: String) async -> String? {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let userData: [String: Any] = [
                "name": name,
                "rizzHobbies": "",
                "mbti": "",
                "anthem": "",
                "routine": "",
                "homeTurf": "",
                "major": "",
                "coreVibe": "",
                "funFact": "",
                "smashCount": 0,
                "passCount": 0,
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
    
    func fetchMyProfile() async -> User? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return await fetchProfile(uid: uid)
    }
    
    func fetchProfile(uid: String) async -> User? {
        let ref = db.collection("users").document(uid)
        do {
            let document = try await ref.getDocument()
            guard let data = document.data() else { return nil }
            let user = User(
                uid: uid,
                name: data["name"] as? String ?? "",
                rizzHobbies: data["rizzHobbies"] as? [String] ?? [],
                mbti: data["mbti"] as? String ?? "",
                anthem: data["anthem"] as? String ?? "",
                routine: data["routine"] as? String ?? "",
                homeTurf: data["mhomeTurf"] as? String ?? "",
                major: data["major"] as? String ?? "",
                coreVibe: data["coreVibe"] as? String ?? "",
                funFact: data["funFact"] as? String ?? "",
                smashCount: data["smashCount"] as? Int ?? 0,
                passCount: data["passCount"] as? Int ?? 0,
                personalScore: data["personalScore"] as? Int ?? 0,
                leaderboardRank: data["leaderboardRank"] as? Int ?? 0
            )
            return user
            
        } catch {
            print("error fetching profile: \(error)")
            return nil
        }
    }


    
    func updateProfile(
        name: String? = nil,
        rizzHobbies: [String]? = nil,
        mbti: String? = nil,
        anthem: String? = nil,
        routine: String? = nil,
        homeTurf: String? = nil,
        major: String? = nil,
        coreVibe: String? = nil,
        funFact: String? = nil
    ) async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }

        var updates: [String: Any] = [:]

        if let name = name {
            updates["name"] = name
        }


        if let mbti = mbti {
            updates["mbti"] = mbti
        }
        
        if let rizzHobbies = rizzHobbies {
            updates["rizzHobbies"] = rizzHobbies
        }
        if let anthem = anthem {
            updates["anthem"] = anthem
        }
        if let routine = routine {
            updates["routine"] = routine
        }
        if let homeTurf = homeTurf {
            updates["homeTurf"] = homeTurf
        }
        if let major = major {
            updates["major"] = major
        }
        if let coreVibe = coreVibe {
            updates["coreVibe"] = coreVibe
        }
        if let funFact = funFact {
            updates["funFact"] = funFact
        }
        guard !updates.isEmpty else { return true }

        do {
            try await db.collection("users")
                .document(uid)
                .updateData(updates)

            return true
        } catch {
            print("profile update failed: \(error)")
            return false
        }
    }
    
    
    func submitVote(targetUserId: String, isSmash: Bool) async {
        print("SubmitVote called")
        
        // TEMP test voter until auth flow is connected
        guard let voterId = authUser?.uid else {
            print("No logged in user")
            return
        }
        
        let voteRef = db.collection("votes").document()
        let targetRef = db.collection("users").document(targetUserId)
        
        let vote = Vote(
            id: voteRef.documentID,
            voterId: voterId,
            targetUserId: targetUserId,
            voteType: isSmash ? "smash" : "pass",
            createdAt: Date()
        )
        
        do {
            try await db.runTransaction { transaction, errorPointer in
                do {
                    let targetDoc = try transaction.getDocument(targetRef)
                    let currentScore = targetDoc.data()?["personalScore"] as? Int ?? 0
                    let smashCount = targetDoc.data()?["smashCount"] as? Int ?? 0
                    let passCount = targetDoc.data()?["passCount"] as? Int ?? 0
                    
                    let newScore = isSmash ? currentScore + 100 : currentScore
                    let newSmashCount = isSmash ? smashCount + 1 : smashCount
                    let newPassCount = isSmash ? passCount : passCount + 1
                    
                    
                    transaction.setData([
                        "id": vote.id,
                        "voterId": vote.voterId,
                        "targetUserId": vote.targetUserId,
                        "voteType": vote.voteType,
                        "createdAt": vote.createdAt
                    ], forDocument: voteRef)
                    
                    transaction.updateData([
                        "personalScore": newScore,
                        "smashCount": newSmashCount,
                        "passCount": newPassCount
                    ], forDocument: targetRef)
                    
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                
                return nil
            }
            
            print("vote submitted successfully")
            
        } catch {
            print("vote failed: \(error)")
        }
    }
    
    func fetchLeaderBoard() async -> [User] {
        do {
            let snapshot = try await db.collection("users")
                .order(by: "personalScore", descending: true)
                .limit(to: 20)
                .getDocuments()

            return snapshot.documents.enumerated().map { index, doc in
                let data = doc.data()

                return User(
                    uid: doc.documentID,
                    name: data["name"] as? String ?? "",
                    rizzHobbies: data["rizzHobbies"] as? [String] ?? [],
                    mbti: data["mbti"] as? String ?? "",
                    anthem: data["anthem"] as? String ?? "",
                    routine: data["routine"] as? String ?? "",
                    homeTurf: data["homeTurf"] as? String ?? "",
                    major: data["major"] as? String ?? "",
                    coreVibe: data["coreVibe"] as? String ?? "",
                    funFact: data["funFact"] as? String ?? "",
                    smashCount: data["smashCount"] as? Int ?? 0,
                    passCount: data["passCount"] as? Int ?? 0,
                    personalScore: data["personalScore"] as? Int ?? 0,
                    leaderboardRank: index + 1
                )
            }
        } catch {
            print("leaderboard fetch failed:", error)
            return []
        }
    }
    
    func fetchMyRank(uid: String) async -> Int {
        do {
            let myDoc = try await db.collection("users").document(uid).getDocument()
            let myScore = myDoc.data()!["Personal Score"] as! Int ?? 0
            
            let higherUsers = try await db.collection("users")
                .whereField("personalScore", isGreaterThan: myScore)
                .getDocuments()
            
            return higherUsers.documents.count + 1
        } catch {
            print("rank fetch failed:", error)
            return -1
        }
    }
}
