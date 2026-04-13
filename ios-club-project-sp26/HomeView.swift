
import SwiftUI

struct HomeView: View {
    var appData: AppData
    var onStartVoting: () -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection
                startVotingButton
                leaderboardSection
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("VibeRank")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("See who's winning the vibe check")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)
            
            userRankCard
                .padding(.top, 16)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [AppTheme.purple, AppTheme.purpleDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 16)
    }
    
    private var userRankCard: some View {
        HStack(spacing: 12) {
            AvatarView(
                initials: appData.currentUser.initials,
                color: appData.currentUser.accentColor,
                size: 44
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(appData.currentUser.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(appData.currentUser.score) Vibe Points")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Rank #\(appData.currentUser.rank) globally")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            Text("#\(appData.currentUser.rank)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.green)
                .clipShape(Capsule())
        }
        .padding(12)
        .background(.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var startVotingButton: some View {
        Button(action: onStartVoting) {
            Text("Start Voting →")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppTheme.orange, Color(hex: "EA580C")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: AppTheme.orange.opacity(0.35), radius: 10, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.bottom, 24)
    }
    
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
            
            ForEach(Array(appData.leaderboard.enumerated()), id: \.element.id) { index, profile in
                leaderboardRow(profile: profile, rank: index + 1)
            }
        }
    }
    
    private func leaderboardRow(profile: Profile, rank: Int) -> some View {
        let scoreColor: Color = rank <= 3
            ? (rank == 1 ? AppTheme.gold : rank == 2 ? AppTheme.silver : AppTheme.bronze)
            : AppTheme.green
        
        return HStack(spacing: 12) {
            RankBadge(rank: rank)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.text)
                
                Text(profile.vibe)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textDim)
            }
            
            Spacer()
            
            Text("\(profile.score)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(scoreColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .cardStyle()
    }
}

#Preview {
    ZStack {
        AppTheme.bg.ignoresSafeArea()
        HomeView(appData: AppData(), onStartVoting: {})
    }
}
