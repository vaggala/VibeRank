import SwiftUI

struct MutualMatchView: View {
    let match: MutualMatch
    let onDismiss: () -> Void

    @State private var cardScale: CGFloat = 0.6
    @State private var cardOpacity: Double = 0
    @State private var glowPulse: CGFloat = 0.8
    @State private var sparkleRotation: Double = 0
    @State private var hasDismissed = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.pink.opacity(0.5), AppTheme.purple.opacity(0.22), .clear],
                            center: .center, startRadius: 20, endRadius: 200
                        )
                    )
                    .frame(width: 320, height: 320)
                    .scaleEffect(glowPulse)
                    .blur(radius: 10)

                ForEach(0..<6, id: \.self) { i in
                    Image(systemName: "sparkle")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.yellow.opacity(0.8))
                        .offset(y: -130)
                        .rotationEffect(.degrees(Double(i) * 60 + sparkleRotation))
                }
            }

            VStack(spacing: 14) {
                Text("it's a mutual smash")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(1.6)
                    .foregroundColor(AppTheme.pink)
                    .textCase(.uppercase)

                Text("🔥")
                    .font(.system(size: 48))
                    .shadow(color: AppTheme.pink.opacity(0.7), radius: 14)

                Text(match.otherUserName.isEmpty ? "someone" : match.otherUserName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                handleBlock

                Button {
                    dismiss()
                } label: {
                    Text("keep vibing")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(colors: [AppTheme.purple, AppTheme.pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: AppTheme.pink.opacity(0.4), radius: 8, y: 3)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 24)
            .frame(maxWidth: 320)
            .background(
                LinearGradient(colors: [AppTheme.card, AppTheme.surface], startPoint: .top, endPoint: .bottom)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(colors: [AppTheme.pink.opacity(0.8), AppTheme.purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: AppTheme.pink.opacity(0.4), radius: 22, y: 6)
            .padding(.horizontal, 32)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
        }
        .contentShape(Rectangle())
        .onTapGesture { dismiss() }
        .onAppear { runEntry() }
    }

    // MARK: - Handle block (IG or "no IG" fallback)

    private var handleBlock: some View {
        Group {
            if match.otherUserHasInstagram && !match.otherUserInstagram.isEmpty {
                VStack(spacing: 4) {
                    Text("INSTAGRAM")
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(1.0)
                        .foregroundColor(AppTheme.textMuted)
                    Text(match.otherUserInstagram)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.text)
                        .shadow(color: AppTheme.pink.opacity(0.5), radius: 6)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(AppTheme.bg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.pink.opacity(0.35), lineWidth: 1)
                )
            } else {
                Text("this person doesn't have Instagram")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textDim)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.bg.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Animation

    private func runEntry() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
            glowPulse = 1.1
        }
        withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func dismiss() {
        guard !hasDismissed else { return }
        hasDismissed = true
        withAnimation(.easeOut(duration: 0.25)) {
            cardScale = 0.8
            cardOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

#Preview {
    MutualMatchView(
        match: MutualMatch(
            id: "a_b",
            otherUserId: "b",
            otherUserName: "Jordan Kim",
            otherUserInstagram: "@jordan_kim",
            otherUserHasInstagram: true,
            createdAt: Date()
        ),
        onDismiss: {}
    )
    .background(AppTheme.bg)
}
