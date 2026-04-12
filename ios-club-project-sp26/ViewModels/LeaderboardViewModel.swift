//
//  LeaderboardViewModel.swift
//  ios-club-project-sp26
//
//  Created by Miguel Tjia on 4/11/26.
//

import SwiftUI
import Foundation

@Observable
class LeaderboardViewModel {
    var topUsers: [User] = []
    var currentUserRank: Int? = nil
    var currentUser: User? = nil
    let service = FirebaseService.shared
    
    func loadLeaderboard() {
        Task {
            topUsers = await service.fetchLeaderBoard()
            
            guard let uid = service.authUser?.uid else { return }
            
            if let me = topUsers.first(where: {$0.uid == uid}) {
                currentUser = me
                currentUserRank = me.leaderboardRank
                return
            }
            
            let myRank = await service.fetchMyRank(uid: uid)
            currentUserRank = myRank
            
            if let me = await service.fetchProfile(uid: uid) {
                currentUser = me
            }
        }
    }
    
}
