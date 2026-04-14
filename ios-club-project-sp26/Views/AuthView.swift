//
//  AuthView.swift
//  ios-club-project-sp26
//
//  Created by vasanth aggala on 4/3/26.
//

import SwiftUI

struct AuthView: View {
    @Environment(ProfileViewModel.self) var vm
    @State private var isLogin = true
    
    var body: some View {
        if isLogin {
            Login(toggle: $isLogin)
        } else {
            SignUp(toggle: $isLogin)
        }
    }
}

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @Environment(ProfileViewModel.self) var vm
    @Binding var toggle: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Log In!").font(.title)
            
//            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
//            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            
            TextField("", text: $email, prompt: Text("Email").foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .padding(10)
                .font(.title)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .background {
                    RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            SecureField("", text: $password, prompt: Text("Password").foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .padding(10)
                .font(.title)
                .textInputAutocapitalization(.never)
                .background {
                    RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            
            Button {
                Task {
//                    let uid = await FirebaseService.shared.signIn(email: email, password: password)
//                    print(uid ?? "login failed :(")
                    await vm.signIn(email: email, password: password)
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Submit").foregroundStyle(.black).font(.title)
                    Spacer()
                }.padding(10).background {
                    RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            }
            Button("Need an account? Sign up") {
                toggle = false
            }
        }.padding()
    }
}

struct SignUp: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @Environment(ProfileViewModel.self) var vm
    @Binding var toggle: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up!").font(.title)
            
//            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
//            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
//            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            
            TextField("", text: $name, prompt: Text("Name").foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .padding(10)
                .font(.title)
                .textInputAutocapitalization(.never)
                .background {
                    RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            TextField("", text: $email, prompt: Text("Email").foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .padding(10)
                .font(.title)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .background {
                    RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            SecureField("", text: $password, prompt: Text("Password").foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .padding(10)
                .font(.title)
                .textInputAutocapitalization(.never)
                .background {
                    RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.6, green: 0.6, blue: 0.6))
                }

            
            Button {
                Task {
                     await vm.signUp(email: email, password: password, name: name)     /*add this when adding view model(s)*/
//                    let uid = await FirebaseService.shared.signUp(email: email, password: password, name: name)
//                    if uid != nil {
//                        toggle = true
//                    } else {
//                        print("signup failed :(")
//                    }
                }
            } label: {
                HStack {
                    Spacer()
                    Text("Submit").foregroundStyle(.black).font(.title)
                    Spacer()
                }.padding(10).background {
                    RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            }
            Button("Already have an account? Log in") {
                toggle = true
            }
            
        }.padding()
        
        
    }
}

#Preview {
    let vm = ProfileViewModel()
    AuthView().environment(vm)
}
