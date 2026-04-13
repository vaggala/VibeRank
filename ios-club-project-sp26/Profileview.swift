
import SwiftUI

struct ProfileView: View {
    let user: UserProfile
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                editButton
                avatarSection
                statsRow
                coreVibeCard
                profileDetails
            }
            .padding(.horizontal, 16)
        }
    }
    
    // Edit Button
    private var editButton: some View {
        HStack {
            Spacer()
            Button("Edit") {
                // TODO: Edit function
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(AppTheme.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.bottom, 8)
    }
    
    // Avatar & Name
    private var avatarSection: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.purple, AppTheme.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: AppTheme.purple.opacity(0.3), radius: 15)
                
                Text(user.initials)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Text(user.name)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.text)
                .padding(.top, 14)
            
            Text("\(user.location) · \(user.age) y/o")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textDim)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
    }
    
    //Stats Row
    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(user.score)", label: "Vibe Pts")
            statItem(value: "#\(user.rank)", label: "Rank")
            statItem(value: "\(user.smashes)", label: "Smashes", highlight: true)
            statItem(value: "\(user.passes)", label: "Passes")
        }
        .padding(.vertical, 14)
        .cardStyle()
        .padding(.bottom, 16)
    }
    
    private func statItem(value: String, label: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(highlight ? AppTheme.green : AppTheme.text)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
    
    // Core Vibe Card
    private var coreVibeCard: some View {
        HStack {
            Text("Core vibe: ")
                .foregroundColor(AppTheme.text) +
            Text(user.vibe)
                .foregroundColor(AppTheme.purple)
                .bold() +
            Text(" · \(user.vibeDesc)")
                .foregroundColor(AppTheme.text)
        }
        .font(.system(size: 13))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [AppTheme.purple.opacity(0.12), AppTheme.pink.opacity(0.08)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.purple.opacity(0.25), lineWidth: 1)
        )
        .padding(.bottom, 20)
    }
    
    // Profile Details
    private var profileDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Profile")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.text)
                .padding(.bottom, 4)
            
            ForEach(detailItems, id: \.label) { item in
                profileDetailRow(item: item)
            }
        }
    }
    
    private var detailItems: [DetailItem] {
        [
            DetailItem(icon: "🎓", label: "Major", value: user.major, dotColor: AppTheme.purple),
            DetailItem(icon: "🏫", label: "School", value: user.school, dotColor: AppTheme.green),
            DetailItem(icon: "🧠", label: "MBTI", value: user.mbti, dotColor: AppTheme.textDim),
            DetailItem(icon: "🎵", label: "Fav Song", value: user.favSong, dotColor: AppTheme.pink),
            DetailItem(icon: "🌍", label: "Origin", value: user.origin, dotColor: AppTheme.orange),
            DetailItem(icon: "☀️", label: "Routine", value: user.routine, dotColor: AppTheme.yellow),
        ]
    }
    
    private func profileDetailRow(item: DetailItem) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(item.dotColor)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.label.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
                    .tracking(0.5)
                
                Text(item.value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.text)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .cardStyle()
    }
}

// Detail Item Model
private struct DetailItem {
    let icon: String
    let label: String
    let value: String
    let dotColor: Color
}

// Preview
#Preview {
    ZStack {
        AppTheme.bg.ignoresSafeArea()
        ProfileView(user: AppData().currentUser)
    }
}
