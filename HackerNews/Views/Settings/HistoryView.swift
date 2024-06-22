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
    
    @Query(sort: \StoryStorage.id) var stories: [StoryStorage]
    
    func delete(_ indexSet: IndexSet) {
        for i in indexSet {
            let story = stories[i]
            modelContext.delete(story)
        }
    }
    
    var body: some View {
        VStack {
            if stories.isEmpty {
                VStack {
                    Spacer()
                    
                    Image(systemName: "clock.arrow.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(.bottom, 10)
                    
                    Text("No History Yet")
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
                ForEach(stories) { story in
                    Text("story id #: \(story.id)")
                        .swipeActions(edge: .leading) {
                            Button("Save", systemImage: story.saved ? "bookmark.slash" : "bookmark") {
                                story.saved.toggle()
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                modelContext.delete(story)
                            }
                        }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !stories.isEmpty {
                EditButton()
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: StoryStorage.self, inMemory: true)
}
