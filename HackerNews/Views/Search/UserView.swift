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
    @State private var isLoading = false
    @State private var followingUser = false
    @State private var user: User = User(created: 0, id: "", karma: 0, submitted: [])
    
    @State private var cachedStories: [Story] = []
    @State private var stories: [Story] = []
    @State private var comments: [Int] = []
    
    @State private var numberOfStories = 10
    @State private var selectedTab = "Stories"
    
    @State private var allTabs = ["Stories", "Comments"]
    
    @Namespace() var namespace
    
    @AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
    
    func refreshData() async {
        stories = []
        user = User(created: 0, id: "", karma: 0, submitted: [])
        isError = false
        isLoaded = false
        isLoading = false
        
        do {
            let userSubmittedURL = URL(string: "https://hacker-news.firebaseio.com/v0/user/\(id).json")!
            user = try await URLSession.shared.decode(User.self, from: userSubmittedURL)
        } catch {
            isError = true
            print(error.localizedDescription)
        }
        
        isLoaded = true
        
        if let submitted = user.submitted {
            for i in submitted {
                do {
                    let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(i).json")!
                    var story = try await URLSession.shared.decode(Story.self, from: storyURL)
                    
                    if story.url == nil {
                        story.url = "https://news.ycombinator.com/item?id=\(story.id)"
                    }
                    
                    cachedStories.append(story)
                    
                    if !cachedStories.isEmpty && cachedStories.count % numberOfStories == 0 {
                        for j in cachedStories.count - numberOfStories..<cachedStories.count {
                            stories.append(cachedStories[j])
                        }
                    }
                    
#if targetEnvironment(simulator)
                    if stories.count == 20 {
                        break
                    }
#endif
                } catch {
                    comments.append(i)
                    print(error.localizedDescription)
                }
            }
        }
        
        isLoading = true
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
                        .background(Color.random())
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                    
                    Text("\(id)")
                        .font(.largeTitle)
                        .bold()
                    
                    if accountUserName != id {
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
                    }
                    
                    if let about = user.about {
                        Text(about.parseHTML())
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Label("\(user.karma)", systemImage: "arrowshape.up")
                        Label("joined \(user.created.timeIntervalToString())", systemImage: "clock")
                        
                        if let submitted = user.submitted {
                            Label("\(submitted.count) submissions", systemImage: "text.bubble")
                                .font(.subheadline)
                        }
                    }
                    
                    Picker("Pick a tab", selection: $selectedTab) {
                        ForEach(allTabs, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        if selectedTab == "Stories" {
                            if stories.isEmpty {
                                Text("No Stories")
                            }
                            
                            ForEach(Array(zip(stories.indices, stories)), id: \.0) { i, story in
                                StoryListView(story: story, num: i + 1)
                                    .allowsHitTesting(true)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal)
                                    .overlay {
                                        NavigationLink {
                                            if #available(iOS 18.0, *) {
                                                StoryDetailView(story: story)
                                                    .navigationTransition(.zoom(sourceID: story, in: namespace))
                                            } else {
                                                StoryDetailView(story: story)
                                            }
                                        } label: {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                        .listRowInsets(EdgeInsets())
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .listRowInsets(EdgeInsets())
                                    .listRowSpacing(5)
                                    .listRowSeparatorTint(.secondary)
                                    .disabled(!monitor.isActive)
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
                                        }
                                        
                                        Section {
                                            Button {
                                                if let url = story.url {
                                                    showShareSheet(url: URL(string: url)!)
                                                }
                                            } label: {
                                                Label("Share", systemImage: "square.and.arrow.up")
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
                            .listRowInsets(EdgeInsets())
                        } else {
                            if comments.isEmpty {
                                Text("No Comments")
                            }
                            
                            ForEach(comments, id: \.self) { i in
                                CommentView(commentID: i, layer: 0, storyAuthor: "@@##!!(())")
                                
                                Divider()
                            }
                        }
                        
                        if !isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
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
