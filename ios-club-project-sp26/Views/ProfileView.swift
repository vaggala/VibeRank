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
private let hardcodedCoreVibe = "Golden Hour Vibes"
private let hardcodedVibeSubtitle = "calm but make it iconic"

private let hardcodedInfoCards: [(label: String, value: String, color: Color)] = [
    ("Major",    "Business & Design (Double Major)", .purple),
    ("School",   "Georgia Tech",                     .purple),
    ("MBTI",     "INFJ",                             .purple),
    ("Fav Song", "\"Golden Hour\" by JVKE",          .green),
    ("Origin",   "Seoul, South Korea",               .green),
    ("Routine",  "Morning runs + iced matcha",       .orange)
]


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
            CoreVibeBanner(
                vibe: hardcodedCoreVibe,
                subtitle: hardcodedVibeSubtitle
            )
            .offset(y: -16)
            InfoList(cards: hardcodedInfoCards)
            Spacer().frame(height: 40)
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

struct CoreVibeBanner: View {
    let vibe: String
    let subtitle: String
                                                                                                                                                                                      
    var body: some View {
        (Text("Core vibe: ")
            .foregroundColor(.white.opacity(0.6))
           + Text(vibe).bold().foregroundColor(.white)
           + Text(" · \(subtitle)").foregroundColor(.white.opacity(0.6)))
              .font(.system(size: 14))
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(16)
              .background(Color(red: 0.09, green: 0.08, blue: 0.15))
              .cornerRadius(12)
              .padding(.horizontal, 16)
      }
}

struct InfoCard: View {
      let label: String
      let value: String
      let dotColor: Color
                  
      var body: some View {
          HStack(alignment: .top, spacing: 12) {
              Circle()
                  .fill(dotColor)
                  .frame(width: 8, height: 8)
                  .padding(.top, 6)
              VStack(alignment: .leading, spacing: 4) {
                  Text(label)
                      .font(.system(size: 12))
                      .foregroundColor(.white.opacity(0.5))
                  Text(value)
                      .font(.system(size: 16, weight: .semibold))
                      .foregroundColor(.white)
              }
              Spacer()
          }
          .padding(16)
          .background(Color(red: 0.09, green: 0.08, blue: 0.15))
          .cornerRadius(12)
      }
  }

  struct InfoList: View {
      let cards: [(label: String, value: String, color: Color)]
                                                                                                                                                                                      
      var body: some View {
          VStack(spacing: 10) {
              ForEach(cards, id: \.label) { card in
                  InfoCard(label: card.label, value: card.value, dotColor: card.color)
              }
          }
          .padding(.horizontal, 16)
      }
  }
 



#Preview {
    ProfileView()
        .environment(ProfileViewModel())
}
