import SwiftUI
import FirebaseAuth
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
    var rizzHobbies: String = ""    // "Accidental Rizz Hobbies"
    var anthem: String = ""         // "Delusional Anthem"
    var routine: String = ""        // "Unhinged Routine"
    var homeTurf: String = ""       // "Home Turf"
    var major: String = ""
    var coreVibe: String = ""       // "Core Vibe"
    var funFact: String = ""
    var personalScore: Int = 0
    var smashCount: Int = 0
    var passCount: Int = 0
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
        allProfiles.sorted { $0.personalScore > $1.personalScore }
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
                    p.id           = doc.documentID
                    p.name         = data["name"]          as? String ?? ""
                    p.mbti         = data["mbti"]          as? String ?? ""
                    p.rizzHobbies  = (data["rizzHobbies"]  as? [String] ?? []).joined(separator: ", ")
                    p.anthem       = data["anthem"]        as? String ?? ""
                    p.routine      = data["routine"]       as? String ?? ""
                    p.homeTurf     = data["homeTurf"]      as? String ?? ""
                    p.major        = data["major"]         as? String ?? ""
                    p.coreVibe     = data["coreVibe"]      as? String ?? ""
                    p.funFact      = data["funFact"]       as? String ?? ""
                    p.personalScore = data["personalScore"] as? Int ?? 0
                    p.smashCount   = data["smashCount"]    as? Int ?? 0
                    p.passCount    = data["passCount"]     as? Int ?? 0
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
                allProfiles[index].personalScore += 100
                allProfiles[index].smashCount += 1
                writeVote(uid: targetID, isSmash: true)
            }
        case .pass:
            if let index = allProfiles.firstIndex(where: { $0.id == targetID }) {
                allProfiles[index].passCount += 1
                writeVote(uid: targetID, isSmash: false)
            }
        case .skip:
            break
        }
        currentVoteIndex += 1
        totalVotes += 1
    }

    private func writeVote(uid: String, isSmash: Bool) {
        guard let voterId = Auth.auth().currentUser?.uid else { return }

        // Update target user's score counters
        var updates: [String: Any] = [
            "smashCount": FieldValue.increment(Int64(isSmash ? 1 : 0)),
            "passCount":  FieldValue.increment(Int64(isSmash ? 0 : 1))
        ]
        if isSmash {
            updates["personalScore"] = FieldValue.increment(Int64(100))
        }
        db.collection("users").document(uid).updateData(updates)

        // Record vote history in votes collection
        let voteData: [String: Any] = [
            "voterId":      voterId,
            "targetUserId": uid,
            "voteType":     isSmash ? "smash" : "pass",
            "createdAt":    Date()
        ]
        db.collection("votes").addDocument(data: voteData)
    }
}
