
import SwiftUI

struct VoteView: View {
    var appData: AppData
    
    @State private var dragOffset: CGSize = .zero
    @State private var cardOpacity: Double = 1.0
    @State private var showNextCard = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            progressBar
            
            if let profile = appData.currentProfile {
                profileCard(profile: profile)
                actionButtons(profile: profile)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Vibe Check")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.text)
            
            Text("Does their energy match yours?")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textDim)
        }
        .padding(.bottom, 12)
    }
    
    // Progress Bar
    private var progressBar: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.surface)
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.purple, AppTheme.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * min(CGFloat(appData.totalVotes) / 30.0, 1.0),
                            height: 4
                        )
                        .animation(.easeInOut(duration: 0.5), value: appData.totalVotes)
                }
            }
            .frame(height: 4)
            
            Text("\(appData.totalVotes) / 30")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textDim)
                .monospacedDigit()
        }
        .padding(.bottom, 16)
    }
    
    // Profile Card
    private func profileCard(profile: Profile) -> some View {
        VStack(spacing: 0) {
            cardHeader(profile: profile)
            
            infoGrid(profile: profile)
                .padding(.horizontal, 16)
                .padding(.top, 4)
            
            // Fun Fact
            Text("Fun fact: \(profile.funFact)")
                .font(.system(size: 13).italic())
                .foregroundColor(AppTheme.yellow)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
        }
        .background(
            LinearGradient(
                colors: [AppTheme.card, AppTheme.surface],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width) * 0.04))
        .opacity(cardOpacity)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        // right = Smash
                        swipeAway(direction: .smash)
                    } else if value.translation.width < -100 {
                        // left = Pass
                        swipeAway(direction: .pass)
                    } else {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: dragOffset)
        .id(profile.id)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.9).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .padding(.bottom, 14)
    }
    
    // Card Header
    private func cardHeader(profile: Profile) -> some View {
        VStack(spacing: 0) {
            AvatarView(
                initials: profile.initials,
                color: profile.accentColor,
                size: 72,
                showGlow: true
            )
            .padding(.top, 28)
            
            Text(profile.name)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.text)
                .padding(.top, 14)
            
            Text("\(profile.age) · \(profile.location)")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textDim)
                .padding(.top, 2)
            
            // Vibe title
            Text(profile.vibe)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.green)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(AppTheme.green.opacity(0.15))
                .clipShape(Capsule())
                .padding(.top, 10)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [profile.accentColor.opacity(0.12), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func infoGrid(profile: Profile) -> some View {
        let items: [(String, String)] = [
            ("Major", profile.major),
            ("Fav Song", profile.favSong),
            ("Origin", profile.origin),
            ("MBTI", profile.mbti),
            ("Routine", profile.routine),
            ("Hobbies", profile.hobbies),
        ]
        
        return VStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 1) {
                    InfoGridCell(label: items[row * 2].0, value: items[row * 2].1)
                    InfoGridCell(label: items[row * 2 + 1].0, value: items[row * 2 + 1].1)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
    }
    
    // Action Buttons
    private func actionButtons(profile: Profile) -> some View {
        HStack(spacing: 24) {
            VoteActionButton(
                icon: "xmark",
                label: "Pass",
                color: AppTheme.red,
                size: 58,
                action: { swipeAway(direction: .pass) }
            )
            
            VoteActionButton(
                icon: "forward.fill",
                label: "Skip",
                color: AppTheme.textDim,
                size: 46,
                action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        appData.vote(.skip)
                    }
                }
            )
            
            VoteActionButton(
                icon: "heart.fill",
                label: "Smash",
                color: AppTheme.pink,
                size: 58,
                action: { swipeAway(direction: .smash) }
            )
        }
        .frame(maxWidth: .infinity)
    }
    
    // Swipe Away Animation
    private func swipeAway(direction: VoteType) {
        let xOffset: CGFloat = direction == .smash ? 500 : -500
        
        withAnimation(.easeIn(duration: 0.3)) {
            dragOffset = CGSize(width: xOffset, height: 0)
            cardOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            appData.vote(direction)
            dragOffset = .zero
            cardOpacity = 1.0
        }
    }
}

//Preview
#Preview {
    ZStack {
        AppTheme.bg.ignoresSafeArea()
        VoteView(appData: AppData())
    }
}
