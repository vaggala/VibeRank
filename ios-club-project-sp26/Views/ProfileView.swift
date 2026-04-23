import SwiftUI

struct ProfileView: View {
    @State private var service = FirebaseService.shared
    let user: UserProfile

    @State private var showEditProfile = false
    
    private var userRank: Int {
        let board = service.leaderboard
        guard let index = board.firstIndex(where: { $0.id == user.id }) else {
            return -1
        }
        return index + 1
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                topBar
                avatarSection
                statsRow
                coreVibeCard
                profileDetails
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Spacer()

            Button("Edit") { showEditProfile = true }
                .font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.text)
                .padding(.horizontal, 14).padding(.vertical, 6)
                .background(.white.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 8))

            Button {
                service.signOut()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 14)).foregroundColor(AppTheme.textDim)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(.white.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Avatar & Name

    private var avatarSection: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [AppTheme.purple, AppTheme.pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 88, height: 88)
                    .shadow(color: AppTheme.purple.opacity(0.3), radius: 15)
                Text(user.initials.isEmpty ? "?" : user.initials)
                    .font(.system(size: 30, weight: .bold, design: .rounded)).foregroundColor(.white)
            }
            Text(user.name)
                .font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(AppTheme.text).padding(.top, 14)
            Text(user.homeTurf)
                .font(.system(size: 13)).foregroundColor(AppTheme.textDim).padding(.top, 4)
        }
        .frame(maxWidth: .infinity).padding(.bottom, 20)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(user.personalScore)", label: "Vibe Pts")
            statItem(value: userRank == -1 ? "—" : "#\(userRank)", label: "Rank")
            statItem(value: "\(user.smashCount)",    label: "Smashes", highlight: true)
            statItem(value: "\(user.passCount)",     label: "Passes")
        }
        .padding(.vertical, 14).cardStyle().padding(.bottom, 16)
    }

    private func statItem(value: String, label: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(highlight ? AppTheme.green : AppTheme.text)
            Text(label).font(.system(size: 10)).foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Core Vibe Card

    private var coreVibeCard: some View {
        HStack {
            Text("Core vibe: ").foregroundColor(AppTheme.text)
            Text(user.coreVibe.isEmpty ? "not set yet" : user.coreVibe)
                .foregroundColor(user.coreVibe.isEmpty ? AppTheme.textMuted : AppTheme.purple).bold()
        }
        .font(.system(size: 13))
        .frame(maxWidth: .infinity, alignment: .leading).padding(16)
        .background(LinearGradient(colors: [AppTheme.purple.opacity(0.12), AppTheme.pink.opacity(0.08)], startPoint: .leading, endPoint: .trailing))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.purple.opacity(0.25), lineWidth: 1))
        .padding(.bottom, 20)
    }

    // MARK: - Profile Details

    private var profileDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("My Profile")
                .font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(AppTheme.text).padding(.bottom, 4)
            ForEach(detailItems, id: \.label) { item in profileDetailRow(item: item) }
        }
    }

    private var detailItems: [DetailItem] {
        [
            DetailItem(icon: "🎓", label: "Major",             value: user.major,        dotColor: AppTheme.purple),
            DetailItem(icon: "🧠", label: "MBTI",              value: user.mbti,         dotColor: AppTheme.blue),
            DetailItem(icon: "🎵", label: "Delusional Anthem", value: user.anthem,       dotColor: AppTheme.pink),
            DetailItem(icon: "☀️", label: "Unhinged Routine",  value: user.routine,      dotColor: AppTheme.yellow),
            DetailItem(icon: "🌍", label: "Home Turf",         value: user.homeTurf,     dotColor: AppTheme.orange),
            DetailItem(icon: "✨", label: "Rizz Hobbies",      value: user.rizzHobbies,  dotColor: AppTheme.green),
            DetailItem(icon: "⭐", label: "Fun Fact",          value: user.funFact,      dotColor: AppTheme.gold),
        ]
    }

    private func profileDetailRow(item: DetailItem) -> some View {
        HStack(spacing: 12) {
            Circle().fill(item.dotColor).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.label.uppercased())
                    .font(.system(size: 10, weight: .medium)).foregroundColor(AppTheme.textMuted).tracking(0.5)
                Text(item.value.isEmpty ? "—" : item.value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(item.value.isEmpty ? AppTheme.textMuted : AppTheme.text)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 12).cardStyle()
    }
}

// MARK: - Detail Item Model

private struct DetailItem {
    let icon: String
    let label: String
    let value: String
    let dotColor: Color
}

#Preview {
    ZStack {
        AppTheme.bg.ignoresSafeArea()
        ProfileView(user: {
            var u = UserProfile()
            u.id = "preview-user"
            return u
        }())
    }
}

