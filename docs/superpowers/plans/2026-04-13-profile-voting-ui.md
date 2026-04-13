# Profile + Voting Screens UI — Implementation Plan

> **For Grace (learning mode):** Each task includes a **Concepts** section explaining the Swift/SwiftUI ideas used. Walk through steps with Claude — you type, he explains. Steps use checkbox (`- [ ]`) for tracking. No auto-commits; you commit when you want.

**Goal:** Build `ProfileView` and `VotingView` matching the Figma designs, wired to existing data where possible, with a new `VotingViewModel` that stubs backend calls for later wiring.

**Architecture:** Two SwiftUI views + one ViewModel. Each view broken into small sub-structs in the same file for readability. Data flow: ProfileView reads existing `ProfileViewModel` from environment; VotingView owns a new `VotingViewModel`. Missing profile fields hardcoded as local constants with `// TODO:` comments.

**Tech Stack:** SwiftUI, Swift 5.9+ (`@Observable`), Xcode 15+

**Spec:** `docs/superpowers/specs/2026-04-13-profile-voting-ui-design.md`

---

## Task 1: Create empty files and scaffold previews

**Files:**
- Create: `ios-club-project-sp26/Views/ProfileView.swift`
- Create: `ios-club-project-sp26/Views/VotingView.swift`

**Concepts:**
- Every SwiftUI screen is a `struct` that conforms to `View` and has a `var body: some View { ... }`
- `#Preview { ... }` is a special block at the bottom of a file that renders the view in Xcode's canvas without building to the simulator. Great for fast iteration.
- A view called `Text("Hello")` just displays text — we use this as a placeholder.

**Steps:**

- [ ] **Step 1.1:** In Xcode, right-click the `Views` folder → New File → SwiftUI View → name it `ProfileView` → Create.

- [ ] **Step 1.2:** Replace the generated code with:

```swift
import SwiftUI

struct ProfileView: View {
    var body: some View {
        Text("Profile — coming soon")
    }
}

#Preview {
    ProfileView()
}
```

- [ ] **Step 1.3:** Repeat 1.1–1.2 for `VotingView`:

```swift
import SwiftUI

struct VotingView: View {
    var body: some View {
        Text("Voting — coming soon")
    }
}

#Preview {
    VotingView()
}
```

- [ ] **Step 1.4:** Open each file and check the Preview canvas appears (right side of Xcode). Click "Resume" if prompted. You should see the placeholder text.

---

## Task 2: Wire the new views into the tab bar

**Files:**
- Modify: `ios-club-project-sp26/Views/ContentView.swift`

**Concepts:**
- `TabView` in SwiftUI manages tabs. Each child view is a tab.
- `.tag(0)` identifies the tab for programmatic selection. `.tabItem { ... }` sets the icon and label.

**Steps:**

- [ ] **Step 2.1:** Open `ContentView.swift`. Find `VotingPage()` inside the `TabView` and change it to `VotingView()`. Same for `ProfilePage()` → `ProfileView()`.

- [ ] **Step 2.2:** Scroll to the bottom of the file and delete the entire `struct VotingPage: View { ... }` block and the entire `struct ProfilePage: View { ... }` block. Leave `LeaderboardPage` alone.

- [ ] **Step 2.3:** Build (`⌘ + R`). Tap the middle and rightmost tabs — you should see your placeholder text from Task 1.

---

## Task 3: Build ProfileHeader (purple top section)

**Files:**
- Modify: `ios-club-project-sp26/Views/ProfileView.swift`

**Concepts:**
- `VStack` stacks children **vertically**. `HStack` horizontally. `ZStack` layers them front-to-back.
- View modifiers like `.padding`, `.background`, `.foregroundColor` are applied with dot syntax and return a new view. Order matters! `.padding().background(.red)` vs `.background(.red).padding()` look different.
- `Circle()`, `RoundedRectangle()`, `Text()` are "shape/content" views.
- `.frame(width:height:)` sets size. `.frame(maxWidth: .infinity)` stretches to full width.

**Steps:**

- [ ] **Step 3.1:** At the top of `ProfileView.swift`, define local constants for the hardcoded fields. Put this right above `struct ProfileView`:

```swift
// TODO: move these to User model when backend extends
private let hardcodedInitials = "JK"
private let hardcodedCity = "Atlanta, GA"
private let hardcodedAge = 21
```

- [ ] **Step 3.2:** Replace `ProfileView`'s body with a `VStack` containing a `ProfileHeader` sub-view (we'll define the sub-view next):

```swift
struct ProfileView: View {
    @Environment(ProfileViewModel.self) var vm

    var body: some View {
        VStack(spacing: 0) {
            ProfileHeader(
                initials: hardcodedInitials,
                name: vm.user?.name ?? "Jordan Kim",
                city: hardcodedCity,
                age: hardcodedAge
            )
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}
```

- [ ] **Step 3.3:** Below `ProfileView`, add the `ProfileHeader` struct:

```swift
struct ProfileHeader: View {
    let initials: String
    let name: String
    let city: String
    let age: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    )

                Text(name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("\(city) · \(age) y/o")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 16)

            Button(action: { print("edit tapped") }) {
                Text("Edit")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.2)))
            }
            .padding(16)
        }
        .background(Color(red: 0.45, green: 0.4, blue: 0.85))
    }
}
```

- [ ] **Step 3.4:** Update the `#Preview` block to inject a mock ProfileViewModel (since the view expects one from the environment):

```swift
#Preview {
    ProfileView()
        .environment(ProfileViewModel())
}
```

- [ ] **Step 3.5:** Check the canvas. You should see the purple header with avatar circle (initials), name, location, and an "Edit" button top-right.

---

## Task 4: Build StatsRow (4 stat tiles)

**Files:**
- Modify: `ios-club-project-sp26/Views/ProfileView.swift`

**Concepts:**
- `HStack` with equal spacing creates a horizontal row. `.frame(maxWidth: .infinity)` on children makes them split space evenly.
- `ForEach` renders a view once per item in a collection.
- Tuple types in Swift: `(label: String, value: String, color: Color)` — quick lightweight data for a static list.

**Steps:**

- [ ] **Step 4.1:** Add more hardcoded constants at the top of the file:

```swift
private let hardcodedSmashes = 124
private let hardcodedPasses = 38
```

- [ ] **Step 4.2:** Below `ProfileHeader`, add a `StatsRow` struct:

```swift
struct StatsRow: View {
    let vibePoints: Int
    let rank: Int
    let smashes: Int
    let passes: Int

    var body: some View {
        HStack(spacing: 0) {
            StatTile(value: "\(vibePoints)", label: "Vibe Pts", color: .orange)
            StatTile(value: "#\(rank)", label: "Rank", color: Color(red: 0.55, green: 0.5, blue: 0.95))
            StatTile(value: "\(smashes)", label: "Smashes", color: Color(red: 0.95, green: 0.45, blue: 0.6))
            StatTile(value: "\(passes)", label: "Passes", color: .gray)
        }
        .background(Color(red: 0.09, green: 0.08, blue: 0.15))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }
}

struct StatTile: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }
}
```

- [ ] **Step 4.3:** In `ProfileView`'s body, add `StatsRow` below `ProfileHeader`:

```swift
VStack(spacing: 0) {
    ProfileHeader(...)
    StatsRow(
        vibePoints: vm.user?.personalScore ?? 847,
        rank: vm.user?.leaderboardRank ?? 4,
        smashes: hardcodedSmashes,
        passes: hardcodedPasses
    )
    .offset(y: -24)      // overlap into the purple header for that floating look
    Spacer()
}
```

- [ ] **Step 4.4:** Check the canvas. You should see a 4-tile stats row floating over the bottom edge of the purple header.

---

## Task 5: Build CoreVibeBanner

**Files:**
- Modify: `ios-club-project-sp26/Views/ProfileView.swift`

**Concepts:**
- `Text` can concatenate with `+`: `Text("bold") + Text("regular")`. Useful for mixed styling inline.
- `.fontWeight(.bold)` makes text bold. `.italic()` makes it italic.

**Steps:**

- [ ] **Step 5.1:** Add more hardcoded constants:

```swift
private let hardcodedCoreVibe = "Golden Hour Vibes"
private let hardcodedVibeSubtitle = "calm but make it iconic"
```

- [ ] **Step 5.2:** Below `StatTile`, add `CoreVibeBanner`:

```swift
struct CoreVibeBanner: View {
    let vibe: String
    let subtitle: String

    var body: some View {
        HStack {
            (Text("Core vibe: ")
                .foregroundColor(.white.opacity(0.6))
             + Text(vibe).bold().foregroundColor(.white)
             + Text(" · \(subtitle)").foregroundColor(.white.opacity(0.6)))
                .font(.system(size: 14))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.09, green: 0.08, blue: 0.15))
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}
```

- [ ] **Step 5.3:** Add it to `ProfileView`'s body below `StatsRow`:

```swift
CoreVibeBanner(vibe: hardcodedCoreVibe, subtitle: hardcodedVibeSubtitle)
    .offset(y: -16)
```

- [ ] **Step 5.4:** Check the canvas.

---

## Task 6: Build InfoList + InfoCard

**Files:**
- Modify: `ios-club-project-sp26/Views/ProfileView.swift`

**Concepts:**
- `ScrollView` enables vertical scrolling when content overflows.
- `LazyVStack` renders children as they become visible (more efficient than `VStack` for long lists).
- `ForEach` with `id: \.self` uses the item itself as the identifier (works for strings). When the data has an `id` property, SwiftUI uses that.

**Steps:**

- [ ] **Step 6.1:** At the top, add hardcoded info cards data (an array of tuples):

```swift
private let hardcodedInfoCards: [(label: String, value: String, color: Color)] = [
    ("Major",    "Business & Design (Double Major)", .purple),
    ("School",   "Georgia Tech",                     .purple),
    ("MBTI",     "INFJ",                             .purple),
    ("Fav Song", "\"Golden Hour\" by JVKE",          .green),
    ("Origin",   "Seoul, South Korea",               .green),
    ("Routine",  "Morning runs + iced matcha",       .orange)
]
```

- [ ] **Step 6.2:** Below `CoreVibeBanner`, add `InfoCard` and `InfoList`:

```swift
struct InfoCard: View {
    let label: String
    let value: String
    let dotColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(dotColor).frame(width: 8, height: 8).padding(.top, 6)
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(16)
        .background(Color(red: 0.09, green: 0.08, blue: 0.15))
        .cornerRadius(12)
    }
}

struct InfoList: View {
    let cards: [(label: String, value: String, color: Color)]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(cards, id: \.label) { card in
                InfoCard(label: card.label, value: card.value, dotColor: card.color)
            }
        }
        .padding(.horizontal, 16)
    }
}
```

- [ ] **Step 6.3:** Wrap `ProfileView`'s body in a `ScrollView`:

```swift
var body: some View {
    ScrollView {
        VStack(spacing: 0) {
            ProfileHeader(...)
            StatsRow(...).offset(y: -24)
            CoreVibeBanner(...).offset(y: -16)
            InfoList(cards: hardcodedInfoCards)
            Spacer().frame(height: 40)
        }
    }
    .background(Color.black.ignoresSafeArea())
}
```

- [ ] **Step 6.4:** Check canvas + simulator. Scroll through the list. This completes the profile screen.

---

## Task 7: Create VotingViewModel with mock data

**Files:**
- Create: `ios-club-project-sp26/ViewModels/VotingViewModel.swift`

**Concepts:**
- `@Observable` is Swift's modern way to make a class observable to SwiftUI. When a property changes, views using it re-render automatically.
- `enum` in Swift is a type with a fixed set of cases. `enum VoteType { case pass, skip, smash }`.
- `struct` is a value type — copied when passed around. Fine for simple data like `VoteTarget`.
- `Identifiable` protocol requires a unique `id` — lets `ForEach` know how to identify each item.
- `static let` defines a constant that belongs to the type itself (not instances). `VoteTarget.mockQueue` vs `someTarget.mockQueue`.

**Steps:**

- [ ] **Step 7.1:** In Xcode, right-click the `ViewModels` folder → New File → Swift File → name it `VotingViewModel.swift`.

- [ ] **Step 7.2:** Paste in the full file:

```swift
import Foundation

enum VoteType {
    case pass, skip, smash
}

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
    let vibeMatch: Int     // 0...30

    static let mockQueue: [VoteTarget] = [
        VoteTarget(name: "Alex Morales", initials: "AM", age: 22, city: "Atlanta, GA",
                   tagline: "Main Character Energy", major: "Computer Science",
                   favSong: "Blinding Lights", origin: "Puerto Rico", mbti: "ENFP",
                   routine: "Morning person", hobbies: "Dance, coding",
                   funFact: "I once ate 12 tacos in one sitting", vibeMatch: 12),

        VoteTarget(name: "Sam Rivera", initials: "SR", age: 20, city: "Austin, TX",
                   tagline: "Chill & Mysterious", major: "Philosophy",
                   favSong: "Redbone", origin: "Mexico City", mbti: "INTP",
                   routine: "Night owl", hobbies: "Reading, chess",
                   funFact: "Can solve a Rubik's cube in under a minute", vibeMatch: 25),

        VoteTarget(name: "Casey Tran", initials: "CT", age: 23, city: "Los Angeles, CA",
                   tagline: "Creative Chaos", major: "Film Studies",
                   favSong: "Glimpse of Us", origin: "Hanoi, Vietnam", mbti: "ENFJ",
                   routine: "Late mornings", hobbies: "Painting, skating",
                   funFact: "Has been to 17 concerts this year", vibeMatch: 8)
    ]
}

@Observable
class VotingViewModel {
    var queue: [VoteTarget] = []
    var currentIndex: Int = 0

    init() {
        loadQueue()
    }

    func loadQueue() {
        // TODO: swap to FirebaseService.fetchVotingQueue() when backend merges
        queue = VoteTarget.mockQueue
    }

    func vote(_ type: VoteType) {
        guard !queue.isEmpty else { return }
        print("voted \(type) on \(queue[currentIndex].name)")
        // TODO: wire to FirebaseService.submitVote() when MT merges
        advance()
    }

    private func advance() {
        guard !queue.isEmpty else { return }
        currentIndex = (currentIndex + 1) % queue.count
    }

    var currentTarget: VoteTarget? {
        guard !queue.isEmpty, currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }
}
```

- [ ] **Step 7.3:** Build (`⌘ + B`). Should compile with no errors.

---

## Task 8: Build VoteProgressHeader (vibe match bar)

**Files:**
- Modify: `ios-club-project-sp26/Views/VotingView.swift`

**Concepts:**
- `GeometryReader` gives you the available space so you can compute child sizes proportionally — useful for progress bars.
- Alternative: `Rectangle().frame(width: barWidth)` where `barWidth` is computed.
- `Double(Int) / Double(Int)` — Swift doesn't auto-convert numeric types.

**Steps:**

- [ ] **Step 8.1:** Replace `VotingView.swift` contents with:

```swift
import SwiftUI

struct VotingView: View {
    @State private var vm = VotingViewModel()

    var body: some View {
        VStack(spacing: 16) {
            if let target = vm.currentTarget {
                VoteProgressHeader(vibeMatch: target.vibeMatch)
                Text("Voting card here")  // placeholder for next task
                Spacer()
                Text("Action buttons here")  // placeholder
            } else {
                Text("No users to vote on")
            }
        }
        .padding(16)
        .background(Color.white.ignoresSafeArea())
    }
}

struct VoteProgressHeader: View {
    let vibeMatch: Int    // 0...30
    let maxMatch: Int = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Does their energy match yours?")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.55, green: 0.5, blue: 0.95))
                        .frame(
                            width: geo.size.width * (Double(vibeMatch) / Double(maxMatch)),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            Text("\(vibeMatch) / \(maxMatch)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.55, green: 0.5, blue: 0.95))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    VotingView()
}
```

- [ ] **Step 8.2:** Check canvas. You should see the purple progress bar filled proportionally to 12/30.

---

## Task 9: Build VotingCard (main card)

**Files:**
- Modify: `ios-club-project-sp26/Views/VotingView.swift`

**Concepts:**
- `LazyVGrid` lays out items in a grid. `GridItem(.flexible())` makes columns resize.
- Views can be composed deeply — one `View` struct inside another is idiomatic SwiftUI.

**Steps:**

- [ ] **Step 9.1:** Replace the `Text("Voting card here")` placeholder in `VotingView`'s body with `VotingCard(target: target)`.

- [ ] **Step 9.2:** Below `VoteProgressHeader`, add three new view structs:

```swift
struct VotingCard: View {
    let target: VoteTarget

    var body: some View {
        VStack(spacing: 0) {
            CardHeader(target: target)
            VStack(spacing: 12) {
                InfoGrid(target: target)
                FunFactBanner(text: target.funFact)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.09, green: 0.08, blue: 0.15))
        }
        .cornerRadius(20)
    }
}

struct CardHeader: View {
    let target: VoteTarget

    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)
                .overlay(
                    Text(target.initials)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                )

            Text(target.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)

            Text("\(target.age) · \(target.city)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))

            Text(target.tagline)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.2)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(red: 0.45, green: 0.4, blue: 0.85))
    }
}

struct InfoGrid: View {
    let target: VoteTarget

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            InfoTile(label: "Major", value: target.major)
            InfoTile(label: "Fav Song", value: target.favSong)
            InfoTile(label: "Origin", value: target.origin)
            InfoTile(label: "MBTI", value: target.mbti)
            InfoTile(label: "Routine", value: target.routine)
            InfoTile(label: "Hobbies", value: target.hobbies)
        }
    }
}

struct InfoTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.black)
        .cornerRadius(10)
    }
}

struct FunFactBanner: View {
    let text: String

    var body: some View {
        Text("Fun fact: \(text)")
            .font(.system(size: 13))
            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(red: 0.08, green: 0.12, blue: 0.12))
            .cornerRadius(10)
    }
}
```

- [ ] **Step 9.3:** Check the canvas. You should see the full card with purple header, 2×3 info grid, and fun fact banner.

---

## Task 10: Build VoteActionButtons and wire the vote() action

**Files:**
- Modify: `ios-club-project-sp26/Views/VotingView.swift`

**Concepts:**
- `Button(action: { ... }) { label }` — the braces after `action:` hold the code that runs when tapped. The closing `{ label }` is the visible button content.
- Tapping a button that calls a method on an `@Observable` VM triggers SwiftUI to re-render any view reading the VM's properties.

**Steps:**

- [ ] **Step 10.1:** Replace the `Text("Action buttons here")` placeholder in `VotingView`'s body with `VoteActionButtons(vm: vm)`.

- [ ] **Step 10.2:** Below `FunFactBanner`, add `VoteActionButtons`:

```swift
struct VoteActionButtons: View {
    let vm: VotingViewModel

    var body: some View {
        HStack(spacing: 24) {
            VoteButton(
                icon: "xmark",
                label: "Pass",
                fill: Color.white,
                stroke: Color(red: 0.95, green: 0.4, blue: 0.55),
                iconBg: Color(red: 0.95, green: 0.4, blue: 0.55),
                iconColor: .white
            ) {
                vm.vote(.pass)
            }

            VoteButton(
                icon: "arrow.right",
                label: "Skip",
                fill: Color(red: 0.09, green: 0.08, blue: 0.15),
                stroke: .clear,
                iconBg: .clear,
                iconColor: .gray
            ) {
                vm.vote(.skip)
            }

            VoteButton(
                icon: "heart",
                label: "Smash",
                fill: Color(red: 0.55, green: 0.5, blue: 0.95),
                stroke: .clear,
                iconBg: .clear,
                iconColor: Color(red: 0.3, green: 0.25, blue: 0.7)
            ) {
                vm.vote(.smash)
            }
        }
    }
}

struct VoteButton: View {
    let icon: String
    let label: String
    let fill: Color
    let stroke: Color
    let iconBg: Color
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(fill)
                        .overlay(Circle().stroke(stroke, lineWidth: 2))
                        .frame(width: 68, height: 68)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(fill == Color.white ? Color(red: 0.95, green: 0.4, blue: 0.55) : .white)
            }
        }
    }
}
```

- [ ] **Step 10.3:** Build & run in simulator. Tap each button — the card should swap to the next user and the progress bar should change to that user's `vibeMatch`. Check the Xcode console for `voted pass/skip/smash on <name>` logs.

---

## Task 11: Final pass and polish

**Files:**
- Maybe modify any of the above

**Concepts:**
- Nothing new — this is visual polish.

**Steps:**

- [ ] **Step 11.1:** Run on a simulator. Tap through all three tabs (Leaderboard, Voting, Profile). Verify:
  - Profile: scrolls, shows stats + banner + info list
  - Voting: card changes when buttons tapped; progress bar reflects current user's vibeMatch
  - Edit button on profile prints `"edit tapped"` in the console
  - Tapping vote buttons prints `"voted <type> on <name>"`

- [ ] **Step 11.2:** Compare with Figma side-by-side. Tweak any colors, spacing, or font sizes that feel off. Common tweaks:
  - Stats row tile colors
  - Card corner radius
  - Padding between sections

- [ ] **Step 11.3 (optional):** Decide whether to commit. A reasonable split:
  - Commit 1: "Create ProfileView with header, stats, banner, info list" (Tasks 1–6)
  - Commit 2: "Create VotingView + VotingViewModel with vote stubs" (Tasks 7–10)
  - Or one bigger commit. Your call — you own the branch history.

---

## Scope Recap

**Done when:** both screens match the Figma at ~90% fidelity, `ProfileView` reads real data from `ProfileViewModel` for name/score/rank/mbti/hobbies, `VotingView` cycles through 3 hardcoded users with working buttons that log to console, and all `TODO:` comments are in place for later backend wiring.

**Not done (intentionally):** Edit profile flow, real backend voting calls, new `User` fields, leaderboard changes.
