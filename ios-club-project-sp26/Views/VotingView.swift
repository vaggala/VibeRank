//
//  VotingView.swift
//  ios-club-project-sp26
//
//  Created by Grace Chiu on 4/13/26.
//

import SwiftUI

  struct VotingView: View {
      @State private var vm = VotingViewModel()

      var body: some View {
          VStack(spacing: 16) {
              if let target = vm.currentTarget {
                  VoteProgressHeader(vibeMatch: target.vibeMatch)
                  VotingCard(target: target)
                  Spacer()
                  VoteActionButtons(vm: vm)   // placeholder
              } else {
                  Text("No users to vote on")
              }
          }
          .padding(16)
          .background(Color(red: 13/255, green: 11/255, blue: 26/255).ignoresSafeArea())
      }
  }

  struct VoteProgressHeader: View {
      let vibeMatch: Int
      let maxMatch: Int = 30

      var body: some View {
          VStack(alignment: .leading, spacing: 8) {
              Text("Does their energy match yours?")
                  .font(.system(size: 14))
                  .foregroundColor(.gray)

              GeometryReader { geo in
                  ZStack(alignment: .leading) {
                      RoundedRectangle(cornerRadius: 4)
                          .fill(Color.white.opacity(0.15))
                          .frame(height: 8)

                      RoundedRectangle(cornerRadius: 4)
                          .fill(Color(red: 0.55, green: 0.5, blue: 0.95))
                          .frame(
                              width: geo.size.width * (Double(vibeMatch) / Double(maxMatch)),
                              height: 8
                          )
                  }
              }
              .frame(height: 8)

              Text("\(vibeMatch) / \(maxMatch)")
                  .font(.system(size: 12, weight: .semibold))
                  .foregroundColor(Color(red: 0.55, green: 0.5, blue: 0.95))
                  .frame(maxWidth: .infinity, alignment: .trailing)
          }
      }
  }

struct VotingCard: View {
    let target: VoteTarget
 
    var body: some View {
        VStack(spacing: 0) {
            CardHeader(target: target)
            VStack(spacing: 12) {
                InfoGrid(target: target)
                FunFactBanner(text: target.funFact)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.09, green: 0.08, blue: 0.15))
        }
        .cornerRadius(20)
    }
}
                
struct CardHeader: View {
    let target: VoteTarget
                                                                                                     
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)
                .overlay(
                    Text(target.initials)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                )
                
            Text(target.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
                
            Text("\(target.age) · \(target.city)")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                                                                                                     
            Text(target.tagline)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.2)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(red: 0.45, green: 0.4, blue: 0.85))
    }
}
                                                                                                     
struct InfoGrid: View {
    let target: VoteTarget

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
 
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            InfoTile(label: "Major", value: target.major)
            InfoTile(label: "Fav Song", value: target.favSong)
            InfoTile(label: "Origin", value: target.origin)
            InfoTile(label: "MBTI", value: target.mbti)
            InfoTile(label: "Routine", value: target.routine)
            InfoTile(label: "Hobbies", value: target.hobbies)
        }
    }
}
                
struct InfoTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.black)
        .cornerRadius(10)
    }
}
                
struct FunFactBanner: View {
    let text: String

    var body: some View {
        Text("Fun fact: \(text)")
            .font(.system(size: 13))
            .foregroundColor(Color(red: 0.4, green: 0.9, blue: 0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(red: 0.08, green: 0.12, blue: 0.12))
            .cornerRadius(10)
    }
}

struct VoteActionButtons: View {
     let vm: VotingViewModel

     var body: some View {
         HStack(spacing: 24) {
             VoteButton(
                 icon: "xmark",
                 label: "Pass",
                 fill: Color.white,
                 stroke: Color(red: 0.95, green: 0.4, blue: 0.55),
                 iconColor: .white,
                 iconBg: Color(red: 0.95, green: 0.4, blue: 0.55),
                 labelColor: Color(red: 0.95, green: 0.4, blue: 0.55)
             ) {
                 vm.vote(.pass)
             }
                 
             VoteButton(
                 icon: "arrow.right",
                 label: "Skip",
                 fill: Color(red: 0.09, green: 0.08, blue: 0.15),
                 stroke: .clear,
                 iconColor: .gray,
                 iconBg: .clear,
                 labelColor: .white
             ) {
                 vm.vote(.skip)
             }
                 
             VoteButton(
                 icon: "heart",
                 label: "Smash",
                 fill: Color(red: 0.55, green: 0.5, blue: 0.95),
                 stroke: .clear,
                 iconColor: Color(.white),
                 iconBg: .clear,
                 labelColor: .white
             ) {
                 vm.vote(.smash)
             }
         }
     }
 }

 struct VoteButton: View {
     let icon: String
     let label: String
     let fill: Color
     let stroke: Color
     let iconColor: Color
     let iconBg: Color
     let labelColor: Color
     let action: () -> Void

     var body: some View {
         Button(action: action) {
             VStack(spacing: 6) {
                 ZStack {
                     Circle()
                         .fill(fill)
                         .overlay(Circle().stroke(stroke, lineWidth: 2))
                         .frame(width: 68, height: 68)
                     Image(systemName: icon)
                         .font(.system(size: 22, weight: .semibold))
                         .foregroundColor(iconColor)
                 }
                 Text(label)
                     .font(.system(size: 12, weight: .medium))
                     .foregroundColor(labelColor)
             }
         }
     }
 }


  #Preview {
      VotingView()
  }
