//
//  VotingViewModel.swift
//  ios-club-project-sp26
//
//  Created by Grace Chiu on 4/13/26.
//

import Foundation
                  
enum VoteType {
    case pass, skip, smash
}
              
struct VoteTarget: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let age: Int
    let city: String
    let tagline: String
    let major: String
    let favSong: String
    let origin: String
    let mbti: String
    let routine: String
    let hobbies: String
    let funFact: String
    let vibeMatch: Int     // 0...30
                                                                                                                                                                                  
  static let mockQueue: [VoteTarget] = [
      VoteTarget(name: "Alex Morales", initials: "AM", age: 22, city: "Atlanta, GA",
                 tagline: "Main Character Energy", major: "Computer Science",
                 favSong: "Blinding Lights", origin: "Puerto Rico", mbti: "ENFP",
                 routine: "Morning person", hobbies: "Dance, coding",
                 funFact: "I once ate 12 tacos in one sitting", vibeMatch: 12),
                                                                                                                                                                                  
      VoteTarget(name: "Sam Rivera", initials: "SR", age: 20, city: "Austin, TX",
                 tagline: "Chill & Mysterious", major: "Philosophy",
                 favSong: "Redbone", origin: "Mexico City", mbti: "INTP",
                 routine: "Night owl", hobbies: "Reading, chess",
                 funFact: "Can solve a Rubik's cube in under a minute", vibeMatch: 25),
                                                                                                                                                                                  
      VoteTarget(name: "Casey Tran", initials: "CT", age: 23, city: "Los Angeles, CA",
                 tagline: "Creative Chaos", major: "Film Studies",
                 favSong: "Glimpse of Us", origin: "Hanoi, Vietnam", mbti: "ENFJ",
                 routine: "Late mornings", hobbies: "Painting, skating",
                 funFact: "Has been to 17 concerts this year", vibeMatch: 8)
  ]
}
                                                                                                                                                                                  
@Observable
class VotingViewModel {
    var queue: [VoteTarget] = []
    var currentIndex: Int = 0
                                                                                                                                                                                  
    init() {
        loadQueue()
    }

    func loadQueue() {
        // TODO: swap to FirebaseService.fetchVotingQueue() when backend merges
        queue = VoteTarget.mockQueue
    }
                                                                                                                                                                                  
    func vote(_ type: VoteType) {
        guard !queue.isEmpty else { return }
        print("voted \(type) on \(queue[currentIndex].name)")
        // TODO: wire to FirebaseService.submitVote() when MT merges
        advance()
    }
                                                                                                                                                                                  
    private func advance() {
        guard !queue.isEmpty else { return }
        currentIndex = (currentIndex + 1) % queue.count
    }

    var currentTarget: VoteTarget? {
        guard !queue.isEmpty, currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }
}
