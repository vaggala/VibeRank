//
//  RootView.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 4/8/26.
//

import SwiftUI

struct RootView: View {
    @State var vm = ProfileViewModel()
    
    var body: some View {
        Group {
            if vm.user != nil {
                profileView_test()
            } else {
                AuthView()
            }
        }.environment(vm)
    }
}

#Preview {
    RootView()
}
