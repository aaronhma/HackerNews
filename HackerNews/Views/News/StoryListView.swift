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
            HStack {
                Text(story.by)
                    .foregroundStyle(.secondary)
            }
            
            Text(story.title)
            
            HStack {
                Label("\(story.score)", systemImage: "arrowshape.up")
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
