//
//  TopStoriesView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

struct TopStoriesView: View {
    @State private var navigationPath = NavigationPath()
    
    @State private var isError = false
    @State private var isLoaded = false
    @State private var stories: [Story] = []
    
    @State private var numberOfStories = 10
    
    func refreshData() async {
        stories = []
        isError = false
        isLoaded = false
        
        var topStories: [Int] = []
        
        do {
            let topStoriesURL = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
            topStories = try await URLSession.shared.decode(from: topStoriesURL)
        } catch {
            isError = true
            print(error.localizedDescription)
        }
        
        isLoaded = true
        
        for i in topStories {
            if stories.count == numberOfStories { break }
            
            do {
                let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(i).json")!
                print(storyURL.absoluteString)
                let story = try await URLSession.shared.decode(Story.self, from: storyURL)
                
                stories.append(story)
            } catch {
                isError = true
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                List {
                    Section {} footer: {
                        Text(Date.now, format: .dateTime.month().day())
                            .foregroundStyle(.secondary)
                            .font(.largeTitle)
                            .bold()
                    }
                    .listRowSpacing(0)
                    .listRowSeparator(.hidden)
                    
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
                                    
                                    Text("DEBUG: Job postings & polls hidden.")
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
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("# Of Stories") {
                            Button {
                                Task {
                                    numberOfStories = 50
                                    await refreshData()
                                }
                            } label: {
                                Text("50 Stories")
                            }
                            
                            Button {
                                Task {
                                    numberOfStories = 100
                                    await refreshData()
                                }
                            } label: {
                                Text("100 items")
                            }
                            
                            Button {
                                Task {
                                    numberOfStories = 12000
                                    await refreshData()
                                }
                            } label: {
                                Text("Everything")
                            }
                        }
                        
                        Section("Sort By") {
                            Button {} label: {
                                Text("Y Combinator Proprietary Formula")
                            }
                        }
                    } label: {
                        Label("View Options", systemImage: "line.3.horizontal.circle")
                    }
                }
            }
            .refreshable {
                Task {
                    await refreshData()
                }
            }
            .navigationTitle("Top Stories")
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
