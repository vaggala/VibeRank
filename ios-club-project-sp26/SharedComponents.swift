// Reusable components

import SwiftUI

// Avatar - profile
struct AvatarView: View {
    let initials: String
    let color: Color
    var size: CGFloat = 44
    var showGlow: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(color: showGlow ? color.opacity(0.4) : .clear, radius: 12)
            
            Text(initials)
                .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// Vote action buttons
struct VoteActionButton: View {
    let icon: String
    let label: String
    let color: Color
    var size: CGFloat = 58
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .stroke(color, lineWidth: 2.5)
                        .frame(width: size, height: size)
                    
                    Circle()
                        .fill(color.opacity(isPressed ? 0.15 : 0))
                        .frame(width: size, height: size)
                    
                    Image(systemName: icon)
                        .font(.system(size: size * 0.35, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Info Grid Cell
struct InfoGridCell: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textMuted)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.text)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.bg)
    }
}

// Rank Badge
struct RankBadge: View {
    let rank: Int
    
    var rankText: String {
        switch rank {
        case 1: return "1st"
        case 2: return "2nd"
        case 3: return "3rd"
        default: return "\(rank)th"
        }
    }
    
    var rankColor: Color {
        switch rank {
        case 1: return AppTheme.gold
        case 2: return AppTheme.silver
        case 3: return AppTheme.bronze
        default: return AppTheme.textDim
        }
    }
    
    var body: some View {
        Text(rankText)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(rankColor)
            .frame(width: 32)
    }
}

// Card Modifier
struct CardModifier: ViewModifier {
    var highlighted: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        highlighted ? AppTheme.purple.opacity(0.4) : AppTheme.cardBorder,
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func cardStyle(highlighted: Bool = false) -> some View {
        modifier(CardModifier(highlighted: highlighted))
    }
}

