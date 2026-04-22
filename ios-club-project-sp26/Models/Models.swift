import SwiftUI

enum VoteType {
    case smash
    case pass
    case skip
}

// MARK: - UserProfile

struct UserProfile: Identifiable {
    var id: String = ""
    var name: String = ""
    var mbti: String = ""
    var rizzHobbies: String = ""
    var anthem: String = ""
    var routine: String = ""
    var homeTurf: String = ""
    var major: String = ""
    var coreVibe: String = ""
    var funFact: String = ""
    var personalScore: Int = 0
    var smashCount: Int = 0
    var passCount: Int = 0
    var rank: Int = 0

    var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    var accentColor: Color {
        let palette: [Color] = [
            AppTheme.purple, AppTheme.blue, AppTheme.pink,
            AppTheme.green, AppTheme.orange, AppTheme.yellow
        ]
        let index = ((id.hashValue % palette.count) + palette.count) % palette.count
        return palette[index]
    }
}

@Observable
class AppData {
    var leaderboardProfiles: [UserProfile] = []
    var candidateProfiles: [UserProfile] = []

    var totalVotes: Int = 0
    var isLoadingLeaderboard: Bool = false
    var isLoadingCandidates: Bool = false
    var currentUserUID: String = ""

    var votedUserIDs: Set<String> = []
    var hasLoadedVoteHistory: Bool = false
    var hasMoreCandidates: Bool = true

    private var leaderboardListener: ListenerRegistration?
    private let db = Firestore.firestore()

    var currentProfile: UserProfile? {
        candidateProfiles.first
    }

    var leaderboard: [UserProfile] {
        leaderboardProfiles
    }

    var isLoading: Bool {
        isLoadingLeaderboard || isLoadingCandidates
    }

    func startListeningLeaderboard() {
        isLoadingLeaderboard = true

        leaderboardListener?.remove()
        leaderboardListener = db.collection("users")
            .order(by: "personalScore", descending: true)
            .limit(to: 20)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    self.isLoadingLeaderboard = false

                    guard let docs = snapshot?.documents else {
                        if let error = error {
                            print("leaderboard listener failed: \(error)")
                        }
                        return
                    }

                    self.leaderboardProfiles = docs.enumerated().map { index, doc in
                        let data = doc.data()
                        var p = UserProfile()
                        p.id = doc.documentID
                        p.name = data["name"] as? String ?? ""
                        p.mbti = data["mbti"] as? String ?? ""
                        p.rizzHobbies = (data["rizzHobbies"] as? [String] ?? []).joined(separator: ", ")
                        p.anthem = data["anthem"] as? String ?? ""
                        p.routine = data["routine"] as? String ?? ""
                        p.homeTurf = data["homeTurf"] as? String ?? ""
                        p.major = data["major"] as? String ?? ""
                        p.coreVibe = data["coreVibe"] as? String ?? ""
                        p.funFact = data["funFact"] as? String ?? ""
                        p.personalScore = data["personalScore"] as? Int ?? 0
                        p.smashCount = data["smashCount"] as? Int ?? 0
                        p.passCount = data["passCount"] as? Int ?? 0
                        p.rank = index + 1
                        return p
                    }
                }
            }
    }

    func loadVotedUserIDs() async {
        guard !currentUserUID.isEmpty else { return }

        do {
            let snapshot = try await db.collection("votes")
                .whereField("voterId", isEqualTo: currentUserUID)
                .getDocuments()

            let ids = snapshot.documents.compactMap { doc in
                doc.data()["targetUserId"] as? String
            }

            await MainActor.run {
                self.votedUserIDs = Set(ids)
                self.hasLoadedVoteHistory = true
            }
        } catch {
            print("failed to load vote history: \(error)")
            await MainActor.run {
                self.votedUserIDs = []
                self.hasLoadedVoteHistory = true
            }
        }
    }

    func loadCandidateProfiles(batchSize: Int = 50) async {
        guard !currentUserUID.isEmpty else { return }

        await MainActor.run {
            self.isLoadingCandidates = true
        }

        do {
            let snapshot = try await db.collection("users")
                .limit(to: batchSize)
                .getDocuments()

            let filtered = snapshot.documents.compactMap { doc -> UserProfile? in
                let id = doc.documentID
                guard id != self.currentUserUID else { return nil }
                guard !self.votedUserIDs.contains(id) else { return nil }
                return Self.profile(from: doc, rank: 0)
            }

            await MainActor.run {
                self.candidateProfiles = filtered
                self.hasMoreCandidates = filtered.count == batchSize
                self.isLoadingCandidates = false
            }
        } catch {
            print("failed to load candidate profiles: \(error)")
            await MainActor.run {
                self.candidateProfiles = []
                self.hasMoreCandidates = false
                self.isLoadingCandidates = false
            }
        }
    }

    func refreshVotingDeck() async {
        guard !currentUserUID.isEmpty else { return }

        await loadVotedUserIDs()
        await loadCandidateProfiles()
    }

    func stopListeningLeaderboard() {
        leaderboardListener?.remove()
        leaderboardListener = nil
    }

    func vote(_ type: VoteType, targetID: String = "") {
        guard !targetID.isEmpty else { return }

        switch type {
        case .smash:
            if let index = leaderboardProfiles.firstIndex(where: { $0.id == targetID }) {
                leaderboardProfiles[index].personalScore += 100
                leaderboardProfiles[index].smashCount += 1
            }
            votedUserIDs.insert(targetID)
            candidateProfiles.removeAll { $0.id == targetID }
            writeVote(uid: targetID, isSmash: true)

        case .pass:
            if let index = leaderboardProfiles.firstIndex(where: { $0.id == targetID }) {
                leaderboardProfiles[index].passCount += 1
            }
            votedUserIDs.insert(targetID)
            candidateProfiles.removeAll { $0.id == targetID }
            writeVote(uid: targetID, isSmash: false)

        case .skip:
            if let first = candidateProfiles.first, first.id == targetID {
                candidateProfiles.removeFirst()
                candidateProfiles.append(first)
            }
        }

        totalVotes += 1
    }

    private func writeVote(uid: String, isSmash: Bool) {
        guard let voterId = Auth.auth().currentUser?.uid else { return }

        var updates: [String: Any] = [
            "smashCount": FieldValue.increment(Int64(isSmash ? 1 : 0)),
            "passCount": FieldValue.increment(Int64(isSmash ? 0 : 1))
        ]

        if isSmash {
            updates["personalScore"] = FieldValue.increment(Int64(100))
        }

        db.collection("users").document(uid).updateData(updates)

        let voteData: [String: Any] = [
            "voterId": voterId,
            "targetUserId": uid,
            "voteType": isSmash ? "smash" : "pass",
            "createdAt": Date()
        ]
        db.collection("votes").addDocument(data: voteData)
    }

    private static func profile(from doc: QueryDocumentSnapshot, rank: Int) -> UserProfile {
        let data = doc.data()
        var p = UserProfile()
        p.id = doc.documentID
        p.name = data["name"] as? String ?? ""
        p.mbti = data["mbti"] as? String ?? ""
        p.rizzHobbies = (data["rizzHobbies"] as? [String] ?? []).joined(separator: ", ")
        p.anthem = data["anthem"] as? String ?? ""
        p.routine = data["routine"] as? String ?? ""
        p.homeTurf = data["homeTurf"] as? String ?? ""
        p.major = data["major"] as? String ?? ""
        p.coreVibe = data["coreVibe"] as? String ?? ""
        p.funFact = data["funFact"] as? String ?? ""
        p.personalScore = data["personalScore"] as? Int ?? 0
        p.smashCount = data["smashCount"] as? Int ?? 0
        p.passCount = data["passCount"] as? Int ?? 0
        p.rank = rank
        return p
    }
}
