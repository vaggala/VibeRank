//
//  Votetest.swift
//  ios-club-project-sp26
//
//  Created by Miguel Tjia on 4/11/26.
//

import SwiftUI

struct VoteTest: View {
    @State private var votingVM = VotingViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Button("SMASH TEST") {
                votingVM.smash(targetUserId: "nEoGwdzGgVRnm6h8T4BkD1F09VU2")
            }

            Button("PASS TEST") {
                votingVM.pass(targetUserId: "nEoGwdzGgVRnm6h8T4BkD1F09VU2")
            }
        }
        .padding()
    }
}

#Preview {
    VoteTest()
}
