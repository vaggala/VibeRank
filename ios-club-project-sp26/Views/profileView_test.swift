//
//  profileView_test.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 4/8/26.
//

// this file is strictly for testing and will not be accessible in production
// want to verify if
// 1) stay signed in implementation works
// 2) access personal profile

import SwiftUI

struct profileView_test: View {
    @Environment(ProfileViewModel.self) var vm
    var body: some View {
        VStack(spacing: 16) {
            if let user = vm.user {
                Text("Name: \(user.name)")
                Text("UID: \(user.uid)")
                Text("Score: \(user.personalScore)")
                Text("Rank: \(user.leaderboardRank)")
                Text("Hobbies: \(user.hobbies.joined(separator: ", "))")

                if let mbti = user.mbti, !mbti.isEmpty {
                    Text("MBTI: \(mbti)")
                }
            } else {
                ProgressView("Loading profile...")
            }

            Button("Reload Profile") {
                Task {
                    await vm.loadAllData()
                }
            }

            Button("Sign Out") {
                vm.signOut()
            }
        }
        .padding()
    }
}

#Preview {
    let vm = ProfileViewModel()
    profileView_test().environment(vm)
}

