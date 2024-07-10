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
    @State private var user: User = User(created: 0, id: "", karma: 0, submitted: [])
    
    @State private var stories: [Story] = []
    
    @Namespace() var namespace
    
    func refreshData() async {
        user = User(created: 0, id: "", karma: 0, submitted: [])
        isError = false
        isLoaded = false
        
        do {
            let userSubmittedURL = URL(string: "https://hacker-news.firebaseio.com/v0/user/\(id).json")!
            user = try await URLSession.shared.decode(User.self, from: userSubmittedURL)
        } catch {
            isError = true
            print(error.localizedDescription)
        }
        
        if let submitted = user.submitted {
            for i in submitted {
                do {
                    let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(i).json")!
                    var story = try await URLSession.shared.decode(Story.self, from: storyURL)
                    
                    if story.url == nil {
                        story.url = "https://news.ycombinator.com/item?id=\(story.id)"
                    }
                    
                    stories.append(story)
                } catch {
                    print(error.localizedDescription)
                }
            }
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
                    .sensoryFeedback(.success, trigger: followingUser)
                    
                    if let about = user.about {
                        Text(about)
                            .foregroundStyle(.secondary)
                    }
                    
                    Label("\(user.karma)", systemImage: "arrowshape.up")
                    Label("joined \(user.created.timeIntervalToString())", systemImage: "clock")
                    
                    VStack(alignment: .leading) {
                        if let submitted = user.submitted {
                            Text("Submissions: \(submitted)")
                                .font(.subheadline)
                            
                            ForEach(Array(zip(stories.indices, stories)), id: \.0) { i, story in
                                Section {
                                    NavigationLink {
                                        if #available(iOS 18.0, *) {
                                            StoryDetailView(story: story)
                                                .navigationTransition(.zoom(sourceID: story, in: namespace))
                                        } else {
                                            StoryDetailView(story: story)
                                        }
                                    } label: {
                                        StoryListView(story: story, num: i + 1, showOpenedStory: false)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .contextMenu {
                                        Section {
                                            NavigationLink {
                                                if #available(iOS 18.0, *) {
                                                    StoryDetailView(story: story)
                                                        .navigationTransition(.zoom(sourceID: story, in: namespace))
                                                } else {
                                                    StoryDetailView(story: story)
                                                }
                                            } label: {
                                                Label("Read Story", systemImage: "newspaper")
                                            }
                                        }
                                        
                                        Section {
                                            Button {} label: {
                                                Label("Upvote", systemImage: "arrowshape.up")
                                            }
                                        }
                                        
                                        Section {
                                            Button {} label: {
                                                Label("Save Story", systemImage: "bookmark")
                                            }
                                            
                                            Button {
                                                UIPasteboard.general.string = story.url
                                            } label: {
                                                Label("Copy Link", systemImage: "link")
                                            }
                                        }
                                        
                                        Section {
                                            Button(role: .destructive) {} label: {
                                                Label("Block Topic", systemImage: "minus.circle")
                                            }
                                            
                                            Button(role: .destructive) {} label: {
                                                Label("Block Poster", systemImage: "hand.raised")
                                            }
                                        }
                                    }
                                }
                            }
                        }
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
