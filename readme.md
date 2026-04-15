# iOS Club SP26 — Group 3

A SwiftUI iOS app built for the Spring 2026 iOS Club project.

## Features

- User profiles (MBTI, hobbies, vibe, etc.)
- Smash / pass voting between users
- Live leaderboard ranked by personal score
- Firebase Auth + Firestore backend

## Stack

- SwiftUI
- Firebase (Auth, Firestore)
- Xcode 16+ / iOS 17+

## Getting Started

1. Clone the repo
2. Add your own `GoogleService-Info.plist` to `ios-club-project-sp26/` (gitignored)
3. Open `ios-club-project-sp26.xcodeproj` in Xcode
4. Build and run

## Structure

```
ios-club-project-sp26/
├── Models/      # UserProfile, Vote, FirebaseService, AppData
├── Views/       # Home, Vote, Profile, Login, Onboarding
└── Assets.xcassets
```
