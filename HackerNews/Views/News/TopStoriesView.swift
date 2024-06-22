//
//  TopStoriesView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

func showShareSheet(url: URL) {
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityVC, animated: true, completion: nil)
}

struct TopStoriesView: View {
    private let monitor = NetworkMonitor()
    
    @State private var navigationPath = NavigationPath()
    
    @State private var isError = false
    @State private var isLoaded = false
    @State private var topStories: [Int] = []
    @State private var stories: [Story] = []
    
    @State private var selectedTab = "Top Stories"
    
    @State private var currentLoadedStories = 0
    @State private var numberOfStories = 10
    @State private var showDebugOptions = false
    @State private var showOfflineMessage = true
    
    private var tagName = ["Top Stories", "New", "Past", "Comments", "Ask", "Show", "Jobs"]
    private var tagIcon = ["arrowshape.up", "newspaper", "backward", "bubble", "questionmark.app", "eye", "briefcase"]
    
    func refreshData() async {
        topStories = []
        stories = []
        currentLoadedStories = 0
        isError = false
        isLoaded = false
        
        do {
            let topStoriesURL = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
            topStories = try await URLSession.shared.decode(from: topStoriesURL)
        } catch {
            isError = true
            print(error.localizedDescription)
        }
        
        isLoaded = true
        
        await downloadNextFewStories()
    }
    
    func downloadNextFewStories() async {
        guard !topStories.isEmpty else { return }
        guard currentLoadedStories < topStories.count else { return }
        
        isLoaded = false
        
        for i in currentLoadedStories..<min(currentLoadedStories + 10, topStories.count) {
            do {
                let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(topStories[i]).json")!
//                print(storyURL.absoluteString)
                let story = try await URLSession.shared.decode(Story.self, from: storyURL)
                
                stories.append(story)
            } catch {
                isError = true
//                print(error.localizedDescription)
            }
        }
        
        
        currentLoadedStories += min(currentLoadedStories + 10, topStories.count)
        
        isLoaded = true
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                if showDebugOptions {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(zip(tagName.indices, tagName)), id: \.0) { i, name in
                                Button {
                                    withAnimation {
                                        selectedTab = name
                                    }
                                } label: {
                                    Label(name, systemImage: selectedTab == name ? "\(tagIcon[i]).fill" : tagIcon[i])
                                        .padding()
                                        .background(selectedTab == name ? .blue : .secondary)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                }
                            }
                        }
                    }
                }
                
                List {
                    Section {} footer: {
                        Text(Date.now, format: .dateTime.month().day())
                            .foregroundStyle(.secondary)
                            .font(.largeTitle)
                            .bold()
                    }
                    .listRowSpacing(0)
                    .listRowSeparator(.hidden)
                    
                    if !monitor.isActive && showOfflineMessage {
                        Section {
                            Button {
                                showOfflineMessage = false
                            } label: {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.red)
                                        .bold()
                                    
                                    Text("You're offline.")
                                        .bold()
                                    
                                    Spacer()
                                    
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    if showDebugOptions && isError {
                        Section {
                            Button {
                                Task {
                                    isLoaded = false
                                    isError = false
                                    await refreshData()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.red)
                                        .bold()
                                    
                                    Text("Unexpected error when loading stories.")
                                        .bold()
                                }
                            }
                        }
                    }
                    
                    Section {
                        ForEach(stories, id: \.id) { story in
                            Button {
                                navigationPath.append(story)
                            } label: {
                                StoryListView(story: story)
                            }
                            .disabled(!monitor.isActive)
                            .onAppear {
                                if (currentLoadedStories % numberOfStories == 0) || (currentLoadedStories + numberOfStories) >= topStories.count {
                                    Task {
                                        await downloadNextFewStories()
                                    }
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {} label: {
                                    Label("Save", systemImage: "bookmark")
                                }
                                .tint(.indigo)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    showShareSheet(url: URL(string: story.url)!)
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                .tint(Color.blue)
                            }
                            .contextMenu {
                                Section {
                                    Button {} label: {
                                        Label("Like", systemImage: "hand.thumbsup")
                                    }
                                    
                                    Button {} label: {
                                        Label("Dislike", systemImage: "hand.thumbsdown")
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
                        .listRowSeparator(.hidden)
                    }
                    
                    if !isLoaded {
                        ProgressView()
                            .controlSize(.extraLarge)
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Developer") {
                            Button {
                                Task {
                                    isLoaded = false
                                    isError = false
                                    await refreshData()
                                }
                            } label: {
                                Label("Force Refresh", systemImage: "arrow.circlepath")
                            }
                            
                            Button {
                                showDebugOptions.toggle()
                            } label: {
                                Label(showDebugOptions ? "Beta Enabled" : "Use Beta", systemImage: showDebugOptions ? "checkmark" : "testtube.2")
                            }
                        }
                    } label: {
                        Label("Developer Options", systemImage: "hammer")
                    }
                }
            }
            .refreshable {
                Task {
                    await refreshData()
                }
            }
            .navigationTitle(monitor.isActive ? "Top Stories" : "Offline")
            .navigationDestination(for: Story.self) { story in
                StoryDetailView(story: story)
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
    TopStoriesView()
}
