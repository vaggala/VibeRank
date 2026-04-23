//
//  FirebaseService.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 4/3/26.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@Observable
class FirebaseService {
    static let shared = FirebaseService()

    var currentUser: UserProfile? = nil
    var isLoggedIn: Bool = false
    var needsOnboarding: Bool = false
    var errorMessage: String = ""
    var isLoading: Bool = false

    var allProfiles: [UserProfile] = []
    var currentVoteIndex: Int = 0
    var totalVotes: Int = 0
    var currentUserUID: String = ""
    var userRank: Int = 0
    
    var candidateProfiles: [UserProfile] = []
    var votedUserIDs: Set<String> = []
    var hasLoadedVoteHistory: Bool = false
    var hasMoreCandidates: Bool = true
    private var isLoadingCandidates: Bool = false

    let db: Firestore
    private var authHandle: AuthStateDidChangeListenerHandle?
    private var profileListener: ListenerRegistration?
    private var leaderboardListener: ListenerRegistration?

    private init() {
        db = Firestore.firestore()

        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let uid = firebaseUser?.uid {
                self?.listenToProfile(uid: uid)
            } else {
                DispatchQueue.main.async {
                    self?.isLoggedIn = false
                    self?.currentUser = nil
                    self?.needsOnboarding = false
                }
            }
        }
    }


    var voteProfiles: [UserProfile] {
        allProfiles.filter { $0.id != currentUserUID }
    }

    var currentProfile: UserProfile? {
        candidateProfiles.first
    }
    
    var leaderboard: [UserProfile] {
        allProfiles
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = "" }
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            await MainActor.run {
                self.isLoggedIn = true
                self.needsOnboarding = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = "" }
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run { self.isLoading = false }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        profileListener?.remove()
        profileListener = nil
        stopListeningLeaderboard()
        try? Auth.auth().signOut()
        isLoggedIn = false
        currentUser = nil
        needsOnboarding = false
        allProfiles = []
        currentVoteIndex = 0
        totalVotes = 0
    }

    // MARK: - Create Profile (onboarding only)
    // Called once when a new user completes onboarding.
    // Creates the document from scratch and initializes scores to 0.

    func createProfile(_ profile: UserProfile) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        await MainActor.run { isLoading = true }

        let data: [String: Any] = [
            "name":          profile.name,
            "mbti":          profile.mbti,
            "rizzHobbies":   profile.rizzHobbies.isEmpty ? [] : [profile.rizzHobbies],
            "anthem":        profile.anthem,
            "routine":       profile.routine,
            "homeTurf":      profile.homeTurf,
            "major":         profile.major,
            "coreVibe":      profile.coreVibe,
            "funFact":       profile.funFact,
            "instagram":     profile.instagram,
            "hasInstagram":  profile.hasInstagram,
            "personalScore": 0,
            "smashCount":    0,
            "passCount":     0
        ]

        do {
            try await db.collection("users").document(uid).setData(data)
            var saved = profile
            saved.id = uid
            await MainActor.run {
                self.currentUser = saved
                self.needsOnboarding = false
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Update Profile (edit profile only)
    // Called when an existing user edits their profile.
    // Never touches scores — those are owned exclusively by vote transactions.

    func updateProfile(_ profile: UserProfile) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        await MainActor.run { isLoading = true }

        let data: [String: Any] = [
            "name":         profile.name,
            "mbti":         profile.mbti,
            "rizzHobbies":  profile.rizzHobbies.isEmpty ? [] : [profile.rizzHobbies],
            "anthem":       profile.anthem,
            "routine":      profile.routine,
            "homeTurf":     profile.homeTurf,
            "major":        profile.major,
            "coreVibe":     profile.coreVibe,
            "funFact":      profile.funFact,
            "instagram":    profile.instagram,
            "hasInstagram": profile.hasInstagram
        ]

        do {
            try await db.collection("users").document(uid).updateData(data)
            var saved = profile
            saved.id = uid
            await MainActor.run {
                self.currentUser = saved
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Real-time Profile Listener (private, called on auth state change)

    private func listenToProfile(uid: String) {
        profileListener?.remove()
        profileListener = db.collection("users").document(uid)
            .addSnapshotListener { [weak self] doc, _ in
                DispatchQueue.main.async {
                    guard let doc = doc, doc.exists, let data = doc.data() else {
                        self?.isLoggedIn = true
                        self?.needsOnboarding = true
                        return
                    }
                    var profile = UserProfile()
                    profile.id            = uid
                    profile.name          = data["name"]          as? String ?? ""
                    profile.mbti          = data["mbti"]          as? String ?? ""
                    profile.rizzHobbies   = (data["rizzHobbies"]  as? [String] ?? []).joined(separator: ", ")
                    profile.anthem        = data["anthem"]        as? String ?? ""
                    profile.routine       = data["routine"]       as? String ?? ""
                    profile.homeTurf      = data["homeTurf"]      as? String ?? ""
                    profile.major         = data["major"]         as? String ?? ""
                    profile.coreVibe      = data["coreVibe"]      as? String ?? ""
                    profile.funFact       = data["funFact"]       as? String ?? ""
                    profile.instagram     = FirebaseService.instagramOrDefault(data: data)
                    profile.hasInstagram  = data["hasInstagram"]  as? Bool ?? true
                    profile.personalScore = data["personalScore"] as? Int ?? 0
                    profile.smashCount    = data["smashCount"]    as? Int ?? 0
                    profile.passCount     = data["passCount"]     as? Int ?? 0
                    self?.currentUser     = profile
                    self?.isLoggedIn      = true
                    self?.needsOnboarding = false
                }
            }
    }

    // MARK: - Leaderboard Listener

    func startListeningLeaderboard() {
        isLoading = true
        leaderboardListener?.remove()
        leaderboardListener = db.collection("users")
            .order(by: "personalScore", descending: true)
            .limit(to: 20)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    guard let docs = snapshot?.documents else {
                        if let error { print("leaderboard listener failed: \(error)") }
                        return
                    }
                    self?.allProfiles = docs.enumerated().map { index, doc in
                        let data = doc.data()
                        var p = UserProfile()
                        p.id            = doc.documentID
                        p.name          = data["name"]          as? String ?? ""
                        p.mbti          = data["mbti"]          as? String ?? ""
                        p.rizzHobbies   = (data["rizzHobbies"]  as? [String] ?? []).joined(separator: ", ")
                        p.anthem        = data["anthem"]        as? String ?? ""
                        p.routine       = data["routine"]       as? String ?? ""
                        p.homeTurf      = data["homeTurf"]      as? String ?? ""
                        p.major         = data["major"]         as? String ?? ""
                        p.coreVibe      = data["coreVibe"]      as? String ?? ""
                        p.funFact       = data["funFact"]       as? String ?? ""
                        p.instagram     = FirebaseService.instagramOrDefault(data: data)
                        p.hasInstagram  = data["hasInstagram"]  as? Bool ?? true
                        p.personalScore = data["personalScore"] as? Int ?? 0
                        p.smashCount    = data["smashCount"]    as? Int ?? 0
                        p.passCount     = data["passCount"]     as? Int ?? 0
                        p.rank          = index + 1
                        return p
                    }
                }
            }
    }

    func stopListeningLeaderboard() {
        leaderboardListener?.remove()
        leaderboardListener = nil
    }

    // MARK: - One-shot Fetch (pull-to-refresh)

    func fetchProfiles() {
        isLoading = true
        db.collection("users").getDocuments { [weak self] snapshot, _ in
            DispatchQueue.main.async {
                self?.isLoading = false
                guard let docs = snapshot?.documents else { return }
                self?.allProfiles = docs.map { doc in
                    let data = doc.data()
                    var p = UserProfile()
                    p.id            = doc.documentID
                    p.name          = data["name"]          as? String ?? ""
                    p.mbti          = data["mbti"]          as? String ?? ""
                    p.rizzHobbies   = (data["rizzHobbies"]  as? [String] ?? []).joined(separator: ", ")
                    p.anthem        = data["anthem"]        as? String ?? ""
                    p.routine       = data["routine"]       as? String ?? ""
                    p.homeTurf      = data["homeTurf"]      as? String ?? ""
                    p.major         = data["major"]         as? String ?? ""
                    p.coreVibe      = data["coreVibe"]      as? String ?? ""
                    p.funFact       = data["funFact"]       as? String ?? ""
                    p.instagram     = FirebaseService.instagramOrDefault(data: data)
                    p.hasInstagram  = data["hasInstagram"]  as? Bool ?? true
                    p.personalScore = data["personalScore"] as? Int ?? 0
                    p.smashCount    = data["smashCount"]    as? Int ?? 0
                    p.passCount     = data["passCount"]     as? Int ?? 0
                    return p
                }
            }
        }
    }

    // MARK: - Vote (optimistic local update + Firestore write)

    func vote(_ type: VoteType, targetID: String = "", onMutualMatch: ((MutualMatch) -> Void)? = nil) {
        guard !targetID.isEmpty else { return }
        switch type {
        case .smash:
            if let index = allProfiles.firstIndex(where: { $0.id == targetID }) {
                allProfiles[index].personalScore += 100
                allProfiles[index].smashCount += 1
            }
            votedUserIDs.insert(targetID)
            candidateProfiles.removeAll { $0.id == targetID }
            Task {
                let match = await submitVote(targetUserId: targetID, isSmash: true)
                if let match = match {
                    await MainActor.run { onMutualMatch?(match) }
                }
            }
        case .pass:
            if let index = allProfiles.firstIndex(where: { $0.id == targetID }) {
                allProfiles[index].passCount += 1
            }
            votedUserIDs.insert(targetID)
            candidateProfiles.removeAll { $0.id == targetID }
            Task { await submitVote(targetUserId: targetID, isSmash: false) }
        case .skip:
            // Rotate to back of deck without marking as voted
            if let first = candidateProfiles.first, first.id == targetID {
                candidateProfiles.removeFirst()
                candidateProfiles.append(first)
            }
        }
        totalVotes += 1
    }

    // MARK: - Submit Vote (Firestore transaction)

    @discardableResult
    func submitVote(targetUserId: String, isSmash: Bool) async -> MutualMatch? {
        guard let voterId = Auth.auth().currentUser?.uid else {
            print("submitVote: no logged-in user")
            return nil
        }

        let voteRef   = db.collection("votes").document()
        let targetRef = db.collection("users").document(targetUserId)

        let vote = Vote(
            id:           voteRef.documentID,
            voterId:      voterId,
            targetUserId: targetUserId,
            voteType:     isSmash ? "smash" : "pass",
            createdAt:    Date()
        )

        do {
            try await db.runTransaction { transaction, errorPointer in
                do {
                    let targetDoc    = try transaction.getDocument(targetRef)
                    let currentScore = targetDoc.data()?["personalScore"] as? Int ?? 0
                    let smashCount   = targetDoc.data()?["smashCount"]    as? Int ?? 0
                    let passCount    = targetDoc.data()?["passCount"]     as? Int ?? 0

                    let newScore      = isSmash ? currentScore + 100 : currentScore - 100
                    let newSmashCount = isSmash ? smashCount + 1 : smashCount
                    let newPassCount  = isSmash ? passCount     : passCount + 1

                    transaction.setData([
                        "id":           vote.id,
                        "voterId":      vote.voterId,
                        "targetUserId": vote.targetUserId,
                        "voteType":     vote.voteType,
                        "createdAt":    vote.createdAt
                    ], forDocument: voteRef)

                    transaction.updateData([
                        "personalScore": newScore,
                        "smashCount":    newSmashCount,
                        "passCount":     newPassCount
                    ], forDocument: targetRef)
                } catch {
                    errorPointer?.pointee = error as NSError
                }
                return nil
            }
            print("vote submitted successfully")
        } catch {
            print("vote failed: \(error)")
            return nil
        }

        guard isSmash else { return nil }
        return await detectAndWriteMutualMatch(voterId: voterId, targetUserId: targetUserId)
    }

    // MARK: - Mutual-Match Detection

    private func detectAndWriteMutualMatch(voterId: String, targetUserId: String) async -> MutualMatch? {
        do {
            let reciprocal = try await db.collection("votes")
                .whereField("voterId",     isEqualTo: targetUserId)
                .whereField("targetUserId", isEqualTo: voterId)
                .whereField("voteType",    isEqualTo: "smash")
                .limit(to: 1)
                .getDocuments()
            guard !reciprocal.documents.isEmpty else { return nil }

            async let voterDocTask  = db.collection("users").document(voterId).getDocument()
            async let targetDocTask = db.collection("users").document(targetUserId).getDocument()
            let voterDoc  = try await voterDocTask
            let targetDoc = try await targetDocTask

            let voterData  = voterDoc.data()  ?? [:]
            let targetData = targetDoc.data() ?? [:]

            let voterName  = voterData["name"]          as? String ?? ""
            let targetName = targetData["name"]         as? String ?? ""
            let voterIg    = FirebaseService.instagramOrDefault(data: voterData)
            let targetIg   = FirebaseService.instagramOrDefault(data: targetData)
            let voterHas   = voterData["hasInstagram"]  as? Bool   ?? true
            let targetHas  = targetData["hasInstagram"] as? Bool   ?? true

            let matchId = MutualMatch.pairDocId(voterId, targetUserId)
            let sorted  = [voterId, targetUserId].sorted()
            let voterIsA = sorted[0] == voterId

            let matchData: [String: Any] = [
                "id":            matchId,
                "participants":  [voterId, targetUserId],
                "uidA":          sorted[0],
                "uidB":          sorted[1],
                "nameA":         voterIsA ? voterName : targetName,
                "nameB":         voterIsA ? targetName : voterName,
                "instagramA":    voterIsA ? voterIg : targetIg,
                "instagramB":    voterIsA ? targetIg : voterIg,
                "hasInstagramA": voterIsA ? voterHas : targetHas,
                "hasInstagramB": voterIsA ? targetHas : voterHas,
                "createdAt":     Date()
            ]

            try await db.collection("matches").document(matchId).setData(matchData)

            return MutualMatch(
                id: matchId,
                otherUserId: targetUserId,
                otherUserName: targetName,
                otherUserInstagram: targetIg,
                otherUserHasInstagram: targetHas,
                createdAt: Date()
            )
        } catch {
            print("mutual-match detection failed: \(error)")
            return nil
        }
    }

    // MARK: - Fetch Matches (for Profile tab list)

    func fetchMatches(for uid: String) async -> [MutualMatch] {
        do {
            let snapshot = try await db.collection("matches")
                .whereField("participants", arrayContains: uid)
                .getDocuments()
            let matches: [MutualMatch] = snapshot.documents.compactMap { doc in
                let data = doc.data()
                let uidA = data["uidA"] as? String ?? ""
                let uidB = data["uidB"] as? String ?? ""
                let isA  = uid == uidA
                let otherUid    = isA ? uidB : uidA
                let otherName   = (isA ? data["nameB"]         : data["nameA"])         as? String ?? ""
                let otherIg     = (isA ? data["instagramB"]    : data["instagramA"])    as? String ?? ""
                let otherHasIg  = (isA ? data["hasInstagramB"] : data["hasInstagramA"]) as? Bool   ?? true
                let createdAt   = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                return MutualMatch(
                    id: doc.documentID,
                    otherUserId: otherUid,
                    otherUserName: otherName,
                    otherUserInstagram: otherIg,
                    otherUserHasInstagram: otherHasIg,
                    createdAt: createdAt
                )
            }
            return matches.sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("fetchMatches failed: \(error)")
            return []
        }
    }

    // MARK: - IG Lazy Backfill

    static func instagramOrDefault(data: [String: Any]) -> String {
        if let stored = data["instagram"] as? String, !stored.isEmpty {
            return stored
        }
        let name = data["name"] as? String ?? ""
        let first = name.split(separator: " ").first.map(String.init) ?? name
        let cleaned = first
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
        return cleaned.isEmpty ? "@user" : "@\(cleaned)"
    }

    // MARK: - Fetch My Rank

    func fetchMyRank(uid: String) async -> Int {
        do {
            let myDoc   = try await db.collection("users").document(uid).getDocument()
            let myScore = myDoc.data()?["personalScore"] as? Int ?? 0
            let higherUsers = try await db.collection("users")
                .whereField("personalScore", isGreaterThan: myScore)
                .getDocuments()
            return higherUsers.documents.count + 1
        } catch {
            print("rank fetch failed:", error)
            return -1
        }
    }
    
    // MARK. - Duplicate Vote
    func loadVotedUserIDs() async {
        guard !currentUserUID.isEmpty else { return }
        do {
            let snapshot = try await db.collection("votes")
                .whereField("voterId", isEqualTo: currentUserUID)
                .getDocuments()
            let ids = snapshot.documents.compactMap { $0.data()["targetUserId"] as? String }
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
        await MainActor.run { self.isLoadingCandidates = true }
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
    
    static func profile(from doc: QueryDocumentSnapshot, rank: Int) -> UserProfile {
        let data = doc.data()
        var p = UserProfile()
        p.id            = doc.documentID
        p.name          = data["name"]          as? String ?? ""
        p.mbti          = data["mbti"]          as? String ?? ""
        p.rizzHobbies   = (data["rizzHobbies"]  as? [String] ?? []).joined(separator: ", ")
        p.anthem        = data["anthem"]        as? String ?? ""
        p.routine       = data["routine"]       as? String ?? ""
        p.homeTurf      = data["homeTurf"]      as? String ?? ""
        p.major         = data["major"]         as? String ?? ""
        p.coreVibe      = data["coreVibe"]      as? String ?? ""
        p.funFact       = data["funFact"]       as? String ?? ""
        p.personalScore = data["personalScore"] as? Int ?? 0
        p.smashCount    = data["smashCount"]    as? Int ?? 0
        p.passCount     = data["passCount"]     as? Int ?? 0
        p.rank          = rank
        return p
    }
    
}
