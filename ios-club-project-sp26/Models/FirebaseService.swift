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
        guard !voteProfiles.isEmpty else { return nil }
        return voteProfiles[currentVoteIndex % voteProfiles.count]
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
            "name":        profile.name,
            "mbti":        profile.mbti,
            "rizzHobbies": profile.rizzHobbies.isEmpty ? [] : [profile.rizzHobbies],
            "anthem":      profile.anthem,
            "routine":     profile.routine,
            "homeTurf":    profile.homeTurf,
            "major":       profile.major,
            "coreVibe":    profile.coreVibe,
            "funFact":     profile.funFact
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
                    p.personalScore = data["personalScore"] as? Int ?? 0
                    p.smashCount    = data["smashCount"]    as? Int ?? 0
                    p.passCount     = data["passCount"]     as? Int ?? 0
                    return p
                }
            }
        }
    }

    // MARK: - Vote (optimistic local update + Firestore write)

    func vote(_ type: VoteType, targetID: String = "") {
        switch type {
        case .smash:
            if let index = allProfiles.firstIndex(where: { $0.id == targetID }) {
                allProfiles[index].personalScore += 100
                allProfiles[index].smashCount += 1
            }
            Task { await submitVote(targetUserId: targetID, isSmash: true) }
        case .pass:
            if let index = allProfiles.firstIndex(where: { $0.id == targetID }) {
                allProfiles[index].passCount += 1
            }
            Task { await submitVote(targetUserId: targetID, isSmash: false) }
        case .skip:
            break
        }
        currentVoteIndex += 1
        totalVotes += 1
    }

    // MARK: - Submit Vote (Firestore transaction)

    func submitVote(targetUserId: String, isSmash: Bool) async {
        guard let voterId = Auth.auth().currentUser?.uid else {
            print("submitVote: no logged-in user")
            return
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
        }
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
}
