import SwiftUI

struct EditProfileView: View {
    var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    // Prefill from existing profile
    @State private var name: String
    @State private var mbti: String
    @State private var hobbies: String
    @State private var anthem: String
    @State private var routine: String
    @State private var homeTurf: String
    @State private var major: String
    @State private var coreVibe: String
    @State private var funFact: String

    @FocusState private var focusedField: EditField?

    enum EditField: Hashable {
        case name, hobbies, anthem, routine, homeTurf, major, coreVibe, funFact
    }

    private let mbtiTypes = [
        "INTJ", "INTP", "ENTJ", "ENTP",
        "INFJ", "INFP", "ENFJ", "ENFP",
        "ISTJ", "ISTP", "ESTJ", "ESTP",
        "ISFJ", "ISFP", "ESFJ", "ESFP",
    ]

    init(authManager: AuthManager) {
        self.authManager = authManager
        let u = authManager.currentUser ?? UserProfile()
        _name     = State(initialValue: u.name)
        _mbti     = State(initialValue: u.mbti)
        _hobbies  = State(initialValue: u.rizzHobbies)
        _anthem   = State(initialValue: u.anthem)
        _routine  = State(initialValue: u.routine)
        _homeTurf = State(initialValue: u.homeTurf)
        _major    = State(initialValue: u.major)
        _coreVibe = State(initialValue: u.coreVibe)
        _funFact  = State(initialValue: u.funFact)
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        fieldCard(label: "Name", field: .name, text: $name,
                                  placeholder: "Your name")

                        mbtiSection

                        fieldCard(label: "Accidental Rizz Hobbies", field: .hobbies, text: $hobbies,
                                  placeholder: "e.g. Making playlists, doodling")

                        fieldCard(label: "Delusional Anthem", field: .anthem, text: $anthem,
                                  placeholder: "e.g. Golden Hour by JVKE")

                        fieldCard(label: "Unhinged Routine", field: .routine, text: $routine,
                                  placeholder: "e.g. Wake up, iced matcha, pretend to study",
                                  multiline: true)

                        fieldCard(label: "Home Turf", field: .homeTurf, text: $homeTurf,
                                  placeholder: "e.g. Seoul, South Korea")

                        fieldCard(label: "Major", field: .major, text: $major,
                                  placeholder: "e.g. Computer Science")

                        fieldCard(label: "Core Vibe", field: .coreVibe, text: $coreVibe,
                                  placeholder: "e.g. Golden Hour Vibes")

                        fieldCard(label: "Fun Fact", field: .funFact, text: $funFact,
                                  placeholder: "e.g. I've never lost a staring contest with a dog",
                                  multiline: true)

                        saveButton
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppTheme.textDim)
                }
            }
        }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Field Card

    private func fieldCard(
        label: String,
        field: EditField,
        text: Binding<String>,
        placeholder: String,
        multiline: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
                .tracking(0.8)

            TextField(placeholder, text: text, axis: multiline ? .vertical : .horizontal)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.text)
                .lineLimit(multiline ? 3 : 1)
                .focused($focusedField, equals: field)
                .padding(14)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            focusedField == field ? AppTheme.purple.opacity(0.6) : AppTheme.cardBorder,
                            lineWidth: 1
                        )
                )
                .animation(.easeInOut(duration: 0.2), value: focusedField)
        }
    }

    // MARK: - MBTI Section

    private var mbtiSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MBTI".uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
                .tracking(0.8)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(mbtiTypes, id: \.self) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { mbti = type }
                    } label: {
                        Text(type)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(mbti == type ? .white : AppTheme.textDim)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                mbti == type
                                    ? LinearGradient(colors: [AppTheme.purple, AppTheme.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [AppTheme.card, AppTheme.card], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(mbti == type ? Color.clear : AppTheme.cardBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            focusedField = nil
            Task {
                var updated = authManager.currentUser ?? UserProfile()
                updated.name     = name.trimmingCharacters(in: .whitespaces)
                updated.mbti     = mbti
                updated.rizzHobbies  = hobbies.trimmingCharacters(in: .whitespaces)
                updated.anthem   = anthem.trimmingCharacters(in: .whitespaces)
                updated.routine  = routine.trimmingCharacters(in: .whitespaces)
                updated.homeTurf = homeTurf.trimmingCharacters(in: .whitespaces)
                updated.major    = major.trimmingCharacters(in: .whitespaces)
                updated.coreVibe = coreVibe.trimmingCharacters(in: .whitespaces)
                updated.funFact  = funFact.trimmingCharacters(in: .whitespaces)
                await authManager.saveProfile(updated)
                dismiss()
            }
        } label: {
            ZStack {
                if authManager.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Changes")
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
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: AppTheme.purple.opacity(0.35), radius: 10, y: 4)
        }
        .disabled(authManager.isLoading)
        .buttonStyle(ScaleButtonStyle())
        .padding(.bottom, 20)
    }
}

#Preview {
    EditProfileView(authManager: AuthManager())
}
