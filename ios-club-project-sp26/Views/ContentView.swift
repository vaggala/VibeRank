//
//  ContentView.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 3/16/26.
//

import SwiftUI

// MARK: - Main Tab View
struct ContentView: View {
    @State private var selectedTab = 1  // default: Voting

    var body: some View {
        TabView(selection: $selectedTab) {
            LeaderboardPage()
                .tag(0)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Leaderboard")
                }

            VotingView()
                .tag(1)
                .tabItem {
                    Image(systemName: "list.bullet.clipboard.fill")
                    Text("Voting")
                }

            ProfileView()
                .tag(2)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("My Profile")
                }
        }
        .toolbarBackground(Color(red: 83/255, green: 74/255, blue: 183/255), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .tint(.white)
    }
}

// MARK: - Leaderboard Page
struct LeaderboardPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer().frame(height: 40)

            // #1 - Gold
            LeaderboardRow(rank: "#1", color: .yellow)
            // #2 - Silver
            LeaderboardRow(rank: "#2", color: .gray)
            // #3 - Bronze
            LeaderboardRow(rank: "#3", color: .orange)
            // Rest - Blue
            LeaderboardRow(rank: "", color: .blue)
            LeaderboardRow(rank: "", color: .blue)
            LeaderboardRow(rank: "", color: .blue)

            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct LeaderboardRow: View {
    let rank: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 28, height: 28)

                if !rank.isEmpty {
                    Text(rank)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            RoundedRectangle(cornerRadius: 8)
                .fill(Color(UIColor.systemGray5))
                .frame(height: 36)
        }
    }
}

#Preview {
    ContentView()
}
