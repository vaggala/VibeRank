import SwiftUI

struct VoteReactionView: View {
    let reaction: VoteReaction
    let totalDuration: Double

    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.2
    @State private var scaleX: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var shakeX: CGFloat = 0
    @State private var yOffset: CGFloat = 0
    @State private var hasDismissed = false

    var body: some View {
        VStack(spacing: 24) {
            Text(reaction.emoji)
                .font(.system(size: 140))
                .scaleEffect(x: scaleX, y: 1.0)
                .rotationEffect(.degrees(rotation))
                .offset(x: shakeX, y: yOffset)

            Text(reaction.caption)
                .font(.system(size: 54, weight: .heavy, design: .rounded))
                .foregroundColor(reaction.captionColor)
                .shadow(color: .black.opacity(0.55), radius: 10, y: 4)
                .offset(x: shakeX * 0.6)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.25))
        .contentShape(Rectangle())
        .onTapGesture { finishEarly() }
        .onAppear { runAnimation() }
    }

    // MARK: - Timeline

    private func runAnimation() {
        setupInitialState()
        runEntry()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            runHold()
        }

        let exitStart = max(0.6, totalDuration - 0.35)
        DispatchQueue.main.asyncAfter(deadline: .now() + exitStart) {
            runExit()
        }
    }

    private func setupInitialState() {
        switch reaction.style {
        case .drop:
            yOffset = -520
            scale = 1.0
            opacity = 1.0
        case .stretch:
            scale = 0.2
            scaleX = 0.3
            opacity = 0
        case .explode:
            scale = 0.1
            opacity = 0
        default:
            scale = 0.2
            opacity = 0
        }
    }

    // MARK: - Phases

    private func runEntry() {
        switch reaction.style {
        case .drop:
            withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
                yOffset = 0
            }
        case .explode:
            withAnimation(.spring(response: 0.38, dampingFraction: 0.42)) {
                opacity = 1
                scale = 1.15
            }
        case .stretch:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                opacity = 1
                scale = 1.0
                scaleX = 1.0
            }
        default:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                opacity = 1
                scale = 1.0
            }
        }
    }

    private func runHold() {
        switch reaction.style {
        case .shake:
            withAnimation(.linear(duration: 0.07).repeatForever(autoreverses: true)) {
                shakeX = 24
            }
        case .spin:
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        case .stretch:
            withAnimation(.easeInOut(duration: 0.35).repeatForever(autoreverses: true)) {
                scaleX = 1.6
            }
        case .pop:
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                scale = 1.06
            }
        case .explode:
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
            }
        case .drop:
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                scale = 1.03
            }
        }
    }

    private func runExit() {
        withAnimation(.easeIn(duration: 0.35)) {
            opacity = 0
            scale = 0.6
        }
    }

    // MARK: - Tap to skip

    private func finishEarly() {
        guard !hasDismissed else { return }
        hasDismissed = true
        SoundPlayer.shared.stop()
        withAnimation(.easeOut(duration: 0.18)) {
            opacity = 0
            scale = 0.6
        }
    }
}
