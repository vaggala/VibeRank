import SwiftUI
import UIKit

struct VoteView: View {
    @State private var service = FirebaseService.shared

    @State private var dragOffset: CGSize = .zero
    @State private var cardOpacity: Double = 1.0
    @State private var pressedButton: VoteType? = nil
    @State private var burstCounter: Int = 0
    @State private var activeBurstType: VoteType? = nil
    @State private var reactionCounter: Int = 0
    @State private var activeReaction: VoteReaction? = nil
    @State private var reactionDuration: Double = 1.5

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                progressBar

                if service.isLoading && service.candidateProfiles.isEmpty {
                    loadingState
                } else if let profile = service.currentProfile {
                    profileCard(profile: profile).frame(maxHeight: .infinity)
                    actionButtons(profile: profile).padding(.top, 16)
                } else {
                    emptyState
                }
            }
            .padding(.horizontal, 16)

            if let burstType = activeBurstType {
                ParticleBurstView(voteType: burstType)
                    .id(burstCounter)
                    .allowsHitTesting(false)
            }

            if let reaction = activeReaction {
                VoteReactionView(reaction: reaction, totalDuration: reactionDuration)
                    .id(reactionCounter)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Vibe Check")
                .font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(AppTheme.text)
            Text("Does their energy match yours?")
                .font(.system(size: 13)).foregroundColor(AppTheme.textDim)
        }
        .padding(.bottom, 12)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(AppTheme.surface).frame(height: 4)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(colors: [AppTheme.purple, AppTheme.pink], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * min(CGFloat(service.votedUserIDs.count) / CGFloat(max(service.votedUserIDs.count + service.candidateProfiles.count, 1)), 1.0), height: 4)
                        .animation(.easeInOut(duration: 0.5), value: service.votedUserIDs.count)
                }
            }
            .frame(height: 4)

            Text("\(service.votedUserIDs.count) voted")
                .font(.system(size: 12)).foregroundColor(AppTheme.textDim).monospacedDigit()
        }
        .padding(.bottom, 16)
    }

    // MARK: - Profile Card

    private func profileCard(profile: UserProfile) -> some View {
        VStack(spacing: 0) {
            cardHeader(profile: profile)
            infoGrid(profile: profile).padding(.horizontal, 16).padding(.top, 4)
            Text("Fun fact: \(profile.funFact)")
                .font(.system(size: 13).italic()).foregroundColor(AppTheme.yellow)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20).padding(.vertical, 14)
        }
        .background(LinearGradient(colors: [AppTheme.card, AppTheme.surface], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.cardBorder, lineWidth: 1))
        .offset(dragOffset)
        .rotationEffect(.degrees(Double(dragOffset.width) * 0.04))
        .opacity(cardOpacity)
        .gesture(
            DragGesture()
                .onChanged { value in dragOffset = value.translation }
                .onEnded { value in
                    let dw = value.translation.width
                    let dh = value.translation.height
                    if abs(dw) > abs(dh) {
                        if dw > 100        { swipeAway(direction: .smash, profileID: profile.id) }
                        else if dw < -100  { swipeAway(direction: .pass,  profileID: profile.id) }
                        else { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { dragOffset = .zero } }
                    } else {
                        if abs(dh) > 100 {
                            let exitY: CGFloat = dh > 0 ? 800 : -800
                            swipeAway(direction: .skip, profileID: profile.id, exitOffset: CGSize(width: 0, height: exitY))
                        } else {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { dragOffset = .zero }
                        }
                    }
                }
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: dragOffset)
        .id(profile.id)
        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
        .padding(.bottom, 14)
    }

    // MARK: - Card Header

    private func cardHeader(profile: UserProfile) -> some View {
        VStack(spacing: 0) {
            AvatarView(initials: profile.initials, color: profile.accentColor, size: 72, showGlow: true)
                .padding(.top, 28)
            Text(profile.name)
                .font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(AppTheme.text).padding(.top, 14)
            Text(profile.homeTurf)
                .font(.system(size: 13)).foregroundColor(AppTheme.textDim).padding(.top, 2)
            Text(profile.coreVibe)
                .font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.green)
                .padding(.horizontal, 14).padding(.vertical, 5)
                .background(AppTheme.green.opacity(0.15)).clipShape(Capsule())
                .padding(.top, 10).padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [profile.accentColor.opacity(0.12), .clear], startPoint: .top, endPoint: .bottom))
    }

    // MARK: - Info Grid

    private func infoGrid(profile: UserProfile) -> some View {
        let items: [(String, String)] = [
            ("Major",        profile.major),
            ("MBTI",         profile.mbti),
            ("Anthem",       profile.anthem),
            ("Routine",      profile.routine),
            ("Home Turf",    profile.homeTurf),
            ("Rizz Hobbies", profile.rizzHobbies),
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
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.cardBorder, lineWidth: 1))
    }

    // MARK: - Action Buttons

    private func actionButtons(profile: UserProfile) -> some View {
        HStack(spacing: 24) {
            VoteActionButton(icon: "xmark",        label: "Pass",  color: AppTheme.red,     size: 58, externallyPressed: pressedButton == .pass,
                             action: { swipeAway(direction: .pass,  profileID: profile.id) })
            VoteActionButton(icon: "forward.fill", label: "Skip",  color: AppTheme.textDim, size: 46, externallyPressed: pressedButton == .skip,
                             action: { swipeAway(direction: .skip, profileID: profile.id) })
            VoteActionButton(icon: "heart.fill",   label: "Smash", color: AppTheme.pink,    size: 58, externallyPressed: pressedButton == .smash,
                             action: { swipeAway(direction: .smash, profileID: profile.id) })
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Loading / Empty States

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView().tint(AppTheme.purple).scaleEffect(1.5)
            Text("Finding vibes...").font(.system(size: 14)).foregroundColor(AppTheme.textDim)
        }
        .frame(maxWidth: .infinity).padding(.top, 80)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            VStack(spacing: 16) {
                Text("✨").font(.system(size: 48))
                Text("No more profiles")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                Text("Check back later for more vibes")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textDim)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    // MARK: - Swipe Animation

    private func swipeAway(direction: VoteType, profileID: String, exitOffset: CGSize? = nil) {
        let offset: CGSize
        if let custom = exitOffset {
            offset = custom
        } else {
            switch direction {
            case .smash: offset = CGSize(width: 500,  height: 0)
            case .pass:  offset = CGSize(width: -500, height: 0)
            case .skip:  offset = CGSize(width: 0,    height: -800)
            }
        }

        triggerHaptic(for: direction)
        activeBurstType = direction
        burstCounter += 1

        let reaction = VoteReactionPool.random(for: direction)
        let soundDuration = SoundPlayer.shared.play(reaction.sound)
        reactionDuration = max(min(soundDuration, 3.5), 1.3)
        activeReaction = reaction
        reactionCounter += 1

        let reactionSnapshot = reactionCounter
        DispatchQueue.main.asyncAfter(deadline: .now() + reactionDuration + 0.1) {
            if reactionCounter == reactionSnapshot {
                activeReaction = nil
            }
        }

        pressedButton = direction
        withAnimation(.easeIn(duration: 0.3)) { dragOffset = offset; cardOpacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { pressedButton = nil }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            service.vote(direction, targetID: profileID)
            dragOffset = .zero
            cardOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            activeBurstType = nil
        }
    }

    private func triggerHaptic(for type: VoteType) {
        switch type {
        case .smash: UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .pass:  UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .skip:  UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
    }
}

#Preview {
    ZStack {
        AppTheme.bg.ignoresSafeArea()
        VoteView()
    }
}
