//
//  UserView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/21/24.
//

import SwiftUI

struct UserView: View {
    private let monitor = NetworkMonitor()
    
    var id: String
    
    @State private var navigationPath = NavigationPath()
    
    @State private var isError = false
    @State private var isLoaded = false
    @State private var followingUser = false
    @State private var user: User = User(about: "", created: 0, id: "", karma: 0, submitted: [])
    
    func refreshData() async {
        user = User(about: "", created: 0, id: "", karma: 0, submitted: [])
        isError = false
        isLoaded = false
        
        do {
            let topStoriesURL = URL(string: "https://hacker-news.firebaseio.com/v0/user/\(id).json")!
            user = try await URLSession.shared.decode(User.self, from: topStoriesURL)
        } catch {
            isError = true
            print(error.localizedDescription)
        }
        
        isLoaded = true
    }
    
    var body: some View {
        NavigationStack {
            if !monitor.isActive {
                VStack {
                    Spacer()
                    
                    Image(systemName: "network.slash")
                        .font(.headline)
                    
                    Text("You're offline.")
                        .font(.headline)
                    
                    Spacer()
                }
            } else if !isLoaded {
                VStack {
                    Spacer()
                    
                    ProgressView()
                        .controlSize(.extraLarge)
                    
                    Text("Loading user profile...")
                        .font(.headline)
                    
                    Spacer()
                }
            } else if isError {
                VStack {
                    Spacer()
                    
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    
                    Text("This user doesn't exist.")
                        .font(.headline)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Text("\(id)")
                        .font(.largeTitle)
                        .bold()
                    
                    Button {
                        withAnimation {
                            followingUser.toggle()
                        }
                    } label: {
                        Text(followingUser ? "FOLLOWING" : "FOLLOW")
                            .padding(8)
                            .foregroundStyle(.white)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                            .bold()
                    }
                    
                    Label("\(user.karma)", systemImage: "arrowshape.up")
                    Label("joined \(user.created.timeIntervalToString())", systemImage: "clock")
                    
                    VStack(alignment: .leading) {
                        Text("Submissions: \(user.submitted)")
                            .font(.subheadline)
                    }
                }
                .navigationTitle(id)
                .navigationBarTitleDisplayMode(.inline)
                .refreshable {
                    Task {
                        await refreshData()
                    }
                }
            }
        }
        .onAppear {
            Task {
                await refreshData()
            }
        }
    }
}

#Preview {
    UserView(id: "jl")
}
