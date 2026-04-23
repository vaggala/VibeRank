import SwiftUI
 
struct EditProfileView: View {
    @State private var service = FirebaseService.shared
    @Environment(\.dismiss) private var dismiss
 
    @State private var name: String
    @State private var mbti: String
    @State private var hobbies: String
    @State private var anthem: String
    @State private var routine: String
    @State private var homeTurf: String
    @State private var major: String
    @State private var coreVibe: String
    @State private var funFact: String
    @State private var instagram: String
    @State private var hasInstagram: Bool

    @FocusState private var focusedField: EditField?

    enum EditField: Hashable {
        case name, hobbies, anthem, routine, homeTurf, major, coreVibe, funFact, instagram
    }
 
    private let mbtiTypes = [
        "INTJ", "INTP", "ENTJ", "ENTP",
        "INFJ", "INFP", "ENFJ", "ENFP",
        "ISTJ", "ISTP", "ESTJ", "ESTP",
        "ISFJ", "ISFP", "ESFJ", "ESFP",
    ]
 
    init() {
        let u = FirebaseService.shared.currentUser ?? UserProfile()
        _name         = State(initialValue: u.name)
        _mbti         = State(initialValue: u.mbti)
        _hobbies      = State(initialValue: u.rizzHobbies)
        _anthem       = State(initialValue: u.anthem)
        _routine      = State(initialValue: u.routine)
        _homeTurf     = State(initialValue: u.homeTurf)
        _major        = State(initialValue: u.major)
        _coreVibe     = State(initialValue: u.coreVibe)
        _funFact      = State(initialValue: u.funFact)
        _instagram    = State(initialValue: u.instagram)
        _hasInstagram = State(initialValue: u.hasInstagram)
    }
 
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.bg.ignoresSafeArea()
 
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        fieldCard(label: "Name",                   field: .name,     text: $name,     placeholder: "Your name")
                        mbtiSection
                        fieldCard(label: "Accidental Rizz Hobbies", field: .hobbies, text: $hobbies,  placeholder: "e.g. Making playlists, doodling")
                        fieldCard(label: "Delusional Anthem",       field: .anthem,  text: $anthem,   placeholder: "e.g. Golden Hour by JVKE")
                        fieldCard(label: "Unhinged Routine",        field: .routine, text: $routine,  placeholder: "e.g. Wake up, iced matcha, pretend to study", multiline: true)
                        fieldCard(label: "Home Turf",               field: .homeTurf, text: $homeTurf, placeholder: "e.g. Seoul, South Korea")
                        fieldCard(label: "Major",                   field: .major,   text: $major,    placeholder: "e.g. Computer Science")
                        fieldCard(label: "Core Vibe",               field: .coreVibe, text: $coreVibe, placeholder: "e.g. Golden Hour Vibes")
                        fieldCard(label: "Fun Fact",                field: .funFact, text: $funFact,  placeholder: "e.g. I've never lost a staring contest with a dog", multiline: true)
                        instagramSection
                        saveButton.padding(.top, 8)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 16)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(AppTheme.textDim)
                }
            }
        }
        .onTapGesture { focusedField = nil }
    }
 
    // MARK: - Field Card
 
    private func fieldCard(label: String, field: EditField, text: Binding<String>, placeholder: String, multiline: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold)).foregroundColor(AppTheme.textMuted).tracking(0.8)
 
            TextField(placeholder, text: text, axis: multiline ? .vertical : .horizontal)
                .font(.system(size: 15)).foregroundColor(AppTheme.text)
                .lineLimit(multiline ? 3 : 1)
                .focused($focusedField, equals: field)
                .padding(14).background(AppTheme.card).clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(focusedField == field ? AppTheme.purple.opacity(0.6) : AppTheme.cardBorder, lineWidth: 1))
                .animation(.easeInOut(duration: 0.2), value: focusedField)
        }
    }
 
    // MARK: - Instagram Section

    private var instagramSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("INSTAGRAM")
                .font(.system(size: 10, weight: .semibold)).foregroundColor(AppTheme.textMuted).tracking(0.8)

            TextField("@yourhandle", text: $instagram)
                .font(.system(size: 15)).foregroundColor(AppTheme.text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .instagram)
                .disabled(!hasInstagram)
                .padding(14).background(AppTheme.card).clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(focusedField == .instagram ? AppTheme.purple.opacity(0.6) : AppTheme.cardBorder, lineWidth: 1))
                .opacity(hasInstagram ? 1.0 : 0.4)
                .animation(.easeInOut(duration: 0.2), value: focusedField)
                .animation(.easeInOut(duration: 0.2), value: hasInstagram)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    hasInstagram.toggle()
                    if !hasInstagram { focusedField = nil }
                }
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(hasInstagram ? AppTheme.cardBorder : AppTheme.purple, lineWidth: 1.5)
                            .frame(width: 20, height: 20)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(hasInstagram ? Color.clear : AppTheme.purple.opacity(0.25))
                            )
                        if !hasInstagram {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.purple)
                        }
                    }
                    Text("I don't have Instagram")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textDim)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - MBTI Section
 
    private var mbtiSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MBTI".uppercased())
                .font(.system(size: 10, weight: .semibold)).foregroundColor(AppTheme.textMuted).tracking(0.8)
 
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(mbtiTypes, id: \.self) { type in
                    Button { withAnimation(.easeInOut(duration: 0.15)) { mbti = type } } label: {
                        Text(type)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(mbti == type ? .white : AppTheme.textDim)
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(
                                mbti == type
                                    ? LinearGradient(colors: [AppTheme.purple, AppTheme.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [AppTheme.card, AppTheme.card], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(mbti == type ? Color.clear : AppTheme.cardBorder, lineWidth: 1))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }
 
    // MARK: - Helpers

    private func normalizedInstagram() -> String {
        guard hasInstagram else { return "" }
        let trimmed = instagram.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "" }
        return trimmed.hasPrefix("@") ? trimmed : "@\(trimmed)"
    }

    // MARK: - Save Button
 
    private var saveButton: some View {
        Button {
            focusedField = nil
            Task {
                var updated = service.currentUser ?? UserProfile()
                updated.name         = name.trimmingCharacters(in: .whitespaces)
                updated.mbti         = mbti
                updated.rizzHobbies  = hobbies.trimmingCharacters(in: .whitespaces)
                updated.anthem       = anthem.trimmingCharacters(in: .whitespaces)
                updated.routine      = routine.trimmingCharacters(in: .whitespaces)
                updated.homeTurf     = homeTurf.trimmingCharacters(in: .whitespaces)
                updated.major        = major.trimmingCharacters(in: .whitespaces)
                updated.coreVibe     = coreVibe.trimmingCharacters(in: .whitespaces)
                updated.funFact      = funFact.trimmingCharacters(in: .whitespaces)
                updated.instagram    = normalizedInstagram()
                updated.hasInstagram = hasInstagram
                await service.saveProfile(updated)
                dismiss()
            }
        } label: {
            ZStack {
                if service.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Save Changes")
                        .font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(LinearGradient(colors: [AppTheme.purple, AppTheme.pink], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: AppTheme.purple.opacity(0.35), radius: 10, y: 4)
        }
        .disabled(service.isLoading)
        .buttonStyle(ScaleButtonStyle())
        .padding(.bottom, 20)
    }
}
 
#Preview {
    EditProfileView()
}
 
