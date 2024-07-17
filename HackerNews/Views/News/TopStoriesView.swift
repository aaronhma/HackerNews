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
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect() // 3600 seconds = 1 hour
    
    @State private var isError = false
    @State private var isLoaded = false
    @State private var autoRefreshAlert = false
    @State private var topStories: [Int] = []
    @State private var cachedStories: [Story] = []
    @State private var stories: [Story] = []
    
    @State private var selectedTab = "Top Stories"
    @State private var selectedTabURL = "https://hacker-news.firebaseio.com/v0/topstories.json"
    
    @State private var numberOfStories = 10
    @State private var showOfflineMessage = true
    
    @State private var scrollToIndex: Int? = nil
    
    @Namespace() var namespace
    
    private var tagName = ["Top Stories", "New Stories", "Best Stories", "Ask HN", "Show HN", "Jobs"]
    private var tagIcon = ["arrowshape.up", "newspaper", "trophy", "questionmark.app", "eye", "briefcase"]
    
    func refreshData() async {
        topStories = []
        stories = []
        isError = false
        isLoaded = false
        
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        do {
            let topStoriesURL = URL(string: selectedTabURL)!
            topStories = try await URLSession.shared.decode(from: topStoriesURL)
        } catch {
            isError = true
            fatalError(error.localizedDescription)
        }
        
        for i in topStories {
            do {
                let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(i).json")!
                //                print(storyURL.absoluteString, currentStoriesIndex, currentBatchLoadedStories)
                var story = try await URLSession.shared.decode(Story.self, from: storyURL)
                
                if story.url == nil {
                    story.url = "https://news.ycombinator.com/item?id=\(story.id)"
                }
                
                cachedStories.append(story)
                
                if !cachedStories.isEmpty && cachedStories.count % numberOfStories == 0 {
                    for j in cachedStories.count - numberOfStories..<cachedStories.count {
                        stories.append(cachedStories[j])
                    }
                    
                    autoRefreshAlert = false
                }
                
#if targetEnvironment(simulator)
                if stories.count == 20 {
                    break
                }
#endif
            } catch {
                isError = true
                fatalError(error.localizedDescription)
            }
        }
        
        isLoaded = true
    }
    
    var body: some View {
        NavigationStack {
            List {
                ScrollViewReader { proxy in
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
                                            await refreshData()
                                        }
                                        
                                        proxy.scrollTo(i, anchor: .center)
                                    }
                                } label: {
                                    Label(name, systemImage: selectedTab == name ? "\(tagIcon[i]).fill" : tagIcon[i])
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 8)
                                        .background(selectedTab == name ? .blue : .secondary.opacity(0.15))
                                        .foregroundStyle(colorScheme == .dark ? .white : (selectedTab == name ? .white : .black))
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
                    .onChange(of: scrollToIndex) {
                        withAnimation {
                            if let newIndex = scrollToIndex {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                }
                .frame(height: 50)
                .listRowInsets(EdgeInsets())
                .listRowSpacing(0)
                .listRowSeparator(.hidden)
                
                Text(currentTime, format: .dateTime.month(.wide).day().year())
                    .listRowSeparator(.hidden)
                    .foregroundStyle(.secondary)
                    .font(.largeTitle)
                    .bold()
                
                if autoRefreshAlert {
                    HStack {
                        Image(systemName: "newspaper")
                            .bold()
                        
                        Text("Checking for new stories...")
                            .bold()
                    }
                }
                
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
                    .listRowSeparator(.hidden)
                }
                
                if isError {
                    Section {
                        Button {
                            Task {
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
                    .listRowSeparator(.hidden)
                }
                
                Section {
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
                                    
                                    NavigationLink {
                                        if #available(iOS 18.0, *) {
                                            UserView(id: story.by)
                                                .navigationTransition(.zoom(sourceID: story, in: namespace))
                                        } else {
                                            UserView(id: story.by)
                                        }
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
                    
                    if isLoaded && stories.isEmpty {
                        VStack {
                            Text("No stories found :'(.\nTry clearing your filters.")
                        }
                        
                        Button {
                            Task {
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
            .listStyle(.plain)
            .refreshable {
                self.currentTime = Date()
                
                Task {
                    await refreshData()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SubmitPostView()
                    } label: {
                        Label("Submit Post", systemImage: "plus")
                    }
                }
                
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
            .navigationTitle(monitor.isActive ? selectedTab : "Offline")
        }
        .onAppear {
            Task {
                await refreshData()
            }
            
            NotificationCenter.default.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { _ in
                autoRefreshAlert = true
                self.currentTime = Date()
                
                Task {
                    await refreshData()
                }
            }
        }
        .onReceive(timer) { _ in
            autoRefreshAlert = true
            self.currentTime = Date()
            
            Task {
                await refreshData()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 {
                        withAnimation {
                            if let index = tagName.firstIndex(of: selectedTab) {
                                let idx = (index + 1) % tagName.count
                                selectedTab = tagName[idx]
                                scrollToIndex = idx
                            } else {
                                fatalError("[ERROR] selectedTab doesn't work")
                            }
                            
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
                                await refreshData()
                            }
                        }
                    } else if value.translation.width > 50 {
                        withAnimation {
                            if let index = tagName.firstIndex(of: selectedTab) {
                                let idx = index == 0 ? tagName.count - 1 : index - 1
                                selectedTab = tagName[idx]
                                scrollToIndex = idx
                            } else {
                                isError = true
                                fatalError("[ERROR] selectedTab doesn't work")
                            }
                            
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
                                await refreshData()
                            }
                        }
                    }
                }
            , including: .gesture
        )
    }
}

#Preview {
    TopStoriesView()
}
