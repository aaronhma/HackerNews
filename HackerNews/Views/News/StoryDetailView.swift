//
//  StoryDetailView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import SwiftData
import WebKit
import TipKit
import SwiftSoup
import SafariServices

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
            //            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (result, error) in
            //                context.coordinator.parent.storyLoading = false
            //            }
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
        
//        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//            if let url = navigationAction.request.url, url.absoluteString != "https://example.com" {
//                decisionHandler(.cancel)
//            } else {
//                decisionHandler(.allow)
//            }
//        }
    }
}

struct UpvoteView: UIViewRepresentable {
    let webView: WKWebView
    
    let url: URL
    let storyID: Int
    let upvote: Bool
    @Binding var extractedText: String
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: UpvoteView
        
        init(_ parent: UpvoteView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let id = self.parent.upvote ? "up_\(self.parent.storyID)" : "un_\(self.parent.storyID)"
            
            webView.evaluateJavaScript("document.getElementById('\(id)').href") { result, error in
                if let text = result as? String {
                    self.parent.extractedText = text
                    print("Extracted text: \(text)")
                    
                    URLSession.shared.dataTask(with: URLRequest(url: URL(string: text)!)) { data, response, error in
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                            return
                        }
                        
                        if let data = data, let html = String(data: data, encoding: .utf8) {
                            print(html)
                        } else {
                            print("No data returned")
                        }
                    }.resume()
                }
            }
            
            webView.evaluateJavaScript("document.getElementById('me').href") { result, error in
                if let text = result as? String {
                    print("Extracted text: \(text)")
                }
            }
            
            webView.evaluateJavaScript("document.getElementById('\(id)').click()") { _, _ in
                print("Clicked...")
            }
        }
    }
}

struct StoryIDDetailView: View {
    var id: Int
    @State private var story = Story(by: "", id: 0, score: 0, time: 0, title: "", type: "")
    
    @AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
    @AppStorage("accountAuth") private var accountAuth = AppSettings.accountAuth
    
    @State private var isLoaded = false
    @State private var isError = false
    
    func refreshData() async {
        isLoaded = false
        isError = false
        
        do {
            let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
            story = try await URLSession.shared.decode(Story.self, from: storyURL)
            
            if story.url == nil {
                story.url = "https://news.ycombinator.com/item?id=\(story.id)"
            }
        } catch {
            isError = true
            fatalError(error.localizedDescription)
        }
        
        isLoaded = true
    }
    
    var body: some View {
        if isLoaded {
            StoryDetailView(story: story)
        } else {
            ProgressView()
                .controlSize(.extraLarge)
        }
    }
}

struct StoryDetailView: View {
    private let monitor = NetworkMonitor()
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var stories: [StoryStorage]
    @Namespace() var namespace
    
    var story: Story
    
    @State private var upvotedStory = false
    @State private var storyLoading = true
    @State private var openStory = false
    
    @AppStorage("apiKey") private var apiKey = AppSettings.apiKey
    
    @State private var summarizeAIShown = false
    @State private var angle: Double = 0
    @State private var direction: Double = 1
    @State private var animationStarted = false
    @State private var shakeOffset: CGFloat = 0
    
    @State private var authToken = ""
    
    @AppStorage("browserPreferenceInApp") private var browserPreferenceInApp = AppSettings.browserPreferenceInApp
    
    let pinchToSummarizeDiscussionTip = PinchToSummarizeDiscussionTip()
    
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
    
    
    @AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
    @AppStorage("accountAuth") private var accountAuth = AppSettings.accountAuth
    
    let webView = WKWebView()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if animationStarted {
                    Button("Stop Summarizing...") {
                        animationStarted.toggle()
                    }
                }
                
                NavigationStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Group {
                                Text(story.title)
                                    .bold()
                                    .font(.title)
                                    .padding(.top, 5)
                                
                                Button {
                                    if browserPreferenceInApp {
                                        openStory.toggle()
                                    } else {
                                        if let url = URL(string: story.url!) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
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
                                        if browserPreferenceInApp {
                                            openStory.toggle()
                                        } else {
                                            if let url = URL(string: story.url!) {
                                                UIApplication.shared.open(url)
                                            }
                                        }
                                    } label: {
                                        AsyncImage(url: URL(string: previewImageURL)!) { i in
                                            i.image?
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: .infinity, height: 200)
                                        }
                                        .overlay {
                                            VStack {
                                                Spacer()
                                                
                                                Label("Open", systemImage: "safari")
                                                    .padding(8)
                                                    .foregroundStyle(.white)
                                                    .background(Color.accentColor)
                                                    .clipShape(Capsule())
                                                    .bold()
                                                
                                                Spacer()
                                                //
                                                //                                    Text(URL(string: story.url)!.hostURL().replacingOccurrences(of: "www.", with: ""))
                                                //                                        .lineLimit(1)
                                                //                                        .frame(maxWidth: .infinity)
                                                //                                        .background(.black.opacity(0.6))
                                            }
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                UpvoteView(webView: webView, url: URL(string: story.url!)!, storyID: story.id, upvote: true, extractedText: $authToken)
                                
                                HStack {
                                    Button {
                                        webView.load(URLRequest(url: URL(string: "https://news.ycombinator.com/item?id=\(story.id)")!))
                                        
                                        withAnimation {
                                            upvotedStory.toggle()
                                        }
                                    } label: {
                                        Label("\(story.score + (upvotedStory ? 1 : 0))", systemImage: upvotedStory ? "arrowshape.up.fill" : "arrowshape.up")
                                            .symbolEffect(.bounce, value: upvotedStory)
                                    }
                                    .sensoryFeedback(.success, trigger: upvotedStory)
                                    .bold()
                                    
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 5, height: 5)
                                        .foregroundStyle(.secondary)
                                    
                                    NavigationLink {
                                        if #available(iOS 18.0, *) {
                                            UserView(id: story.by)
                                                .navigationTransition(.zoom(sourceID: story, in: namespace))
                                        } else {
                                            UserView(id: story.by)
                                        }
                                    } label: {
                                        Label(story.by, systemImage: "person")
                                    }
                                    .bold()
                                    
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 5, height: 5)
                                        .foregroundStyle(.secondary)
                                    
                                    Label(story.time.timeIntervalToString(), systemImage: "clock")
                                }
                                .padding(.top, 5)
                                .foregroundStyle(.primary)
                            }
                            .padding(.horizontal)
                            
                            Divider()
                            
                            HStack {
                                if let descendants = story.descendants {
                                    Text("\(descendants) COMMENTS")
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                } else {
                                    Text("0 COMMENTS")
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal)
                                }
                                
                                Spacer()
                                
                                Button {
                                    animationStarted.toggle()
                                    pinchToSummarizeDiscussionTip.invalidate(reason: .actionPerformed)
                                } label: {
                                    Label("Summarize", systemImage: "wand.and.sparkles")
                                }
                                .disabled(story.descendants == 0)
                                .padding(.trailing)
                                .popoverTip(pinchToSummarizeDiscussionTip) { action in
                                    guard action.id == "summarize-discussion" else { return }
                                    animationStarted.toggle()
                                    pinchToSummarizeDiscussionTip.invalidate(reason: .actionPerformed)
                                }
                            }
                            .padding(.bottom, 2)
                            
                            if accountUserName.isEmpty && accountAuth.isEmpty {
                                NavigationLink {
                                    LoginView()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.bubble")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                            .padding()
                                            .background(.blue)
                                            .foregroundStyle(.white)
                                            .frame(width: 30, height: 30)
                                            .clipShape(RoundedRectangle(cornerRadius: 32))
                                        
                                        VStack(alignment: .leading) {
                                            Text("Join the conversation.")
                                                .bold()
                                            
                                            Text("Sign in to share your thoughts.")
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .foregroundStyle(.primary)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
                            } else {
                                NavigationLink {
                                    LoginView()
                                } label: {
                                    HStack {
                                        Image(systemName: "plus.bubble")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 18, height: 18)
                                            .padding()
                                            .background(.blue)
                                            .foregroundStyle(.white)
                                            .frame(width: 30, height: 30)
                                            .clipShape(RoundedRectangle(cornerRadius: 32))
                                        
                                        VStack(alignment: .leading) {
                                            Text("SIGNED_IN")
                                                .bold()
                                            
                                            Text("wait until next release for comments")
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .foregroundStyle(.primary)
                                .padding(.horizontal)
                                .padding(.bottom, 5)
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
                    .navigationTitle(animationStarted ? "Summarizing..." : URL(string: story.url!)!.hostURL().replacingOccurrences(of: "www.", with: "")) // "Comments"
                    .navigationBarTitleDisplayMode(.inline)
                    .refreshable {
                        //            Task {
                        //                await refreshData()
                        //            }
                    }
                    .onAppear {
                        if !openedStoryAlready() {
                            modelContext.insert(StoryStorage(id: story.id, userOpinion: .unknown, saved: false))
                        }
                        // webView.load(URLRequest(url: URL(string: "https://news.ycombinator.com/item?id=40940225")!))
                        
                        Task {
                            await PinchToSummarizeDiscussionTip.tipViewedTimes.donate()
                        }
                        
                        //            Task {
                        //                await refreshData()
                        //            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .sheet(isPresented: $openStory) {
                        NavigationStack {
                            if storyLoading {
                                ProgressView()
                                    .controlSize(.extraLarge)
                                    .padding(.top)
                            }
                            
                            HStack {
                                Button("Close Story") {
                                    openStory.toggle()
                                    storyLoading = false
                                }
                                .padding(.top)
                                
                                Button {} label: {}
                            }
                            
                            if let url = story.url {
                                WebView(url: URL(string: url)!, storyLoading: $storyLoading)
                                    .edgesIgnoringSafeArea(.all)
                            }
                        }
                        .presentationDetents([.large, .medium], selection: .constant(.large))
                    }
                }
                .rotationEffect(Angle(degrees: animationStarted ? angle : 0))
                .rotation3DEffect(.degrees(animationStarted ? 20 : 0), axis: (x: 1, y: 0, z: 0))
                //                .rotationEffect(Angle(degrees: animationStarted ? 45 : 0))
                .offset(x: animationStarted ? shakeOffset : 0, y: 0)
                .scaleEffect(animationStarted ? 0.5 : 1.0)
                
                .onChange(of: animationStarted) {
                    //                    if animationStarted {
                    //                        Timer.scheduledTimer(withTimeInterval: 0.005, repeats: true) { _ in
                    //                            withAnimation(.easeInOut(duration: 0.2)) {
                    //                                self.angle += self.direction
                    //                                if self.angle >= 45 || self.angle <= -45 {
                    //                                    self.direction *= -1
                    //
                    //                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    //                                    generator.impactOccurred()
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                    if animationStarted {
                        withAnimation {
                            angle = 25
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                angle = -25
                            }
                        }
                        // repeat the animation
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            withAnimation {
                                angle = 25
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    angle = -25
                                }
                            }
                        }
                    }
                }
                //                .gesture(
                //                    MagnificationGesture()
                //                        .onChanged { value in
                //                            summarizeAIShown.toggle()
                //                            scale = value
                //                            if value < 1.0 && !animationStarted {
                //                                animationStarted = true
                //                                withAnimation {
                //                                    offset = geometry.size.width / 2
                //                                }
                //                            }
                //                        }
                //                )
                //
                //                .scaleEffect(x: 1, y: scale)
                //                .gesture(
                //                    MagnificationGesture()
                //                        .onChanged { value in
                //                            summarizeAIShown.toggle()
                //                            scale = value
                //                            if value < 1.0 && !animationStarted {
                //                                animationStarted = true
                //                                withAnimation {
                //                                    offset = geometry.size.width / 2
                //                                }
                //                            }
                //                        }
                //                )
                //                .onChange(of: animationStarted) { _ in
                //                    withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                //                        shakeOffset = 10
                //                    }
                //                }
                
                if animationStarted {
                    Image(systemName: "brain")
                        .resizable()
                        .frame(width: 25, height: 25)
                    
                    Text("ChatGPT")
                        .font(.largeTitle)
                        .padding()
                    
                    TextField("Enter your OpenAI API key", text: $apiKey)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    StoryDetailView(
        story: Story(
            by: "AUTHOR",
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
    .task {
        try? Tips.resetDatastore()
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault),
        ])
    }
}
