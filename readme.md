# iOS Club SP26 — Group 3 (VibeRank)

A SwiftUI iOS app built for the Spring 2026 iOS Club project. Users build a vibe profile, swipe smash/pass on others, and climb a live leaderboard.

## Features

- Firebase email/password auth with onboarding flow
- Rich user profiles (MBTI, hobbies, anthem, core vibe, etc.)
- Swipeable smash / pass / skip voting mechanic
- Real-time leaderboard synced via Firestore listeners
- Editable profile with live updates

## Stack

- SwiftUI (iOS 17+)
- Firebase Auth + Firestore
- Xcode 16+

## Getting Started

1. Clone the repo
2. Open `ios-club-project-sp26.xcodeproj` in Xcode
3. Build and run (Firebase config is already included)

## File Structure

```
ios-club-project-sp26/
├── ios_club_project_sp26App.swift   # App entry point; configures Firebase on launch
├── Theme.swift                      # AppTheme colors, hex utilities, dark-mode palette
├── GoogleService-Info.plist         # Firebase client configuration
│
├── Models/
│   ├── Models.swift                 # UserProfile struct, VoteType enum, AppData observable (leaderboard + vote feed)
│   └── AuthManager.swift            # @Observable auth state — sign up, sign in, session restore, onboarding flag
│
└── Views/
    ├── ContentView.swift            # Root view — routes between Login, Onboarding, and main tab bar
    ├── LoginView.swift              # Email/password sign-in and sign-up form
    ├── OnboardingView.swift         # Multi-step first-time profile setup wizard
    ├── HomeView.swift               # Landing screen — user header, start-voting button, leaderboard preview
    ├── VoteView.swift               # Swipe-to-vote card UI with drag gestures and smash/pass buttons
    ├── ProfileView.swift            # Current user's profile display with stats and details
    ├── EditProfileView.swift        # Edit form for updating profile fields
    └── SharedComponents.swift       # Reusable UI pieces (avatars, cards, buttons)
```
