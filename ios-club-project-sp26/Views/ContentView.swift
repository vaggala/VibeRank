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
                    Image(systemName: "diamond.fill")
                    Text("Leaderboard")
                }
            
            VotingView()
                .tag(1)
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("Voting")
                }
            
            ProfileView()
                .tag(2)
                .tabItem {
                    Image(systemName: "triangle.fill")
                    Text("My Profile")
                }
        }
        .tint(.blue)
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
//
//// MARK: - Voting Page
//struct VotingPage: View {
//    var body: some View {
//        VStack {
//            Spacer()
//            
//            // Card area with arrows
//            HStack {
//                // Left arrow
//                Button(action: {}) {
//                    Image(systemName: "chevron.left")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                        .padding(12)
//                        .background(Circle().fill(Color(UIColor.systemGray5)))
//                }
//                
//                Spacer()
//                
//                // Right arrow
//                Button(action: {}) {
//                    Image(systemName: "chevron.right")
//                        .font(.title2)
//                        .foregroundColor(.gray)
//                        .padding(12)
//                        .background(Circle().fill(Color(UIColor.systemGray5)))
//                }
//            }
//            .padding(.horizontal, 16)
//            
//            Spacer()
//            
//            // Pass & Smash buttons
//            HStack(spacing: 20) {
//                Button(action: {}) {
//                    Text("Pass")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.black)
//                        .frame(width: 140, height: 56)
//                        .background(
//                            RoundedRectangle(cornerRadius: 28)
//                                .fill(Color(red: 0.95, green: 0.6, blue: 0.6))
//                        )
//                }
//                
//                Button(action: {}) {
//                    Text("Smash")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.black)
//                        .frame(width: 140, height: 56)
//                        .background(
//                            RoundedRectangle(cornerRadius: 28)
//                                .fill(Color(red: 0.6, green: 0.9, blue: 0.6))
//                        )
//                }
//            }
//            .padding(.bottom, 24)
//        }
//    }
//}
//
//// MARK: - Profile Page
//struct ProfilePage: View {
//    var body: some View {
//        VStack(alignment: .leading) {
//            // Top bar
//            HStack {
//                Button(action: {}) {
//                    Image(systemName: "chevron.left")
//                        .font(.title2)
//                        .foregroundColor(.black)
//                }
//                
//                Spacer()
//                
//                // Small squares
//                HStack(spacing: 8) {
//                    ForEach(0..<4) { _ in
//                        RoundedRectangle(cornerRadius: 4)
//                            .stroke(Color.gray, lineWidth: 1)
//                            .frame(width: 28, height: 28)
//                    }
//                }
//            }
//            .padding(.horizontal, 16)
//                .superpowers/

nothing added to commit but untracked files present (use "git add" to track)
gracechiu@Graces-MacBook-Pro-3 VibeRank % git status
On branch grace
Your branch is ahead of 'origin/grace' by 17 commits.
  (use "git push" to publish your local commits)

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
    new file:   ios-club-project-sp26/Views/ProfileView.swift
    new file:   ios-club-project-sp26/Views/VotingView.swift

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
    modified:   ios-club-project-sp26/Views/ContentView.swift
    modified:   ios-club-project-sp26/Views/ProfileView.swift
    modified:   ios-club-project-sp26/Views/VotingView.swift

Untracked files:
  (use "git add <file>..." to include in what will be committed)
    .superpowers/
    docs/

gracechiu@Graces-MacBook-Pro-3 VibeRank %
.padding(.top, 8)
//            
//            // Title
//            Text("My Profile")
//                .font(.system(size: 32, weight: .bold))
//                .padding(.horizontal, 16)
//                .padding(.top, 8)
//            
//            Spacer()
//        }
//    }
//}

#Preview {
    ContentView()
}
