//
//  CommentView.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/5/24.
//

import SwiftUI

struct CommentView: View {
    var commentID: Int
    var layer: Int
    var storyAuthor: String
    
    @State private var comment: Comment = Comment(by: "", id: 0, parent: 0, text: "", time: 0, type: "")
    @State private var isError = false
    @State private var isLoaded = false
    
    @State private var collapsedComment = false
    @State private var showOPExplainerAlert = false
    
    func refreshData() async {
        comment = Comment(by: "", id: 0, parent: 0, text: "", time: 0, type: "")
        isError = false
        isLoaded = false
        
        do {
            let commentURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(commentID).json")!
            comment = try await URLSession.shared.decode(Comment.self, from: commentURL)
        } catch {
            comment = Comment(by: "[deleted]", id: 0, parent: 0, text: "[deleted]", time: Date.now.timeIntervalSince1970, type: "comment")
            print(error.localizedDescription, commentID)
            
            isError = true
        }
        
        isLoaded = true
    }
    
    var body: some View {
        VStack {
            if comment.text != "[deleted]" {
                if isLoaded {
                    ZStack(alignment: .leading) {
                        if layer != 0 {
                            Rectangle()
                                .fill(.secondary)
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                        
                        VStack {
                            HStack {
                                NavigationLink {
                                    UserView(id: comment.by)
                                } label: {
                                    Label(comment.by, systemImage: "person")
                                        .lineLimit(1)
                                        .foregroundStyle(Color.accentColor)
                                        .bold()
                                        .padding(.top, 5)
                                }
                                
                                if storyAuthor == comment.by {
                                    Label("OP", systemImage: "circle.fill")
                                        .font(.subheadline)
                                        .foregroundStyle(.blue)
                                        .bold()
                                        .onTapGesture {
                                            showOPExplainerAlert = true
                                        }
                                        .alert("OP = Original Poster\nThe OP is \(storyAuthor).", isPresented: $showOPExplainerAlert) {}
                                }
                                
                                Spacer()
                                
                                Button {} label: {
                                    Image(systemName: "arrowshape.up")
                                }
                                
                                Button {
                                    collapsedComment.toggle()
                                } label: {
                                    Label(collapsedComment ? "Open" : "Close", systemImage: collapsedComment ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                                }
                                
                                Text(comment.time.timeIntervalToString())
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !collapsedComment {
                                HStack {
                                    Text(comment.text.parseHTML())
                                        .padding(.vertical, 2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Spacer()
                                }
                                
                                if let kids = comment.kids {
                                    ForEach(kids, id: \.self) { i in
                                        CommentView(commentID: i, layer: layer + 1, storyAuthor: storyAuthor)
                                    }
                                }
                            }
                        }
                        .padding(.leading, layer == 0 ? 0 : 10)
                    }
                } else {
                    ProgressView()
                        .controlSize(.extraLarge)
                }
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
    CommentView(commentID: 2921983, layer: 0, storyAuthor: "norvig")
}
