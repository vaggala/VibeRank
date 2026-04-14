import SwiftUI

struct OnboardingView: View {
    var authManager: AuthManager

    @State private var step: Int = 0
    @State private var draft = UserProfile()

    // Individual field states (bound to draft in each step)
    @State private var name: String = ""
    @State private var mbti: String = ""
    @State private var hobbies: String = ""
    @State private var anthem: String = ""
    @State private var routine: String = ""
    @State private var homeTurf: String = ""
    @State private var major: String = ""
    @State private var coreVibe: String = ""
    @State private var funFact: String = ""

    @FocusState private var fieldFocused: Bool

    private let totalSteps = 9

    // Step metadata: (field label, fun subtitle, SF Symbol, field index)
    private let steps: [(title: String, subtitle: String, icon: String)] = [
        ("What's your name?",              "Let's start with the basics",                    "person.fill"),
        ("Your MBTI?",                     "Pick your personality type",                     "brain.head.profile"),
        ("Accidental Rizz Hobbies",        "What do you do that people find lowkey charming","sparkles"),
        ("Delusional Anthem",              "The song you pretend was written about you",     "music.note"),
        ("Unhinged Routine",               "Describe your daily schedule, honestly",         "clock.fill"),
        ("Home Turf",                      "Where are you from originally?",                 "map.fill"),
        ("Major",                          "What are you studying?",                         "graduationcap.fill"),
        ("Core Vibe",                      "Describe yourself in one iconic phrase",         "flame.fill"),
        ("Fun Fact",                       "Something that makes people say \"wait what\"",  "star.fill"),
    ]

    private let mbtiTypes = [
        "INTJ", "INTP", "ENTJ", "ENTP",
        "INFJ", "INFP", "ENFJ", "ENFP",
        "ISTJ", "ISTP", "ESTJ", "ESTP",
        "ISFJ", "ISFP", "ESFJ", "ESFP",
    ]

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                Spacer()

                stepContent
                    .padding(.horizontal, 28)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(step)

                Spacer()

                bottomButtons
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
            }
        }
        .onTapGesture { fieldFocused = false }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(step + 1) of \(totalSteps)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.textDim)
                Spacer()
                Text("\(Int((Double(step + 1) / Double(totalSteps)) * 100))%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.purple)
            }

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
                            width: geo.size.width * CGFloat(step + 1) / CGFloat(totalSteps),
                            height: 4
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: step)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Icon + header
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(AppTheme.purple.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: steps[step].icon)
                        .font(.system(size: 22))
                        .foregroundColor(AppTheme.purple)
                }

                Text(steps[step].title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.text)

                Text(steps[step].subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textDim)
            }

            // Input
            if step == 1 {
                mbtiPicker
            } else {
                textInputField
            }
        }
    }

    // MARK: - Text Input

    private var textInputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(inputPlaceholder, text: currentBinding, axis: .vertical)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.text)
                .lineLimit(step == 8 ? 4 : 1)
                .focused($fieldFocused)
                .padding(16)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            fieldFocused ? AppTheme.purple.opacity(0.6) : AppTheme.cardBorder,
                            lineWidth: 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: fieldFocused)
                .onAppear { fieldFocused = true }
        }
    }

    private var inputPlaceholder: String {
        switch step {
        case 0: return "e.g. Jordan Kim"
        case 2: return "e.g. Making playlists, doodling, cooking at 2am"
        case 3: return "e.g. Golden Hour by JVKE"
        case 4: return "e.g. Wake up at noon, iced matcha, pretend to study"
        case 5: return "e.g. Seoul, South Korea"
        case 6: return "e.g. Computer Science"
        case 7: return "e.g. Golden Hour Vibes"
        case 8: return "e.g. I've never lost a staring contest with a dog"
        default: return ""
        }
    }

    // MARK: - MBTI Picker

    private var mbtiPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            ForEach(mbtiTypes, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { mbti = type }
                } label: {
                    Text(type)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(mbti == type ? .white : AppTheme.textDim)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            mbti == type
                                ? LinearGradient(colors: [AppTheme.purple, AppTheme.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [AppTheme.card, AppTheme.card], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    mbti == type ? Color.clear : AppTheme.cardBorder,
                                    lineWidth: 1
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            if step > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.textDim)
                        .frame(width: 90)
                        .padding(.vertical, 16)
                        .background(AppTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(AppTheme.cardBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }

            Button {
                if step < totalSteps - 1 {
                    withAnimation(.easeInOut(duration: 0.25)) { step += 1 }
                } else {
                    submitProfile()
                }
            } label: {
                ZStack {
                    if authManager.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(step < totalSteps - 1 ? "Next →" : "Let's Go 🔥")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppTheme.purple, AppTheme.pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .opacity(canAdvance ? 1 : 0.4)
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: AppTheme.purple.opacity(0.35), radius: 10, y: 4)
            }
            .disabled(!canAdvance || authManager.isLoading)
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - Helpers

    private var currentBinding: Binding<String> {
        switch step {
        case 0: return $name
        case 2: return $hobbies
        case 3: return $anthem
        case 4: return $routine
        case 5: return $homeTurf
        case 6: return $major
        case 7: return $coreVibe
        case 8: return $funFact
        default: return .constant("")
        }
    }

    private var currentValue: String {
        switch step {
        case 0: return name
        case 1: return mbti
        case 2: return hobbies
        case 3: return anthem
        case 4: return routine
        case 5: return homeTurf
        case 6: return major
        case 7: return coreVibe
        case 8: return funFact
        default: return ""
        }
    }

    private var canAdvance: Bool {
        !currentValue.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submitProfile() {
        var profile = UserProfile()
        profile.name     = name.trimmingCharacters(in: .whitespaces)
        profile.mbti     = mbti
        profile.hobbies  = hobbies.trimmingCharacters(in: .whitespaces)
        profile.anthem   = anthem.trimmingCharacters(in: .whitespaces)
        profile.routine  = routine.trimmingCharacters(in: .whitespaces)
        profile.homeTurf = homeTurf.trimmingCharacters(in: .whitespaces)
        profile.major    = major.trimmingCharacters(in: .whitespaces)
        profile.coreVibe = coreVibe.trimmingCharacters(in: .whitespaces)
        profile.funFact  = funFact.trimmingCharacters(in: .whitespaces)

        Task { await authManager.saveProfile(profile) }
    }
}

#Preview {
    OnboardingView(authManager: AuthManager())
}
