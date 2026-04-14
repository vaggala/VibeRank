//
//  ProfileView.swift
//  ios-club-project-sp26
//
//  Created by Grace Chiu on 4/13/26.
//

import SwiftUI

// TODO: move these to backend to User model when the backend extends
private let hardcodedInitials = "JK"
private let hardcodedCity = "Atlanta, GA"
private let hardcodedAge = 21
private let hardcodedSmashes = 124
private let hardcodedPasses = 38

struct ProfileView: View {
    @Environment(ProfileViewModel.self) var vm
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileHeader(
                initials: hardcodedInitials,
                name: vm.user?.name ?? "Jordan Kim",
                city: hardcodedCity,
                age: hardcodedAge
            )
            StatsRow(
                vibePoints: vm.user?.personalScore ?? 847,
                rank: vm.user?.leaderboardRank ?? 4,
                smashes: hardcodedSmashes,
                passes: hardcodedPasses
            )
            .offset(y: -24)
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }
}



struct ProfileHeader: View {
    let initials: String
    let name: String
    let city: String
    let age: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 12) {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 140, height: 140)
                    .overlay(
                        Text(initials)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundColor(.white)
                    )
                Text(name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text("\(city) | \(age) years old")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                    
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .padding(.horizontal, 16)
            
            Button(action: {print("edit tapped")}) {
                Text("Edit")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.2)))
            }
            .padding(16)
        }
        .background(Color(red: 0.45, green: 0.4, blue: 0.85))
    }
}

struct StatsRow: View {
      let vibePoints: Int
      let rank: Int
      let smashes: Int
      let passes: Int
                  
      var body: some View {
          HStack(spacing: 0) {
              StatTile(value: "\(vibePoints)", label: "Vibe Pts", color: .orange)
              StatTile(value: "#\(rank)", label: "Rank", color: Color(red: 0.55, green: 0.5, blue: 0.95))
              StatTile(value: "\(smashes)", label: "Smashes", color: Color(red: 0.95, green: 0.45, blue: 0.6))
              StatTile(value: "\(passes)", label: "Passes", color: .gray)
          }
          .background(Color(red: 0.09, green: 0.08, blue: 0.15))
          .cornerRadius(16)
          .padding(.horizontal, 16)
      }
  }
                                                                                                                                                                                      
  struct StatTile: View {
      let value: String
      let label: String
      let color: Color

      var body: some View {
          VStack(spacing: 4) {
              Text(value)
                  .font(.system(size: 22, weight: .bold))
                  .foregroundColor(color)
              Text(label)
                  .font(.system(size: 12))
                  .foregroundColor(.white.opacity(0.6))
          }
          .frame(maxWidth: .infinity)
          .padding(.vertical, 14)
      }
  }

#Preview {
    ProfileView()
        .environment(ProfileViewModel())
}
