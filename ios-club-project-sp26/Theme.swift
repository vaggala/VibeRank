// VibeRank - Theme file
import SwiftUI

// App colors:

struct AppTheme {
    // Background Color
    static let bg = Color(hex: "0F0D1A")
    static let card = Color(hex: "1A1728")
    static let cardBorder = Color(hex: "2A2640")
    static let surface = Color(hex: "231F35")
    
    // Highlights
    static let purple = Color(hex: "7C3AED")
    static let purpleDark = Color(hex: "4C1D95")
    static let pink = Color(hex: "EC4899")
    static let orange = Color(hex: "F97316")
    static let green = Color(hex: "10B981")
    static let red = Color(hex: "EF4444")
    static let yellow = Color(hex: "EAB308")
    static let blue = Color(hex: "3B82F6")
    
    // Text
    static let text = Color(hex: "F1F0F5")
    static let textDim = Color(hex: "9B97B0")
    static let textMuted = Color(hex: "6B6780")
    
    // Leaderboard(Top 3)
    static let gold = Color(hex: "FFD700")
    static let silver = Color(hex: "C0C0C0")
    static let bronze = Color(hex: "CD7F32")
    
}

// Hex Color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
