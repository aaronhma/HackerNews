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
    
    @State private var showOPExplainerAlert = false
    
    func refreshData() async {
        comment = Comment(by: "", id: 0, parent: 0, text: "", time: 0, type: "")
        isError = false
        isLoaded = false
        
        do {
            let commentURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(commentID).json")!
            comment = try await URLSession.shared.decode(Comment.self, from: commentURL)
        } catch {
            print(error.localizedDescription)
            isError = true
        }
        
        isLoaded = true
    }
    
    var body: some View {
        VStack {
            if isLoaded {
                HStack {
                    NavigationLink {
                        UserView(id: comment.by)
                    } label: {
                        Label(comment.by, systemImage: "person")
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
                            .alert("OP = Original Poster", isPresented: $showOPExplainerAlert) {}
                        //                        .alert("The OP (original poster) is \(story.by).", isPresented: $showOPExplainerAlert) {}
                    }
                    
                    Spacer()
                    
                    Button {} label: {
                        Image(systemName: "arrowshape.up")
                    }
                    
                    Text(comment.time.timeIntervalToString())
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text(comment.text.parseHTML())
                        .padding(.vertical, 2)
                    
                    Spacer()
                }
                
                if let kids = comment.kids {
                    ForEach(kids, id: \.self) { i in
                        HStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 2, height: .infinity)
                            
                            CommentView(commentID: i, layer: layer + 1, storyAuthor: storyAuthor)
                            //                            .padding(.leading, CGFloat((layer + 1) * 5))
                            
                            //                        Divider()
                        }
                    }
                }
            } else {
                ProgressView()
                    .controlSize(.extraLarge)
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
