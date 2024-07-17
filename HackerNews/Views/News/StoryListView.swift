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
    var num: Int?
    var showOpenedStory = true
    
    @State private var openedStory = false
    
    func openedStoryAlready() -> Bool {
        return stories.contains(where: { $0.id == story.id })
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let url = story.url {
                HStack {
                    if let n = num {
                        Text("\(n).")
                    }
                    
                    Text(URL(string: url)!.hostURL().replacingOccurrences(of: "www.", with: ""))
                        .foregroundStyle(Color.accentColor)
                        .lineLimit(1)
                    
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 5, height: 5)
                        .foregroundStyle(.secondary)
                    
                    Text(story.time.timeIntervalToString())
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(story.title)
                .multilineTextAlignment(.leading)
                .font(.title3)
                .foregroundStyle(openedStory && showOpenedStory ? .secondary : .primary)
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
                
                Image(systemName: "arrowshape.up.circle.fill")
                    .foregroundStyle(.secondary)
                
                Text("\(story.score)")
                    .lineLimit(1)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .foregroundStyle(.secondary)
                
                if let descendants = story.descendants {
                    Text("\(descendants)")
                        .lineLimit(1)
                } else {
                    Text("0")
                }
                
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
