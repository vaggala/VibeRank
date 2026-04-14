//
//  VotingViewModel.swift
//  ios-club-project-sp26
//
//  Created by Miguel Tjia on 4/11/26.
//

import Foundation
import SwiftUI

@Observable
class VotingViewModel {
    let service = FirebaseService.shared
    
    func smash(targetUserId: String) {
        Task {
            await service.submitVote(targetUserId: targetUserId, isSmash: true)
        }
    }
    
    func pass(targetUserId: String) {
        Task {
            await service.submitVote(targetUserId: targetUserId, isSmash: false)
        }
    }
}
