# Profile + Voting Screens UI — Design

**Author:** Grace Chiu
**Date:** 2026-04-13
**Branch:** `grace-profile-voting-ui` (off `main`)
**GitHub issues:** "Create user profile screen UI" + "Create voting screen UI"

## Goal

Build the production UI for two screens — **My Profile** and **Vote** — matching the Figma designs, replacing the placeholder versions currently in `ContentView.swift`. Wire to existing user data where possible; hardcode missing fields in a way that's easy to swap to dynamic data later.

## Scope

**In scope:**
- `ProfileView.swift` — the full profile screen
- `VotingView.swift` — the full voting screen
- `VotingViewModel.swift` — new ViewModel for the voting screen (hardcoded queue, stubbed vote action)
- Replace `ProfilePage` and `VotingPage` placeholders in `ContentView.swift` with the new views

**Out of scope:**
- Leaderboard/Home tab (handled separately)
- Edit-profile flow (the Edit button on Profile is a print-stub)
- Real voting backend (`submitVote`) — that lives on MT branch, will be wired after MT merges
- Extending the `User` model or Firestore schema
- Any changes to Auth, FirebaseService, or existing ProfileViewModel

## Data Approach

- Fields the main `User` model already has (`name`, `mbti`, `hobbies`, `personalScore`, `leaderboardRank`) are read from `ProfileViewModel.user`.
- Fields not in the model (age, city, school, fav song, origin, routine, core vibe, fun fact, smash count, pass count) are hardcoded as local constants at the top of the view, with a `TODO` comment pointing to where they should eventually come from.
- This way, swapping hardcoded → dynamic later is a one-line change per field.

## File Plan

| File | Action |
|------|--------|
| `ios-club-project-sp26/Views/ProfileView.swift` | **Create** |
| `ios-club-project-sp26/Views/VotingView.swift` | **Create** |
| `ios-club-project-sp26/ViewModels/VotingViewModel.swift` | **Create** |
| `ios-club-project-sp26/Views/ContentView.swift` | **Modify** — swap `VotingPage()`/`ProfilePage()` in the `TabView` for new views; delete the two unused placeholder structs |

Nothing else gets touched. `LeaderboardPage` and `LeaderboardRow` stay untouched.

## ProfileView Structure

```
ProfileView (root)
├── ProfileHeader       purple section: avatar, name, city/age, "Edit" button (stub)
├── StatsRow            4 tiles: Vibe Pts / Rank / Smashes / Passes
├── CoreVibeBanner      dark banner: "Core vibe: <tagline> · <subtitle>"
└── InfoList            scrollable list of InfoCard rows
    └── InfoCard        one row: colored dot + field label + field value
```

**Data flow:**
- `@Environment(ProfileViewModel.self) var vm` — already provided by `RootView` on main
- Displays `vm.user?.name`, `vm.user?.personalScore`, `vm.user?.leaderboardRank`, `vm.user?.mbti`, `vm.user?.hobbies`
- All other fields hardcoded as local constants at top of file
- "Edit" button calls `print("edit tapped")` — stub for future edit-profile flow

## VotingView Structure

```
VotingView (root)
├── VoteProgressHeader    "Does their energy match yours?" + vibe-match bar
├── VotingCard            main card
│   ├── CardHeader        avatar, name, age · city, tagline pill
│   ├── InfoGrid          2×3 grid: Major, Fav Song, Origin, MBTI, Routine, Hobbies
│   └── FunFactBanner     green banner at bottom of card
└── VoteActionButtons     3 circular buttons: Pass, Skip, Smash
```

**Data flow:**
- `@State var vm = VotingViewModel()` — owned by this view
- Current user shown: `vm.queue[vm.currentIndex]`
- Vibe match bar fill = `vm.queue[vm.currentIndex].vibeMatch / 30`
- Tapping Pass/Skip/Smash calls `vm.vote(.pass)` etc. → advances index, loops when reaching the end

**Vibe match bar:** represents how closely the viewer's vibe matches the person shown. Scale is fixed at `/30` for now (per design). Stored as `Int` on each `VoteTarget`. May become dynamic later.

## VotingViewModel

```swift
@Observable
class VotingViewModel {
    var queue: [VoteTarget] = []
    var currentIndex: Int = 0

    init() { loadQueue() }

    func loadQueue() {
        // TODO: swap to FirebaseService.fetchVotingQueue() once backend merges
        queue = VoteTarget.mockQueue
    }

    func vote(_ type: VoteType) {
        print("voted \(type) on \(queue[currentIndex].name)")
        // TODO: wire to FirebaseService.submitVote() once MT merges
        advance()
    }

    private func advance() {
        currentIndex = (currentIndex + 1) % queue.count  // loop for demo
    }
}

enum VoteType { case pass, skip, smash }

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
    let vibeMatch: Int  // 0...30

    static let mockQueue: [VoteTarget] = [ /* 3–5 sample users */ ]
}
```

**Why `VoteTarget` is separate from `User`:** `User` on main has ~6 fields; the voting card needs ~12. Adding all of these to `User` would touch a shared model used by teammates. Keeping `VoteTarget` local to `VotingViewModel.swift` isolates the change to this branch.

## Styling Notes

- Dark theme base: near-black card backgrounds (`Color(red: 0.09, green: 0.08, blue: 0.15)`)
- Purple header: approximately `Color(red: 0.45, green: 0.4, blue: 0.85)`
- Stat colors: orange (Vibe Pts), purple (Rank), pink (Smashes), gray (Passes)
- Accent colors follow Figma; fine-tune during implementation
- Use SF Symbols for icons (heart, X, chevron, etc.)

## Testing

- No unit tests for this task (UI-only).
- Verify visually:
  - Xcode Previews (`#Preview` block at the bottom of each file)
  - Build to simulator; tap through tabs; interact with voting buttons

## Swift/SwiftUI Concepts Introduced

Tagged for the implementation session, not things to research up front:

- `struct` vs `class` (Views are structs; ViewModels are classes)
- Layout containers: `VStack`, `HStack`, `ZStack`, `Spacer`
- View modifiers and chaining (`.padding`, `.background`, `.foregroundColor`)
- State property wrappers: `@State`, `@Environment`, `@Observable`
- `ForEach` for rendering lists
- `Button` + closures
- `Image(systemName:)` (SF Symbols)
- `#Preview` blocks
- `enum` with simple cases
- `Identifiable` protocol

## Open Questions / Future Work

- When MT branch merges, swap the TODO-flagged lines in `VotingViewModel.vote()` and `loadQueue()` for real backend calls
- Edit-profile flow is a separate issue
- The `User` model eventually needs the additional fields (age, city, school, fav song, origin, routine, core vibe, fun fact, smashCount, passCount) — track via separate issue
- Re-evaluate `/30` scale once the actual vibe-match algorithm is designed
