//
//  TopStoriesView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

func showShareSheet(url: URL) {
	let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
	UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityVC, animated: true, completion: nil)
}

struct TopStoriesView: View {
	private let monitor = NetworkMonitor()
	
	@Environment(\.colorScheme) var colorScheme
	
	@State private var currentTime = Date()
	let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect() // 3600 seconds = 1 hour
	
	@State private var isError = false
	@State private var isLoaded = false
	@State private var autoRefreshAlert = false
	@State private var topStories: [Int] = []
	@State private var stories: [Story] = []
	@State private var tempStoryCache: [Story] = []
	
	@State private var selectedTab = "Top Stories"
	@State private var selectedTabURL = "https://hacker-news.firebaseio.com/v0/topstories.json"
	
	@State private var currentStoryNum = 0
	@State private var numberOfStories = 5
	@State private var showOfflineMessage = true
	
	@State private var scrollToIndex: Int? = nil
	
	@State private var showSignInRequiredSheet = false
	@State private var showingSearchSheet = false
	
	@Namespace() var namespace
	
	private var tagName = ["Top Stories", "New Stories", "Best Stories", "Ask HN", "Show HN", "Jobs"]
	private var tagIcon = ["arrowshape.up", "newspaper", "trophy", "questionmark.app", "eye", "briefcase"]
	
	func refreshData() async {
		topStories = []
		stories = []
		tempStoryCache = []
		isError = false
		isLoaded = false
		currentStoryNum = 0
		
		let config = URLSessionConfiguration.default
		config.allowsCellularAccess = true
		config.allowsExpensiveNetworkAccess = true
		config.allowsConstrainedNetworkAccess = true
		config.waitsForConnectivity = true
		config.requestCachePolicy = .reloadIgnoringLocalCacheData
		
		do {
			let topStoriesURL = URL(string: selectedTabURL)!
			topStories = try await URLSession.shared.decode(from: topStoriesURL)
		} catch {
			isError = true
			print(error.localizedDescription)
		}
		
		await fetchNextFewStories()
	}
	
	func fetchNextFewStories() async {
		isLoaded = false
		
		for i in currentStoryNum..<(currentStoryNum + numberOfStories) {
			if i > topStories.count - 1 {
				break
			}
			
			do {
				let storyURL = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(topStories[i]).json")!
				//                print(storyURL.absoluteString, currentStoriesIndex, currentBatchLoadedStories)
				var story = try await URLSession.shared.decode(Story.self, from: storyURL)
				
				if story.url == nil {
					story.url = "https://news.ycombinator.com/item?id=\(story.id)"
				}
				
				tempStoryCache.append(story)
			} catch {
				isError = true
				print(error.localizedDescription)
			}
		}
		
		for i in tempStoryCache {
			stories.append(i)
		}
		
		currentStoryNum += numberOfStories
		isLoaded = true
		autoRefreshAlert = false
		tempStoryCache = []
	}
	
	var body: some View {
		NavigationStack {
			List {
				ScrollViewReader { proxy in
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack {
							ForEach(Array(zip(tagName.indices, tagName)), id: \.0) { i, name in
								Button {
									withAnimation {
										selectedTab = name
										
										selectedTabURL = switch selectedTab {
										case "Top Stories":
											"https://hacker-news.firebaseio.com/v0/topstories.json"
										case "New Stories":
											"https://hacker-news.firebaseio.com/v0/newstories.json"
										case "Best Stories":
											"https://hacker-news.firebaseio.com/v0/beststories.json"
										case "Ask HN":
											"https://hacker-news.firebaseio.com/v0/askstories.json"
										case "Show HN":
											"https://hacker-news.firebaseio.com/v0/showstories.json"
										case "Jobs":
											"https://hacker-news.firebaseio.com/v0/jobstories.json"
										default:
											fatalError("\(selectedTab) doesn't exist.")
										}
										
										Task {
											await refreshData()
										}
										
										proxy.scrollTo(i, anchor: .center)
									}
								} label: {
									Label(name, systemImage: selectedTab == name ? "\(tagIcon[i]).fill" : tagIcon[i])
										.padding(.vertical, 8)
										.padding(.horizontal, 8)
										.background(selectedTab == name ? .blue : .secondary.opacity(0.15))
										.foregroundStyle(colorScheme == .dark ? .white : (selectedTab == name ? .white : .black))
										.clipShape(RoundedRectangle(cornerRadius: 10))
										.symbolEffect(.bounce, value: selectedTab == name)
										.bold(selectedTab == name)
								}
								.sensoryFeedback(.success, trigger: selectedTab)
								.padding(.leading, i == 0 ? 10 : 0)
								.padding(.trailing, i == tagName.count - 1 ? 10 : 0)
							}
						}
					}
					.onChange(of: scrollToIndex) {
						withAnimation {
							if let newIndex = scrollToIndex {
								proxy.scrollTo(newIndex, anchor: .center)
							}
						}
					}
				}
				.frame(height: 50)
				.listRowInsets(EdgeInsets())
				.listRowSpacing(0)
				.listRowSeparator(.hidden)
				
				Text(currentTime, format: .dateTime.month(.wide).day().year())
					.listRowSeparator(.hidden)
					.foregroundStyle(.secondary)
					.font(.largeTitle)
					.bold()
				
				if autoRefreshAlert {
					HStack {
						Image(systemName: "newspaper")
							.bold()
						
						Text("Checking for new stories...")
							.bold()
					}
				}
				
				if !monitor.isActive && showOfflineMessage {
					Section {
						Button {
							showOfflineMessage = false
						} label: {
							HStack {
								Image(systemName: "exclamationmark.triangle")
									.foregroundStyle(.red)
									.bold()
								
								Text("You're offline.")
									.bold()
								
								Spacer()
								
								Image(systemName: "xmark.circle.fill")
									.foregroundStyle(.secondary)
							}
						}
					}
					.listRowSeparator(.hidden)
				}
				
				if isError {
					Section {
						Button {
							Task {
								await refreshData()
							}
						} label: {
							HStack {
								Image(systemName: "exclamationmark.triangle")
									.foregroundStyle(.red)
									.bold()
								
								Text("Unexpected error when loading stories.")
									.bold()
							}
						}
					}
					.listRowSeparator(.hidden)
				}
				
				Section {
					ForEach(Array(zip(stories.indices, stories)), id: \.0) { i, story in
						NavigationLink {
							if #available(iOS 18.0, *) {
								StoryDetailView(story: story)
									.navigationTransition(.zoom(sourceID: story, in: namespace))
							} else {
								StoryDetailView(story: story)
							}
						} label: {
							StoryListView(story: story, num: i + 1)
						}
						//                                .allowsHitTesting(true)
						.padding(.vertical, 5)
						.padding(.horizontal)
						//                                .buttonStyle(PlainButtonStyle())
						.listRowInsets(EdgeInsets())
						.listRowSpacing(5)
						.listRowSeparatorTint(.secondary)
						.disabled(!monitor.isActive)
						.contextMenu {
							Section {
								NavigationLink {
									if #available(iOS 18.0, *) {
										StoryDetailView(story: story)
											.navigationTransition(.zoom(sourceID: story, in: namespace))
									} else {
										StoryDetailView(story: story)
									}
								} label: {
									Label(
										"Read Story",
										systemImage: "newspaper"
									)
								}
								
								NavigationLink {
									if #available(iOS 18.0, *) {
										UserView(id: story.by)
											.navigationTransition(.zoom(sourceID: story, in: namespace))
									} else {
										UserView(id: story.by)
									}
								} label: {
									Label("View Profile", systemImage: "person")
								}
							}
							
							Section {
								Button {} label: {
									Label("Upvote", systemImage: "arrowshape.up")
								}
							}
							
							Section {
								Button {} label: {
									Label("Save Story", systemImage: "bookmark")
								}
							}
							
							Section {
								Button {
									if let url = story.url {
										showShareSheet(url: URL(string: url)!)
									}
								} label: {
									Label("Share", systemImage: "square.and.arrow.up")
								}
								
								Button {
									UIPasteboard.general.string = story.url
								} label: {
									Label("Copy Link", systemImage: "link")
								}
							}
							
							Section {
								Button(role: .destructive) {} label: {
									Label("Block Topic", systemImage: "minus.circle")
								}
								
								Button(role: .destructive) {} label: {
									Label("Block Poster", systemImage: "hand.raised")
								}
							}
						}
						.onAppear {
							if i + 1 == stories.count {
								Task {
									await fetchNextFewStories()
								}
							}
						}
					}
					.listRowInsets(EdgeInsets())
					
					if isLoaded && stories.isEmpty {
						VStack {
							Text("No stories found :'(.\nTry clearing your filters.")
						}
						
						Button {
							Task {
								await refreshData()
							}
						} label: {
							Text("Clear Filters")
						}
					}
				}
				
				Section {
					if stories.count != topStories.count {
						HStack {
							Spacer()
							ProgressView()
								.controlSize(.extraLarge)
							Spacer()
						}
						.padding(.vertical)
						.listRowSeparator(.hidden)
					}
				}
			}
			.listStyle(.plain)
			.refreshable {
				self.currentTime = Date()
				
				Task {
					await refreshData()
				}
			}
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						showingSearchSheet.toggle()
					} label: {
						Label("Search", systemImage: "magnifyingglass")
					}
				}
				
				ToolbarItem(placement: .topBarLeading) {
					Button {
						showSignInRequiredSheet = true
						//                        SubmitPostView()
					} label: {
						Label("Submit Post", systemImage: "plus")
					}
				}
				
#if targetEnvironment(simulator)
				ToolbarItem(placement: .topBarTrailing) {
					Menu {
						Section("View Options") {
							Button {
								Task {
									isLoaded = false
									isError = false
									await refreshData()
								}
							} label: {
								Label("Force Refresh", systemImage: "arrow.circlepath")
							}
						}
					} label: {
						Label("View Options", systemImage: "arrow.up.arrow.down")
					}
				}
#endif
				
				ToolbarItem(placement: .topBarTrailing) {
					NavigationLink {
						LoginView()
					} label: {
						Label("Profile", systemImage: "person")
					}
				}
				
				ToolbarItem(placement: .topBarTrailing) {
					NavigationLink {
						SettingsView()
					} label: {
						Label("Settings", systemImage: "gearshape")
					}
				}
			}
			.fullScreenCover(isPresented: $showingSearchSheet) {
				Search()
			}
			.sheet(isPresented: $showSignInRequiredSheet) {
				NavigationStack {
					VStack {
						ScrollView {
							Image(systemName: "arrowshape.up.fill")
								.resizable()
								.scaledToFit()
								.frame(width: 50, height: 50)
								.padding(.top)
							
							Text("Sign in to upvote.")
								.bold()
								.multilineTextAlignment(.center)
								.font(.largeTitle)
							
							Text("The best news, jobs, and discussions is on Hacker News.")
								.multilineTextAlignment(.center)
							
							Divider()
								.padding(.vertical, 20)
								.padding(.horizontal)
							
							Image(systemName: "hand.raised.circle")
								.resizable()
								.scaledToFit()
								.frame(width: 80, height: 80)
							
							Text("Privacy")
								.bold()
								.multilineTextAlignment(.center)
								.font(.largeTitle)
							
							Text("Learn how bark respects and protects your privacy.")
								.multilineTextAlignment(.center)
							
							OnboardingItem(title: "What you read is off the record.", description: "We don't collect any data from you.", icon: "newspaper", color: .red)
							OnboardingItem(title: "Throw trackers off your trail.", description: "Read articles without ads or trackers.", icon: "hand.raised.fill", color: .pink)
							OnboardingItem(title: "AI with privacy in mind.", description: "Your data is anonymized and isn't used for training.", icon: "brain.fill", color: .orange)
							OnboardingItem(title: "Free & open-source.", description: "Welcome to the community!", icon: "hand.wave.fill", color: .green)
						}
						
						Spacer()
						
						NavigationLink {
							LoginView()
						} label: {
							Text("Sign In")
								.font(.title3)
								.bold()
								.frame(maxWidth: .infinity)
						}
						.padding(.vertical)
						.foregroundStyle(.white)
						.background(.blue)
						.clipShape(RoundedRectangle(cornerRadius: 22))
						.padding(.horizontal)
						.sensoryFeedback(.success, trigger: showSignInRequiredSheet)
						
						Button {
							showSignInRequiredSheet = false
						} label: {
							Text("Not Now")
								.font(.title3)
								.bold()
								.frame(maxWidth: .infinity)
						}
						.padding(.vertical)
						.foregroundStyle(.blue)
						.background(Color(UIColor.secondarySystemBackground))
						.clipShape(RoundedRectangle(cornerRadius: 22))
						.padding(.horizontal)
						.sensoryFeedback(.success, trigger: showSignInRequiredSheet)
					}
					.navigationTitle("Sign in to upvote.")
					.navigationBarTitleDisplayMode(.inline)
				}
				.presentationDetents([])
				.interactiveDismissDisabled(true)
			}
			.navigationTitle(monitor.isActive ? selectedTab : "Offline")
		}
		.onAppear {
			Task {
				await refreshData()
			}
			
			NotificationCenter.default
				.addObserver(
					forName: .NSCalendarDayChanged,
					object: nil,
					queue: .main
				) { _ in
					autoRefreshAlert = true
					self.currentTime = Date()
					
					Task {
						await refreshData()
					}
				}
		}
		.onReceive(timer) { _ in
			autoRefreshAlert = true
			self.currentTime = Date()
			
			Task {
				await refreshData()
			}
		}
		.gesture(
			DragGesture()
				.onEnded { value in
					if value.translation.width < -50 {
						withAnimation {
							if let index = tagName.firstIndex(of: selectedTab) {
								let idx = (index + 1) % tagName.count
								selectedTab = tagName[idx]
								scrollToIndex = idx
							} else {
								fatalError("[ERROR] selectedTab doesn't work")
							}
							
							selectedTabURL = switch selectedTab {
							case "Top Stories":
								"https://hacker-news.firebaseio.com/v0/topstories.json"
							case "New Stories":
								"https://hacker-news.firebaseio.com/v0/newstories.json"
							case "Best Stories":
								"https://hacker-news.firebaseio.com/v0/beststories.json"
							case "Ask HN":
								"https://hacker-news.firebaseio.com/v0/askstories.json"
							case "Show HN":
								"https://hacker-news.firebaseio.com/v0/showstories.json"
							case "Jobs":
								"https://hacker-news.firebaseio.com/v0/jobstories.json"
							default:
								fatalError("\(selectedTab) doesn't exist.")
							}
							
							Task {
								await refreshData()
							}
						}
					} else if value.translation.width > 50 {
						withAnimation {
							if let index = tagName.firstIndex(of: selectedTab) {
								let idx = index == 0 ? tagName.count - 1 : index - 1
								selectedTab = tagName[idx]
								scrollToIndex = idx
							} else {
								isError = true
								fatalError("[ERROR] selectedTab doesn't work")
							}
							
							selectedTabURL = switch selectedTab {
							case "Top Stories":
								"https://hacker-news.firebaseio.com/v0/topstories.json"
							case "New Stories":
								"https://hacker-news.firebaseio.com/v0/newstories.json"
							case "Best Stories":
								"https://hacker-news.firebaseio.com/v0/beststories.json"
							case "Ask HN":
								"https://hacker-news.firebaseio.com/v0/askstories.json"
							case "Show HN":
								"https://hacker-news.firebaseio.com/v0/showstories.json"
							case "Jobs":
								"https://hacker-news.firebaseio.com/v0/jobstories.json"
							default:
								fatalError("\(selectedTab) doesn't exist.")
							}
							
							Task {
								await refreshData()
							}
						}
					}
				}
			, including: .gesture
		)
	}
}

#Preview {
	TopStoriesView()
}
