// Define all data structures

import SwiftUI

// 1. Profile Model
struct Profile: Identifiable {
    let id: UUID
    let initials: String
    let name: String
    let age: Int
    let location: String
    let vibe: String
    let major: String
    let favSong: String
    let origin: String
    let mbti: String
    let routine: String
    let hobbies: String
    let funFact: String
    let accentColor: Color
    var score: Int
    var smashes: Int
    var passes: Int
    
    init(
        initials: String, name: String, age: Int, location: String,
        vibe: String, major: String, favSong: String, origin: String,
        mbti: String, routine: String, hobbies: String, funFact: String,
        accentColor: Color, score: Int, smashes: Int, passes: Int
    ) {
        self.id = UUID()
        self.initials = initials
        self.name = name
        self.age = age
        self.location = location
        self.vibe = vibe
        self.major = major
        self.favSong = favSong
        self.origin = origin
        self.mbti = mbti
        self.routine = routine
        self.hobbies = hobbies
        self.funFact = funFact
        self.accentColor = accentColor
        self.score = score
        self.smashes = smashes
        self.passes = passes
    }
}

// 2. Vote Type
enum VoteType {
    case smash
    case pass
    case skip
}

// 3. app data
@Observable
class AppData {
    
    // current login user data
    var currentUser = UserProfile(
        initials: "JK", name: "Jordan Kim", age: 21,
        location: "Atlanta, GA", vibe: "Golden Hour Vibes",
        vibeDesc: "calm but make it iconic",
        major: "Business & Design (Double Major)",
        school: "Georgia Tech", mbti: "INFJ",
        favSong: "\"Golden Hour\" by JVKE",
        origin: "Seoul, South Korea",
        routine: "Morning runs + iced matcha",
        accentColor: AppTheme.purple,
        score: 847, rank: 4, smashes: 124, passes: 38
    )
    
    // All profiles
    var profiles: [Profile] = SampleData.profiles
    
    var currentVoteIndex: Int = 0
    var totalVotes: Int = 12
    
    // Leaderboard
    var leaderboard: [Profile] {
        profiles.sorted { $0.score > $1.score }
    }
    
    // currently voted profile
    var currentProfile: Profile? {
        guard !profiles.isEmpty else { return nil }
        return profiles[currentVoteIndex % profiles.count]
    }
    
    // logic
    func vote(_ type: VoteType) {
        guard let current = currentProfile,
              let index = profiles.firstIndex(where: { $0.id == current.id }) else { return }
        
        switch type {
        case .smash:
            profiles[index].score += 15
            profiles[index].smashes += 1
        case .pass:
            profiles[index].score -= 5
            profiles[index].passes += 1
        case .skip:
            break
        }
        
        currentVoteIndex += 1
        totalVotes += 1
    }
}
 
// MARK: - User Profile (Current User)
struct UserProfile {
    let initials: String
    let name: String
    let age: Int
    let location: String
    let vibe: String
    let vibeDesc: String
    let major: String
    let school: String
    let mbti: String
    let favSong: String
    let origin: String
    let routine: String
    let accentColor: Color
    var score: Int
    var rank: Int
    var smashes: Int
    var passes: Int
}
 
// MARK: - Sample Data
struct SampleData {
    static let profiles: [Profile] = [
        Profile(
            initials: "AM", name: "Alex Morales", age: 22, location: "Atlanta, GA",
            vibe: "Main Character Energy", major: "Computer Science",
            favSong: "Blinding Lights", origin: "Puerto Rico", mbti: "ENFP",
            routine: "Morning person", hobbies: "Dance, coding",
            funFact: "I once ate 12 tacos in one sitting",
            accentColor: AppTheme.purple, score: 1204, smashes: 189, passes: 42
        ),
        Profile(
            initials: "SR", name: "Sam Rivera", age: 20, location: "Miami, FL",
            vibe: "Chill & Mysterious", major: "Psychology",
            favSong: "Sweater Weather", origin: "Colombia", mbti: "INTJ",
            routine: "Night owl", hobbies: "Guitar, journaling",
            funFact: "I can solve a Rubik's cube in under 2 minutes",
            accentColor: AppTheme.blue, score: 1098, smashes: 164, passes: 51
        ),
        Profile(
            initials: "CT", name: "Casey Tran", age: 21, location: "San Jose, CA",
            vibe: "Creative Chaos", major: "Art & Design",
            favSong: "Redbone", origin: "Vietnam", mbti: "INFP",
            routine: "Whenever I wake up", hobbies: "Painting, skating",
            funFact: "I've been to 14 countries before turning 21",
            accentColor: AppTheme.yellow, score: 976, smashes: 145, passes: 58
        ),
        Profile(
            initials: "RB", name: "Riley Brooks", age: 23, location: "Chicago, IL",
            vibe: "Night Owl Scholar", major: "Physics",
            favSong: "Starboy", origin: "Nigeria", mbti: "INTP",
            routine: "2am study sessions", hobbies: "Chess, stargazing",
            funFact: "I memorized 200 digits of pi for fun",
            accentColor: AppTheme.green, score: 801, smashes: 120, passes: 64
        ),
        Profile(
            initials: "ML", name: "Morgan Lee", age: 19, location: "Seattle, WA",
            vibe: "Soft & Bold", major: "English Literature",
            favSong: "Cruel Summer", origin: "South Korea", mbti: "ENFJ",
            routine: "Morning yoga + tea", hobbies: "Writing, hiking",
            funFact: "I once read 52 books in one year",
            accentColor: AppTheme.pink, score: 774, smashes: 112, passes: 70
        ),
        Profile(
            initials: "DP", name: "Dakota Price", age: 22, location: "Austin, TX",
            vibe: "Chaos Coordinator", major: "Business",
            favSong: "HUMBLE.", origin: "Texas", mbti: "ESTP",
            routine: "Gym at 6am sharp", hobbies: "Basketball, cooking",
            funFact: "I accidentally started a viral TikTok trend",
            accentColor: AppTheme.orange, score: 752, smashes: 108, passes: 73
        ),
    ]
}
