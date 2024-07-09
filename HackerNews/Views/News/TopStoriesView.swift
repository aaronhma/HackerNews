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
    
    @State private var isError = false
    @State private var isLoaded = false
    @State private var topStories: [Int] = []
    @State private var stories: [Story] = []
    
    @State private var selectedTab = "Top Stories"
    @State private var selectedTabURL = "https://hacker-news.firebaseio.com/v0/topstories.json"
    
    @State private var currentStoriesIndex = 0
    @State private var currentBatchLoadedStories = 0
    @State private var numberOfStories = 10
    @State private var showOfflineMessage = true
    
    @Namespace() var namespace
    
    private var tagName = ["Top Stories", "New Stories", "Best Stories", "Ask HN", "Show HN", "Jobs"]
    private var tagIcon = ["arrowshape.up", "newspaper", "trophy", "questionmark.app", "eye", "briefcase"]
    
    func refreshData() async {
        topStories = []
        stories = []
        currentStoriesIndex = 0
        currentBatchLoadedStories = 0
        isError = false
        isLoaded = false
        
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringCacheData
        
        do {
            let topStoriesURL = URL(string: selectedTabURL)!
            topStories = try await URLSession.shared.decode(from: topStoriesURL)
            //            print(topStories.count)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        await downloadNextFewStories()
    }
    
    func downloadNextFewStories() async {
        guard !topStories.isEmpty else { return } // no stories
                                                  //        guard topStories.count >= numberOfStories else { return } // not enough stories
        
        isLoaded = false
        currentBatchLoadedStories = 0
        
        var tmpStories: [Story] = []
        
        for _ in currentStoriesIndex..<min(currentStoriesIndex + 10, topStories.count) {
            guard currentStoriesIndex < topStories.count else { return }
            
            do {
                let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(topStories[currentStoriesIndex]).json")!
                //                print(storyURL.absoluteString, currentStoriesIndex, currentBatchLoadedStories)
                currentStoriesIndex += 1
                var story = try await URLSession.shared.decode(Story.self, from: storyURL)
                
                if story.url == nil {
                    story.url = "https://news.ycombinator.com/item?id=\(story.id)"
                }
                
                tmpStories.append(story)
                currentBatchLoadedStories += 1
            } catch {
                //                isError = true
                fatalError(error.localizedDescription)
            }
        }
        
        currentStoriesIndex += 10
        currentBatchLoadedStories = 0
        
        for i in tmpStories {
            stories.append(i)
        }
        
        isLoaded = true
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(Array(zip(tagName.indices, tagName)), id: \.0) { i, name in
                                Button {
                                    withAnimation {
                                        selectedTab = name
                                        
                                        selectedTabURL = switch selectedTab {
                                        case "Top Stories":
                                            "https://hacker-news.firebaseio.com/v0/topstories.json"
                                        case "New Stories":
                                            "https://hacker-news.firebaseio.com/v0/newstories.json"
                                        case "Best Stories":
                                            "https://hacker-news.firebaseio.com/v0/beststories.json"
                                        case "Ask HN":
                                            "https://hacker-news.firebaseio.com/v0/askstories.json"
                                        case "Show HN":
                                            "https://hacker-news.firebaseio.com/v0/showstories.json"
                                        case "Jobs":
                                            "https://hacker-news.firebaseio.com/v0/jobstories.json"
                                        default:
                                            fatalError("\(selectedTab) doesn't exist.")
                                        }
                                        
                                        Task {
                                            isLoaded = false
                                            isError = false
                                            await refreshData()
                                        }
                                    }
                                } label: {
                                    Label(name, systemImage: selectedTab == name ? "\(tagIcon[i]).fill" : tagIcon[i])
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 8)
                                        .background(selectedTab == name ? .blue : .secondary)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .symbolEffect(.bounce, value: selectedTab == name)
                                        .bold(selectedTab == name)
                                }
                                .sensoryFeedback(.success, trigger: selectedTab)
                                .padding(.leading, i == 0 ? 10 : 0)
                                .padding(.trailing, i == tagName.count - 1 ? 10 : 0)
                            }
                        }
                    }
                    .frame(height: 50)
                    .listRowSpacing(0)
                    .listRowSeparator(.hidden)
                    
                    Group {
                        Text(Date.now, format: .dateTime.month(.wide).day().year())
                                .foregroundStyle(.secondary)
                                .font(.largeTitle)
                                .bold()
                        
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
                        
                        if isError {
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
                            ForEach(Array(zip(stories.indices, stories)), id: \.0) { i, story in
                                NavigationLink {
                                    StoryDetailView(story: story)
                                    // https://augmentedcode.io/2024/06/17/zoom-navigation-transition-in-swiftui/
                                    //                                    .apply {
                                    //                                        if #available(iOS 18.0, *) {
                                    //                                            .navigationTransition(.zoom(sourceID: story, in: namespace))
                                    //                                        } else {
                                    //                                            // empty modifer???
                                    //                                        }
                                    //                                    }
                                } label: {
                                    StoryListView(story: story, num: i + 1)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(!monitor.isActive)
                                .onAppear {
                                    if (i + 1) % numberOfStories == 0 {
                                        print(i)
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
                                        if let url = story.url {
                                            showShareSheet(url: URL(string: url)!)
                                        }
                                    } label: {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .tint(Color.blue)
                                }
                                .contextMenu {
                                    Section {
                                        NavigationLink {
                                            StoryDetailView(story: story)
                                        } label: {
                                            Label("Read Story", systemImage: "newspaper")
                                        }
                                        
                                        NavigationLink {
                                            UserView(id: story.by)
                                        } label: {
                                            Label("View Profile", systemImage: "person")
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
                                
                                if i != 499 {
                                    Divider()
                                }
                            }
                            //                        .listRowSeparator(.hidden)
                            
                            if isLoaded && stories.isEmpty {
                                VStack {
                                    Text("No stories found :'(.\nTry clearing your filters.")
                                }
                                
                                Button {
                                    Task {
                                        isLoaded = false
                                        isError = false
                                        await refreshData()
                                    }
                                } label: {
                                    Text("Clear Filters")
                                }
                            }
                        }
                        
                        if !isLoaded {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                Spacer()
                            }
                            .padding(.vertical)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .padding(.horizontal)
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("View Options") {
                            Button {
                                Task {
                                    isLoaded = false
                                    isError = false
                                    await refreshData()
                                }
                            } label: {
                                Label("Force Refresh", systemImage: "arrow.circlepath")
                            }
                        }
                    } label: {
                        Label("View Options", systemImage: "arrow.up.arrow.down")
                    }
                }
            }
            .refreshable {
                Task {
                    await refreshData()
                }
            }
            .navigationTitle(monitor.isActive ? selectedTab : "Offline")
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
