//
//  StoryDetailView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct StoryDetailView: View {
    private let monitor = NetworkMonitor()
    
    @Environment(\.modelContext) private var modelContext
    
    var story: Story
    
    @State private var isError = false
    @State private var isLoaded = false
    @State private var showOPExplainerAlert = false
    
    @State private var comments: [Comment] = []
    
    func refreshData() async {
        comments = []
        isError = false
        isLoaded = false
        
        if let allComments = story.kids {
            for i in allComments {
                do {
                    let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(i).json")!
                    let comment = try await URLSession.shared.decode(Comment.self, from: storyURL)
                    
                    comments.append(comment)
                } catch {
                    print(error.localizedDescription)
                    isError = true
                }
            }
        }
        
        isLoaded = true
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Button {
                    if let url = URL(string: story.url) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    if !monitor.isActive {
                        Rectangle()
                            .frame(width: .infinity, height: 150)
                            .opacity(0.4)
                            .blur(radius: 5)
                            .disabled(true)
                            .overlay {
                                VStack {
                                    Label("Open", systemImage: "safari")
                                        .padding(8)
                                        .foregroundStyle(.white)
                                        .background(Color.accentColor)
                                        .clipShape(Capsule())
                                        .bold()
                                    
                                    Text(URL(string: story.url)!.hostURL())
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                        .padding(.horizontal)
                                }
                            }
                    } else {
                        WebView(url: URL(string: story.url)!)
                            .frame(width: .infinity, height: 150)
                            .opacity(0.4)
                            .blur(radius: 5)
                            .disabled(true)
                            .overlay {
                                VStack {
                                    Label("Open", systemImage: "safari")
                                        .padding(8)
                                        .foregroundStyle(.white)
                                        .background(Color.accentColor)
                                        .clipShape(Capsule())
                                        .bold()
                                    
                                    Text(URL(string: story.url)!.hostURL())
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                        .padding(.horizontal)
                                }
                            }
                    }
                }
                
                Group {
                    Text(story.title)
                        .bold()
                        .font(.title)
                    
                    Label(story.type.uppercased(), systemImage: "text.document")
                    
                    HStack {
                        Label(story.by, systemImage: "person")
                        
                        Label("\(story.score)", systemImage: "arrowshape.up")
                        
                        Label(story.time.timeIntervalToString(), systemImage: "clock")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                Text("\(comments.count) COMMENTS")
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                ForEach(comments, id: \.id) { comment in
                    VStack {
                        HStack {
                            Label(comment.by, systemImage: "person")
                                .foregroundStyle(Color.accentColor)
                                .bold()
                                .padding(.top, 5)
                            
                            if comment.by == story.by {
                                Label("OP", systemImage: "circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                    .bold()
                                    .onTapGesture {
                                        showOPExplainerAlert = true
                                    }
                                    .alert("The OP (original poster) is \(story.by).", isPresented: $showOPExplainerAlert) {}
                            }
                            
                            Spacer()
                            
                            Text(comment.time.timeIntervalToString())
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(comment.text)
                            .padding(.vertical, 2)
                        
                        HStack {
                            Button {} label: {
                                Label("Upvote", systemImage: "arrowshape.up")
                            }
                            
                            Spacer()
                        }
                    }
                    
                    Divider()
                }
                .padding(.horizontal)
                //                }
                
                Divider()
                
                if !monitor.isActive {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                                .bold()
                                .font(.largeTitle)
                            
                            Text("You're offline.")
                                .font(.headline)
                                .bold()
                            
                            Button {
                                Task {
                                    isLoaded = false
                                    isError = false
                                    await refreshData()
                                }
                            } label: {
                                Label("Try again", systemImage: "arrow.trianglehead.counterclockwise.rotate.90")
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                } else if isError {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                                .bold()
                                .font(.largeTitle)
                            
                            Text("An error occurred.")
                                .font(.headline)
                                .bold()
                            
                            Button {
                                Task {
                                    isLoaded = false
                                    isError = false
                                    await refreshData()
                                }
                            } label: {
                                Label("Try again", systemImage: "arrow.trianglehead.counterclockwise.rotate.90")
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                } else if !isLoaded {
                    HStack {
                        Spacer()
                        
                        ProgressView()
                            .controlSize(.extraLarge)
                        
                        Spacer()
                    }
                    .padding(.top)
                }
            }
        }
        .refreshable {
            Task {
                await refreshData()
            }
        }
        .onAppear {
            modelContext.insert(StoryStorage(id: story.id, userOpinion: .unknown, saved: false))
            
            Task {
                await refreshData()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {} label: {
                    Label("Save Story", systemImage: "bookmark")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: URL(string: story.url)!) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Section {
                        Button {
                            UIPasteboard.general.string = story.url
                        } label: {
                            Label("Copy Link", systemImage: "link")
                        }
                    }
                    
                    Section {
                        Button(role: .destructive) {} label: {
                            Label("Block Website", systemImage: "minus.circle")
                        }
                        
                        Button(role: .destructive) {} label: {
                            Label("Block Topic", systemImage: "minus.circle")
                        }
                        
                        Button(role: .destructive) {} label: {
                            Label("Block Poster", systemImage: "hand.raised")
                        }
                        
                        Button(role: .destructive) {} label: {
                            Label("Report Content", systemImage: "minus.circle")
                        }
                    }
                } label: {
                    Label("Story Options", systemImage: "ellipsis")
                }
            }
        }
        .navigationTitle(URL(string: story.url)!.hostURL())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StoryDetailView(
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
        .modelContainer(for: StoryStorage.self, inMemory: true)
    }
}
