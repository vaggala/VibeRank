# iOS Club SP26 — Group 3 (VibeRank)

VibeRank is a college social app that takes the classic "smash or pass" concept but replaces judging people on looks or boring, surface-level profiles with personality-driven prompts that actually capture how someone feels, not just who they are on paper. 

Instead of a name and a major, your profile is built around things like your MBTI, your "delusional anthem," your unhinged daily routine, and your core vibe. Other users then swipe on those profiles, voting "Smash" (they vibe with you) or "Pass" (they don't). Every smash adds 100 points to that person's score, and everyone is ranked on a live leaderboard based on their total points.

VibeRank gives college students a fun way to show off their personality and find out who vibes with them.

## Features

- Firebase email/password auth with onboarding flow
- Rich user profiles (MBTI, hobbies, anthem, core vibe, Instagram, etc.)
- Swipeable smash / pass / skip voting mechanic
- Real-time leaderboard synced via Firestore listeners
- Editable profile with live updates
- Meme sound effects, particle bursts, and animated emoji reactions on every vote
- Mutual-smash detection with a glowing Instagram-reveal popup
- Profile tab list of every mutual-smash Instagram handle you've earned

## Stack
- SwiftUI (iOS 17+)
- Firebase Auth + Firestore
- Xcode 16+

## Getting Started

1. Clone the repo
2. Open `ios-club-project-sp26.xcodeproj` in Xcode
3. Build and run (Firebase config is already included)

## Architecture

The app uses a **single-source-of-truth** pattern. One `@Observable` class — `FirebaseService.shared` — holds all app state and owns all Firestore/Auth traffic. Views bind to it directly with `@State private var service = FirebaseService.shared` — no separate view models, no intermediate state containers.

```
┌──────────────────────────────────────────────────────┐
│  Views (SwiftUI)                                      │
│  ContentView, LoginView, OnboardingView, HomeView,    │
│  VoteView, ProfileView, EditProfileView               │
│           ↓ binds to                                  │
├──────────────────────────────────────────────────────┤
│  FirebaseService.shared  (@Observable singleton)      │
│  ─ Auth state: currentUser, isLoggedIn,               │
│    needsOnboarding, errorMessage, isLoading           │
│  ─ Voting state: allProfiles, currentVoteIndex,       │
│    totalVotes, userRank                               │
│  ─ Listeners: auth / profile / leaderboard            │
│  ─ Actions: signUp, signIn, signOut, saveProfile,     │
│    vote, submitVote, fetchMyRank, fetchMatches,       │
│    detectAndWriteMutualMatch                          │
│           ↓ writes / reads                            │
├──────────────────────────────────────────────────────┤
│  Firebase (cloud): Auth + Firestore                   │
│  Collections: users, votes, matches                   │
└──────────────────────────────────────────────────────┘
```

### Data flow

- **Launch** — `FirebaseService.init()` attaches an `Auth.auth().addStateDidChangeListener`. If the user is already signed in, a profile listener hydrates `currentUser` from Firestore and flips `isLoggedIn` on.
- **Sign up / in** — `service.signUp()` / `signIn()` hit Firebase Auth; the state listener above takes care of populating `currentUser` and routing `ContentView` to the right screen.
- **Onboarding** — new users see the 10-step wizard (`OnboardingView`), with the final step asking for their Instagram handle plus an "I don't have Instagram" checkbox. On submit, `service.saveProfile(draft)` writes the full doc and clears `needsOnboarding`.
- **Voting** — `VoteView.swipeAway(...)` triggers haptic + sound + particle + emoji overlays, then calls `service.vote(type, targetID:, onMutualMatch:)`. That does an optimistic local update of `allProfiles` and fires a Firestore transaction in `submitVote()` for atomic score/count updates.
- **Mutual match** — after a smash is written, `submitVote` queries for a reciprocal smash. If found, it writes a single doc to the `matches` collection (doc ID = sorted UID pair, so it's idempotent) and invokes the `onMutualMatch` callback. `VoteView` queues the match while the emoji reaction finishes playing, then presents `MutualMatchView` — a glowing popup showing the other user's Instagram handle (or a "no Instagram" fallback if they opted out).
- **Leaderboard** — `startListeningLeaderboard()` attaches a real-time Firestore listener on the top 20 users by score; `allProfiles` (and therefore `HomeView`) updates automatically when anyone scores.
- **Profile tab** — on appear, `ProfileView` calls `service.fetchMatches(for: uid)` which queries `matches` where `participants` array-contains the current user. The denormalized match docs already carry each participant's name + IG snapshot, so the list renders from a single query.
- **IG backfill** — existing users without an `instagram` field get a lazy `@<firstname>` default via `FirebaseService.instagramOrDefault(data:)` on every read. No migration script; new saves overwrite the default with the real handle.
- **Sign out** — `service.signOut()` removes all listeners, resets state, and `ContentView` falls back to `LoginView`.

## File Structure

```
ios-club-project-sp26/
├── ios_club_project_sp26App.swift    # App entry point; configures Firebase on launch
├── Theme.swift                       # AppTheme colors, hex utilities, dark-mode palette
├── GoogleService-Info.plist          # Firebase client configuration
│
├── Models/
│   ├── FirebaseService.swift         # @Observable singleton — all app state + Firestore/Auth traffic, mutual-match detection
│   ├── Models.swift                  # UserProfile struct (with initials/accentColor helpers, instagram + hasInstagram) + VoteType enum
│   ├── Vote.swift                    # Vote record struct (voter, target, type, timestamp)
│   ├── MutualMatch.swift             # MutualMatch view-model + pairDocId helper for idempotent match IDs
│   ├── SoundPlayer.swift             # AVAudioPlayer wrapper; returns the duration of each clip
│   └── VoteReaction.swift            # Emoji reaction pool — picks a random reaction + sound per VoteType
│
├── Sounds/
│   └── *.mp3                         # Meme sound clips played on each vote
│
└── Views/
    ├── ContentView.swift             # Root view — routes between Login, Onboarding, and main tab bar
    ├── LoginView.swift               # Email/password sign-in and sign-up form
    ├── OnboardingView.swift          # Multi-step first-time profile setup wizard, including Instagram step with no-IG checkbox
    ├── HomeView.swift                # Landing screen — user header, start-voting button, live leaderboard
    ├── VoteView.swift                # Swipe-to-vote card + haptics, sound, particle burst, emoji reactions, mutual-match popup
    ├── ProfileView.swift             # Current user's profile display with stats, details, and mutual-smash Instagram list
    ├── EditProfileView.swift         # Edit form for updating profile fields (including Instagram + no-IG checkbox)
    ├── ParticleBurstView.swift       # Radial particle animation triggered on each vote
    ├── VoteReactionView.swift        # Full-screen emoji reaction overlay synced to sound length
    ├── MutualMatchView.swift         # Glowing celebration popup shown after a mutual smash, revealing the other user's Instagram
    └── SharedComponents.swift        # Reusable UI pieces (avatars, cards, buttons, rank badge)
```
