//
//  StoryDetailView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation
import SwiftUI
import SwiftData
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var storyLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if storyLoading {
            webView.load(URLRequest(url: url))
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (result, error) in
                context.coordinator.parent.storyLoading = false
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.readyState") { (result, error) in
                if let readyState = result as? String, readyState == "complete" {
                    self.parent.storyLoading = false
                }
            }
        }
    }
}


struct StoryDetailView: View {
    private let monitor = NetworkMonitor()
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var stories: [StoryStorage]
    
    var story: Story
    
    @State private var upvotedStory = false
    @State private var storyLoading = true
    @State private var openStory = false
    //    @State private var isError = false
    //    @State private var isLoaded = false
    //    @State private var showOPExplainerAlert = false
    
    //    @State private var comments: [Comment] = []
    
    //    func refreshData() async {
    //        comments = []
    //        isError = false
    //        isLoaded = false
    //
    //        if let allComments = story.kids {
    //            for i in allComments {
    //                do {
    //                    let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(i).json")!
    //                    let comment = try await URLSession.shared.decode(Comment.self, from: storyURL)
    //
    //                    comments.append(comment)
    //                } catch {
    //                    print(error.localizedDescription)
    //                    isError = true
    //                }
    //            }
    //        }
    //
    //        isLoaded = true
    //    }
    
    func getSocialMediaPreviewImage(for url: URL) -> String? {
        let semaphore = DispatchSemaphore(value: 0)
        var previewImageURLString: String?
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading URL: \(error.localizedDescription)")
                semaphore.signal()
                return
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                semaphore.signal()
                return
            }
            
            let regex = try! NSRegularExpression(pattern: "<meta property=\"og:image\" content=\"([^\"]+)\"")
            let matches = regex.matches(in: html, range: NSRange(location: 0, length: html.utf16.count))
            if let match = matches.first {
                let range = Range(match.range(at: 1), in: html)!
                previewImageURLString = String(html[range])
            } else {
                // Fallback to favicon
                previewImageURLString = "\(url.absoluteString)/favicon.ico"
            }
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return previewImageURLString
    }
    
    func openedStoryAlready() -> Bool {
        return stories.contains(where: { $0.id == story.id })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Group {
                        Text(story.title)
                            .bold()
                            .font(.title)
                            .padding(.top, 5)
                        
                        Button {
                            openStory.toggle()
                        } label: {
                            HStack {
                                if let url = story.url {
                                    AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?sz=\(40)&domain=\(url)")) { i in
                                        i
                                            .interpolation(.none)
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    } placeholder: {
                                        ProgressView()
                                            .controlSize(.large)
                                            .frame(width: 50, height: 50)
                                    }
                                }
                                
                                if let url = story.url {
                                    Text(URL(string: url)!.hostURL().replacingOccurrences(of: "www.", with: ""))
                                        .lineLimit(1)
                                }
                            }
                        }
                        
                        if let text = story.text {
                            Text(text.parseHTML())
                        }
                        
                        if let url = story.url, let previewImageURL = getSocialMediaPreviewImage(for: URL(string: url)!) {
                            Button {
                                openStory.toggle()
                            } label: {
                                AsyncImage(url: URL(string: previewImageURL)!) { i in
                                    i.image?
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: .infinity, height: 200)
                                }
                                //                            .overlay {
                                //                                VStack {
                                //                                    Spacer()
                                //
                                //                                    Label("Open", systemImage: "safari")
                                //                                        .padding(8)
                                //                                        .foregroundStyle(.white)
                                //                                        .background(Color.accentColor)
                                //                                        .clipShape(Capsule())
                                //                                        .bold()
                                //
                                //                                    Spacer()
                                //
                                //                                    Text(URL(string: story.url)!.hostURL().replacingOccurrences(of: "www.", with: ""))
                                //                                        .lineLimit(1)
                                //                                        .frame(maxWidth: .infinity)
                                //                                        .background(.black.opacity(0.6))
                                //                                }
                                //                            }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        HStack {
                            Button {
                                withAnimation {
                                    upvotedStory.toggle()
                                }
                            } label: {
                                Label("\(story.score + (upvotedStory ? 1 : 0))", systemImage: upvotedStory ? "arrowshape.up.fill" : "arrowshape.up")
                                    .symbolEffect(.bounce, value: upvotedStory)
                            }
                            .bold()
                            
                            NavigationLink {
                                UserView(id: story.by)
                            } label: {
                                Label(story.by, systemImage: "person")
                            }
                            .bold()
                            
                            Label(story.time.timeIntervalToString(), systemImage: "clock")
                        }
                        .padding(.top, 5)
                        .foregroundStyle(.primary)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    if let descendants = story.descendants {
                        Text("\(descendants) COMMENTS")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    } else {
                        Text("0 COMMENTS")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        if let kids = story.kids {
                            ForEach(kids, id: \.self) { i in
                                CommentView(commentID: i, layer: 0, storyAuthor: story.by)
                                
                                Divider()
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    //                if !monitor.isActive {
                    //                    HStack {
                    //                        Spacer()
                    //
                    //                        VStack {
                    //                            Image(systemName: "exclamationmark.triangle")
                    //                                .foregroundStyle(.red)
                    //                                .bold()
                    //                                .font(.largeTitle)
                    //
                    //                            Text("You're offline.")
                    //                                .font(.headline)
                    //                                .bold()
                    //
                    //                            Button {
                    ////                                Task {
                    ////                                    isLoaded = false
                    ////                                    isError = false
                    ////                                    await refreshData()
                    ////                                }
                    //                            } label: {
                    //                                Label("Try again", systemImage: "arrow.trianglehead.counterclockwise.rotate.90")
                    //                            }
                    //                        }
                    //
                    //                        Spacer()
                    //                    }
                    //                    .padding(.top)
                    //                } else if isError {
                    //                    HStack {
                    //                        Spacer()
                    //
                    //                        VStack {
                    //                            Image(systemName: "exclamationmark.triangle")
                    //                                .foregroundStyle(.red)
                    //                                .bold()
                    //                                .font(.largeTitle)
                    //
                    //                            Text("An error occurred.")
                    //                                .font(.headline)
                    //                                .bold()
                    //
                    //                            Button {
                    ////                                Task {
                    ////                                    isLoaded = false
                    ////                                    isError = false
                    ////                                    await refreshData()
                    ////                                }
                    //                            } label: {
                    //                                Label("Try again", systemImage: "arrow.trianglehead.counterclockwise.rotate.90")
                    //                            }
                    //                        }
                    //
                    //                        Spacer()
                    //                    }
                    //                    .padding(.top)
                    //                } else if !isLoaded {
                    //                    HStack {
                    //                        Spacer()
                    //
                    //                        ProgressView()
                    //                            .controlSize(.extraLarge)
                    //
                    //                        Spacer()
                    //                    }
                    //                    .padding(.top)
                    //                }
                }
            }
        }
        .refreshable {
            //            Task {
            //                await refreshData()
            //            }
        }
        .onAppear {
            if !openedStoryAlready() {
                modelContext.insert(StoryStorage(id: story.id, userOpinion: .unknown, saved: false))
            }
            
            //            Task {
            //                await refreshData()
            //            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {} label: {
                    Label("Save Story", systemImage: "bookmark")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if let url = story.url {
                    ShareLink(item: URL(string: url)!) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
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
        .navigationTitle("Comments")//URL(string: story.url)!.hostURL().replacingOccurrences(of: "www.", with: ""))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $openStory) {
            if storyLoading {
                ProgressView()
                    .controlSize(.extraLarge)
            }
            
            Button("Close Story") {
                openStory.toggle()
                storyLoading = false
            }
            
            if let url = story.url {
                WebView(url: URL(string: url)!, storyLoading: $storyLoading)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

#Preview {
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
