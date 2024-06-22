//
//  StoryListView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

struct StoryListView: View {
    var story: Story
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(URL(string: story.url)!.hostURL())
                .lineLimit(1)
            
            Text(story.title)
                .lineLimit(3)
                .bold()
            
            HStack {
                Text(story.by)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                
                Label(story.time.timeIntervalToString(), systemImage: "clock")
            }
            
            HStack {
                Label("\(story.score)", systemImage: "arrowshape.up")
                Spacer()
                Label("\(story.descendants) comments", systemImage: "bubble")
                Spacer()
            }
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
