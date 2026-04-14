//
//  Vote.swift
//  ios-club-project-sp26
//
//  Created by Miguel Tjia on 4/11/26.
//

import Foundation

struct Vote: Codable, Identifiable {
    let id: String
    let voterId: String
    let targetUserId: String
    let voteType: String
    let createdAt: Date
    
}
