import SwiftUI
 
struct HomeView: View {
    @State private var service = FirebaseService.shared
    var currentUser: UserProfile
    var onStartVoting: () -> Void
 
    private var userRank: Int {
        let board = service.leaderboard
        return (board.firstIndex(where: { $0.id == currentUser.id }) ?? 0) + 1
    }
 
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                startVotingButton
                leaderboardSection
            }
            .padding(.horizontal, 16)
        }
<<<<<<< HEAD
        .refreshable {
            service.fetchProfiles()
        }
=======
>>>>>>> origin/main
    }
 
    // MARK: - Header
 
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("VibeRank")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
 
            Text("See who's winning the vibe check")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)
 
            userRankCard.padding(.top, 16)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [AppTheme.purple, AppTheme.purpleDark], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 16)
    }
 
    private var userRankCard: some View {
        HStack(spacing: 12) {
            AvatarView(initials: currentUser.initials, color: AppTheme.purple, size: 44)
 
            VStack(alignment: .leading, spacing: 2) {
                Text(currentUser.name)
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                Text("\(currentUser.personalScore) Vibe Points")
                    .font(.system(size: 12)).foregroundColor(.white.opacity(0.7))
                Text("Rank #\(userRank) globally")
                    .font(.system(size: 11)).foregroundColor(.white.opacity(0.5))
            }
 
            Spacer()
 
            Text("#\(userRank)")
                .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(AppTheme.green).clipShape(Capsule())
        }
        .padding(12)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
 
    // MARK: - Start Voting Button
 
    private var startVotingButton: some View {
        Button(action: onStartVoting) {
            Text("Start Voting →")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(colors: [AppTheme.orange, Color(hex: "EA580C")], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: AppTheme.orange.opacity(0.35), radius: 10, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.bottom, 24)
    }
 
    // MARK: - Leaderboard
 
    private var leaderboardSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Leaderboard")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                Spacer()
                Text("This Week")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.purple)
            }
            .padding(.bottom, 4)
 
            if service.isLoading && service.leaderboard.isEmpty {
                ProgressView().tint(AppTheme.purple).padding(.top, 20)
            } else if service.leaderboard.isEmpty {
                Text("No data yet — be the first to vote!")
                    .font(.system(size: 14)).foregroundColor(AppTheme.textDim).padding(.top, 16)
            } else {
                ForEach(Array(service.leaderboard.enumerated()), id: \.element.id) { index, profile in
                    leaderboardRow(profile: profile, rank: index + 1)
                }
            }
        }
    }
 
    private func leaderboardRow(profile: UserProfile, rank: Int) -> some View {
        let scoreColor: Color = rank == 1 ? AppTheme.gold : rank == 2 ? AppTheme.silver : rank == 3 ? AppTheme.bronze : AppTheme.green
        let isMe = profile.id == currentUser.id
 
        return HStack(spacing: 12) {
            RankBadge(rank: rank)
 
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(profile.name).font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.text)
                    if isMe {
                        Text("you")
                            .font(.system(size: 10, weight: .semibold)).foregroundColor(AppTheme.purple)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(AppTheme.purple.opacity(0.15)).clipShape(Capsule())
                    }
                }
                Text(profile.coreVibe).font(.system(size: 11)).foregroundColor(AppTheme.textDim)
            }
 
            Spacer()
 
            Text("\(profile.personalScore)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(scoreColor)
        }
        .padding(.horizontal, 14).padding(.vertical, 12).cardStyle()
    }
}
 
#Preview {
    ZStack {
        AppTheme.bg.ignoresSafeArea()
        HomeView(currentUser: UserProfile(), onStartVoting: {})
    }
}
