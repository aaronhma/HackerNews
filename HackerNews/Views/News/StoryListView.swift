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
                .foregroundStyle(Color.accentColor)
                .lineLimit(1)
            
            Text(story.title)
                .font(.title3)
                .lineLimit(3)
                .bold()
            
            HStack {
                Text(story.by)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
                
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(.secondary)
                
                Text(story.time.timeIntervalToString())
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "arrowshape.up.fill")
                    .foregroundStyle(.secondary)
                
                Text("\(story.score)")
                    .foregroundStyle(.secondary)
                
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(.secondary)
                
                Text("\(story.descendants) comments")
                    .foregroundStyle(.secondary)
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
