//
//  LeaderboardViewModel.swift
//  ios-club-project-sp26
//
//  Created by Miguel Tjia on 4/11/26.
//

import SwiftUI
import Foundation
import FirebaseFirestore

@Observable
class LeaderboardViewModel {
    //    var topUsers: [User] = []
    //    var currentUserRank: Int? = nil
    //    var currentUser: User? = nil
    //    let service = FirebaseService.shared
    //
    //    func loadLeaderboard() {
    //        Task {
    //            topUsers = await service.fetchLeaderBoard()
    //
    //            guard let uid = service.authUser?.uid else { return }
    //
    //            if let me = topUsers.first(where: {$0.uid == uid}) {
    //                currentUser = me
    //                currentUserRank = me.leaderboardRank
    //                return
    //            }
    //
    //            let myRank = await service.fetchMyRank(uid: uid)
    //            currentUserRank = myRank
    //
    //            if let me = await service.fetchProfile(uid: uid) {
    //                currentUser = me
    //            }
    //        }
    //    }
    var topUsers: [User] = []
    var currentUserRank: Int? = nil
    var currentUser: User? = nil
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func startListening() {
        listener = db.collection("users")
            .order(by: "personalScore", descending: true)
            .limit(to: 20)
            .addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    guard let docs = snapshot?.documents else { return }
                    
                    self.topUsers = docs.enumerated().map { index, doc in
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
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
