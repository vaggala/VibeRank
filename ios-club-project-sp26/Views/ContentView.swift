import SwiftUI

struct ContentView: View {
    @State private var authManager = AuthManager()
    @State private var appData = AppData()
    @State private var selectedTab: Tab = .home

    enum Tab: String {
        case home, vote, profile
    }

    var body: some View {
        Group {
            if !authManager.isLoggedIn {
                LoginView(authManager: authManager)
            } else if authManager.needsOnboarding {
                OnboardingView(authManager: authManager)
            } else if let user = authManager.currentUser {
                mainTabView(user: user)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Main Tab View

    private func mainTabView(user: UserProfile) -> some View {
        ZStack(alignment: .bottom) {
            AppTheme.bg.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(
                        appData: appData,
                        currentUser: user,
                        onStartVoting: { selectedTab = .vote }
                    )
                case .vote:
                    VoteView(appData: appData)
                case .profile:
                    ProfileView(
                        user: user,
                        authManager: authManager
                    )
                }
            }
            .padding(.bottom, 70)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .onAppear {
            appData.currentUserUID = user.id
//            appData.fetchProfiles()
            appData.startListeningLeaderboard()
        }
        .onDisappear {
            appData.stopListeningLeaderboard()
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab

    var body: some View {
        HStack {
            tabItem(tab: .home, icon: "square.grid.2x2",   label: "Home",    activeColor: AppTheme.purple)
            Spacer()
            tabItem(tab: .vote, icon: "rectangle.portrait.on.rectangle.portrait", label: "Vote", activeColor: AppTheme.orange)
            Spacer()
            tabItem(tab: .profile, icon: "person.fill",    label: "Profile", activeColor: AppTheme.pink)
        }
        .padding(.horizontal, 40)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [AppTheme.bg, AppTheme.bg.opacity(0.95), AppTheme.bg.opacity(0)],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private func tabItem(tab: ContentView.Tab, icon: String, label: String, activeColor: Color) -> some View {
        let isActive = selectedTab == tab

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isActive ? activeColor.opacity(0.15) : .clear)
                        .frame(width: 36, height: 28)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isActive ? activeColor : AppTheme.textMuted)
                }

                Text(label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? activeColor : AppTheme.textMuted)
            }
        }
    }
}

#Preview {
    ContentView()
}
