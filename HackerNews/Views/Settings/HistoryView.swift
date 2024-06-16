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
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            EditButton()
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: StoryStorage.self, inMemory: true)
}
