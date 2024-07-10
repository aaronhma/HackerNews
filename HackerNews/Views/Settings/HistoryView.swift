//
//  HistoryView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab = "All"
    
    @Query var history: [StoryStorage]
    
    @State private var allDeleted = false
    
    func delete(_ indexSet: IndexSet) {
        for i in indexSet {
            let story = history[i]
            modelContext.delete(story)
        }
    }
    
    @State private var stories: [Story] = []
    @State private var isLoaded = true
    
    @Namespace() var namespace
    
    func refreshData() async {
        isLoaded = false
        
        for i in history {
            do {
                let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(i.id).json")!
                var story = try await URLSession.shared.decode(Story.self, from: storyURL)
                
                if story.url == nil {
                    story.url = "https://news.ycombinator.com/item?id=\(story.id)"
                }
                
                stories.append(story)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        isLoaded = true
    }
    
    var body: some View {
        VStack {
            if allDeleted || history.isEmpty {
                VStack {
                    Spacer()
                    
                    Image(systemName: "clock.arrow.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(.bottom, 10)
                    
                    Text("No History")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 10)
                    
                    Text("It's always a great day to learn! :)")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 30)
                    
                    Spacer()
                }
            }
            
            List {
                if !allDeleted && !history.isEmpty {
                    Section {
                        Button(role: .destructive) {
                            do {
                                try modelContext.delete(model: StoryStorage.self)
                                
                                withAnimation {
                                    allDeleted.toggle()
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        } label: {
                            Label("Clear History", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    
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
                            //                        .swipeActions(edge: .trailing) {
                            //                            Button("Delete", systemImage: "trash", role: .destructive) {
                            //                                modelContext.delete(story)
                            //                            }
                            //                        }
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
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !allDeleted && !stories.isEmpty {
                EditButton()
            }
        }
        .onAppear {
            Task {
                await refreshData()
            }
        }
        .refreshable {
            Task {
                await refreshData()
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .modelContainer(for: StoryStorage.self, inMemory: true)
    }
}
