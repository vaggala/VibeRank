import SwiftUI

struct LoginView: View {
    @State private var service = FirebaseService.shared

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 80)

                    logoSection

                    Spacer().frame(height: 48)

                    formSection

                    Spacer().frame(height: 24)

                    submitButton

                    Spacer().frame(height: 20)

                    toggleModeButton

                    if !service.errorMessage.isEmpty {
                        Text(service.errorMessage)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Logo

    private var logoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.purple, AppTheme.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: AppTheme.purple.opacity(0.5), radius: 20)

                Text("V")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Text("VibeRank")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.text)

            Text(isSignUp ? "Create your account" : "Welcome back")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textDim)
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 12) {
            inputField(icon: "envelope", placeholder: "Email",    text: $email,    field: .email, keyboard: .emailAddress)
            inputField(icon: "lock",     placeholder: "Password", text: $password, field: .password, isSecure: true)
        }
    }

    private func inputField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        keyboard: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.textDim)
                .frame(width: 20)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboard)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
            }
            .font(.system(size: 15))
            .foregroundColor(AppTheme.text)
            .focused($focusedField, equals: field)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    focusedField == field ? AppTheme.purple.opacity(0.6) : AppTheme.cardBorder,
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }

    // MARK: - Submit Button

    private var submitButton: some View {
        Button {
            focusedField = nil
            Task {
                if isSignUp {
                    await service.signUp(email: email, password: password)
                } else {
                    await service.signIn(email: email, password: password)
                }
            }
        } label: {
            ZStack {
                if service.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(isSignUp ? "Create Account" : "Sign In")
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
                .opacity(canSubmit ? 1 : 0.4)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: AppTheme.purple.opacity(0.35), radius: 10, y: 4)
        }
        .disabled(!canSubmit || service.isLoading)
        .buttonStyle(ScaleButtonStyle())
    }

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6
    }

    // MARK: - Toggle Mode

    private var toggleModeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSignUp.toggle()
                service.errorMessage = ""
            }
        } label: {
            HStack(spacing: 4) {
                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                    .foregroundColor(AppTheme.textDim)
                Text(isSignUp ? "Sign In" : "Sign Up")
                    .foregroundColor(AppTheme.purple)
                    .fontWeight(.semibold)
            }
            .font(.system(size: 14))
        }
    }
}

#Preview {
    LoginView()
}
