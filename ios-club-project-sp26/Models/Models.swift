import SwiftUI

// MARK: - Vote Type

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
    var instagram: String = ""
    var hasInstagram: Bool = true
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
