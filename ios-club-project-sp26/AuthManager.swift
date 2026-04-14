import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@Observable
class AuthManager {
    var currentUser: UserProfile? = nil
    var isLoggedIn: Bool = false
    var needsOnboarding: Bool = false
    var errorMessage: String = ""
    var isLoading: Bool = false

    private let db = Firestore.firestore()
    private var profileListener: ListenerRegistration?

    init() {
        // Restore session on app launch
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let uid = firebaseUser?.uid {
                self?.loadUserProfile(uid: uid)
            } else {
                DispatchQueue.main.async {
                    self?.isLoggedIn = false
                    self?.currentUser = nil
                    self?.needsOnboarding = false
                }
            }
        }
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
            // Auth listener will call loadUserProfile automatically
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
        try? Auth.auth().signOut()
        isLoggedIn = false
        currentUser = nil
        needsOnboarding = false
    }

    // MARK: - Save Profile to Firestore

    func saveProfile(_ profile: UserProfile) async {
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
            "personalScore": profile.personalScore,
            "smashCount":    profile.smashCount,
            "passCount":     profile.passCount
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

    // MARK: - Load Profile from Firestore (real-time listener)

    private func loadUserProfile(uid: String) {
        // Remove any existing listener first
        profileListener?.remove()

        profileListener = db.collection("users").document(uid)
            .addSnapshotListener { [weak self] doc, _ in
                DispatchQueue.main.async {
                    guard let doc = doc, doc.exists, let data = doc.data() else {
                        // Logged in but no profile yet → onboarding
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

                    self?.currentUser = profile
                    self?.isLoggedIn = true
                    self?.needsOnboarding = false
                }
            }
    }
}
