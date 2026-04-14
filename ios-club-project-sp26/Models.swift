import SwiftUI
import FirebaseFirestore

// MARK: - Vote Type

enum VoteType {
    case smash
    case pass
    case skip
}

// MARK: - UserProfile (stored in Firestore, used everywhere)

struct UserProfile: Identifiable {
    var id: String = ""
    var name: String = ""
    var mbti: String = ""
    var hobbies: String = ""    // "Accidental Rizz Hobbies"
    var anthem: String = ""     // "Delusional Anthem"
    var routine: String = ""    // "Unhinged Routine"
    var homeTurf: String = ""   // "Home Turf"
    var major: String = ""
    var coreVibe: String = ""   // "Core Vibe"
    var funFact: String = ""
    var score: Int = 0
    var smashes: Int = 0
    var passes: Int = 0
    var rank: Int = 0

    // Computed from name
    var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    // Deterministic accent color based on user ID
    var accentColor: Color {
        let palette: [Color] = [
            AppTheme.purple, AppTheme.blue, AppTheme.pink,
            AppTheme.green, AppTheme.orange, AppTheme.yellow
        ]
        let index = ((id.hashValue % palette.count) + palette.count) % palette.count
        return palette[index]
    }
}

// MARK: - AppData (voting state + Firestore)

@Observable
class AppData {
    var allProfiles: [UserProfile] = []
    var currentVoteIndex: Int = 0
    var totalVotes: Int = 0
    var isLoading: Bool = false
    var currentUserUID: String = ""

    private let db = Firestore.firestore()

    // Other users to vote on (excludes self)
    var voteProfiles: [UserProfile] {
        allProfiles.filter { $0.id != currentUserUID }
    }

    // Current card to show
    var currentProfile: UserProfile? {
        guard !voteProfiles.isEmpty else { return nil }
        return voteProfiles[currentVoteIndex % voteProfiles.count]
    }

    // Sorted leaderboard (all users including self)
    var leaderboard: [UserProfile] {
        allProfiles.sorted { $0.score > $1.score }
    }

    // MARK: - Fetch all users from Firestore

    func fetchProfiles() {
        isLoading = true
        db.collection("users").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let docs = snapshot?.documents else { return }
                self?.allProfiles = docs.map { doc in
                    let data = doc.data()
                    var p = UserProfile()
                    p.id       = doc.documentID
                    p.name     = data["name"]     as? String ?? ""
                    p.mbti     = data["mbti"]     as? String ?? ""
                    p.hobbies  = data["hobbies"]  as? String ?? ""
                    p.anthem   = data["anthem"]   as? String ?? ""
                    p.routine  = data["routine"]  as? String ?? ""
                    p.homeTurf = data["homeTurf"] as? String ?? ""
                    p.major    = data["major"]    as? String ?? ""
                    p.coreVibe = data["coreVibe"] as? String ?? ""
                    p.funFact  = data["funFact"]  as? String ?? ""
                    p.score    = data["score"]    as? Int ?? 0
                    p.smashes  = data["smashes"]  as? Int ?? 0
                    p.passes   = data["passes"]   as? Int ?? 0
                    return p
                }
            }
        }
    }

    // MARK: - Vote and write back to Firestore

    func vote(_ type: VoteType, targetID: String = "") {
        switch type {
        case .smash:
            if let index = allProfiles.firstIndex(where: { $0.id == targetID }) {
                allProfiles[index].score += 15
                allProfiles[index].smashes += 1
                writeVote(uid: targetID, scoreDelta: 15, smashDelta: 1, passDelta: 0)
            }
        case .pass:
            if let index = allProfiles.firstIndex(where: { $0.id == targetID }) {
                allProfiles[index].score -= 5
                allProfiles[index].passes += 1
                writeVote(uid: targetID, scoreDelta: -5, smashDelta: 0, passDelta: 1)
            }
        case .skip:
            break
        }
        currentVoteIndex += 1
        totalVotes += 1
    }

    private func writeVote(uid: String, scoreDelta: Int, smashDelta: Int, passDelta: Int) {
        db.collection("users").document(uid).updateData([
            "score":   FieldValue.increment(Int64(scoreDelta)),
            "smashes": FieldValue.increment(Int64(smashDelta)),
            "passes":  FieldValue.increment(Int64(passDelta))
        ])
    }
}
