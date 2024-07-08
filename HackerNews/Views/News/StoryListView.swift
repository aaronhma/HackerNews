//
//  StoryListView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import SwiftData

struct StoryListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var stories: [StoryStorage]
    
    var story: Story
    
    @State private var openedStory = false
    
    func openedStoryAlready() -> Bool {
        return stories.contains(where: { $0.id == story.id })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(URL(string: story.url)!.hostURL().replacingOccurrences(of: "www.", with: ""))
                .foregroundStyle(Color.accentColor)
                .lineLimit(1)
            
            Text(story.title)
                .font(.title3)
                .foregroundStyle(openedStory ? .secondary : .primary)
                .lineLimit(3)
                .bold()
            
            HStack {
                Image(systemName: "person.circle.fill")
                
                Text(story.by)
                    .lineLimit(1)
                
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "calendar.circle.fill")
                
                Text(story.time.timeIntervalToString())
                    .lineLimit(1)
                
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "arrowshape.up.circle.fill")
                    .foregroundStyle(.secondary)
                
                Text("\(story.score)")
                    .lineLimit(1)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundStyle(.secondary)
                
                Text("\(story.descendants)")
                    .lineLimit(1)
                
                Spacer()
            }
            .foregroundStyle(.secondary)
        }
        .onAppear {
            openedStory = openedStoryAlready()
        }
    }
}

#Preview {
    StoryListView(
        story: Story(
            by: "AUTHOR",
            descendants: 0,
            id: 0,
            kids: [0],
            score: 0,
            time: 0,
            title: "Title",
            type: "Type",
            url: "https://news.ycombinator.com/"
        )
    )
}
