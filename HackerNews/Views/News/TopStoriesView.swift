//
//  TopStoriesView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import UIKit

func showShareSheet(url: URL) {
	let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
	UIApplication.shared.currentUIWindow()?.rootViewController?.present(
		activityVC, animated: true, completion: nil)
}

struct TopStoriesView: View {
	private let monitor = NetworkMonitor()

	@Environment(\.colorScheme) var colorScheme

	@State private var currentTime = Date()
	let timer = Timer.publish(every: 3600, on: .main, in: .common).autoconnect()  // 3600 seconds = 1 hour

	@State private var autoRefreshAlert = false

	// Replace with ViewModel
	@State private var viewModel = TopStoriesView.ViewModel()

	@State private var selectedTab = "Top Stories"
	@State private var selectedTabURL = "https://hacker-news.firebaseio.com/v0/topstories.json"

	@State private var showOfflineMessage = true
	@State private var showingEditTagsSheet = false

	@State private var scrollToIndex: Int? = nil

	@State private var showSignInRequiredSheet = false
	@State private var showingSearchSheet = false
	@State private var showingTopButtons = true

	@Namespace() var namespace

	// MARK: - Tab bar
	@State private var tabs = StoriesTab.tabs

	@State private var activeTab = StoriesTab.Tab.topStories

	@State private var tabBarScrollState: StoriesTab.Tab?
	@State private var mainViewScrollState: StoriesTab.Tab?

	@State private var progress = CGFloat.zero

	//

	@State private var tagName = [
		"Top Stories", "New Stories", "Best Stories", "Ask HN", "Show HN", "Jobs",
	]
	@State private var tagIcon = [
		"arrowshape.up", "newspaper", "trophy", "questionmark.app", "eye", "briefcase",
	]

	func refreshData() async {
		do {
			try await viewModel.fetchStories(from: selectedTabURL)
		} catch {
			viewModel.isError = true
			print(error.localizedDescription)
		}
		autoRefreshAlert = false
	}

	private func deleteTag(offsets: IndexSet) {
		tagName.remove(atOffsets: offsets)
		tagIcon.remove(atOffsets: offsets)
	}

	private func moveTag(source: IndexSet, destination: Int) {
		tagName.move(fromOffsets: source, toOffset: destination)
		tagIcon.move(fromOffsets: source, toOffset: destination)
	}

	var body: some View {
		NavigationStack {
			List {
				Section {
				} header: {
					VStack {
						HStack {
							Button {
								showingSearchSheet.toggle()
							} label: {
								HStack {
									Spacer()

									Image(systemName: "magnifyingglass")
										.bold()

									Text("Tap here to search")
										.font(.headline)
										.bold()
										.lineLimit(1)

									Spacer()
								}
								.padding(12)
								.background(colorScheme == .dark ? .regularMaterial : .bar)
								.clipShape(RoundedRectangle(cornerRadius: 32))
							}
							.modifier(BackgroundShadowModifier())
							.foregroundColor(.primary)
							.frame(maxWidth: .infinity)

							NavigationLink {
								SettingsView()
							} label: {
								Image(systemName: "gearshape")
									.bold()
									.padding(12)
									.foregroundStyle(.primary)
									.background(colorScheme == .dark ? .regularMaterial : .bar)
									.clipShape(RoundedRectangle(cornerRadius: 32))
							}
							.modifier(BackgroundShadowModifier())
						}
						.padding(.horizontal)

						Text(currentTime, format: .dateTime.month(.wide).day().year())
							.foregroundStyle(.primary)
							.font(.largeTitle)
							.bold()

						ScrollView(.horizontal) {
							HStack(spacing: 20) {
								ForEach($tabs) { $tab in
									Button {
										withAnimation(.snappy) {
											activeTab = tab.id
											mainViewScrollState = tab.id
											tabBarScrollState = tab.id
										}
									} label: {
										Label(tab.id.rawValue, systemImage: tab.icon)
											.padding(.vertical, 12)
											.foregroundStyle(
												activeTab == tab.id ? Color.primary : .gray
											)
											.contentShape(.rect)
											.symbolEffect(.bounce, value: activeTab == tab.id)
									}
									.sensoryFeedback(.selection, trigger: activeTab)
									.buttonStyle(.plain)
									.rect { rect in
										tab.size = rect.size
										tab.minX = rect.minX
									}
								}
							}
							.scrollTargetLayout()
						}
						.scrollPosition(
							id: .init(
								get: {
									return tabBarScrollState
								},
								set: { _ in

								}), anchor: .center
						)
						.overlay(alignment: .bottom) {
							ZStack(alignment: .leading) {
								Rectangle()
									.fill(.gray.opacity(0.3))
									.frame(height: 1)

								let inputRange = tabs.indices.compactMap { return CGFloat($0) }
								let outputRange = tabs.compactMap { return $0.size.width }
								let outputPositionRange = tabs.compactMap { return $0.minX }
								let indicatorWidth = progress.interpolate(
									inputRange: inputRange, outputRange: outputRange)
								let indicatorPosition = progress.interpolate(
									inputRange: inputRange, outputRange: outputPositionRange)

								Rectangle()
									.fill(.primary)
									.frame(width: indicatorWidth, height: 1.5)
									.offset(x: indicatorPosition)
							}
						}
						.safeAreaPadding(.horizontal, 15)
						.scrollIndicators(.hidden)

						ScrollViewReader { proxy in
							ScrollView(.horizontal, showsIndicators: false) {
								LazyHStack {
									ForEach(Array(zip(tagName.indices, tagName)), id: \.0) {
										i, name in
										Button {
											withAnimation {
												selectedTab = name

												selectedTabURL =
													switch selectedTab {
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
											Label(
												name,
												systemImage: selectedTab == name
													? "\(tagIcon[i]).fill" : tagIcon[i]
											)
											.padding(.vertical, 8)
											.padding(.horizontal, 8)
											//												.background(selectedTab == name ? .blue : .secondary.opacity(0.15))
											.background(selectedTab == name ? .blue : .clear)
											.background(
												selectedTab == name ? .regularMaterial : .bar
											)
											.foregroundStyle(
												colorScheme == .dark
													? .white
													: (selectedTab == name ? .white : .black)
											)
											.clipShape(RoundedRectangle(cornerRadius: 32))
											.symbolEffect(.bounce, value: selectedTab == name)
											.bold(selectedTab == name)
										}
										.modifier(BackgroundShadowModifier())
										.sensoryFeedback(.success, trigger: selectedTab)
										.padding(.leading, i == 0 ? 10 : 0)
										//								.padding(.trailing, i == tagName.count - 1 ? 10 : 0)
									}

									Button {
										showingEditTagsSheet.toggle()
									} label: {
										Label("Edit", systemImage: "pencil")
											.padding(.vertical, 8)
											.padding(.horizontal, 8)
											.background(Color.accentColor.opacity(0.15))
											.foregroundStyle(colorScheme == .dark ? .white : .black)
											.clipShape(RoundedRectangle(cornerRadius: 10))
											.symbolEffect(.bounce, value: showingEditTagsSheet)
									}
									.sensoryFeedback(.success, trigger: showingEditTagsSheet)
									.padding(.trailing, 10)
									.sheet(isPresented: $showingEditTagsSheet) {
										NavigationStack {
											List {
												Section {
													ForEach(
														Array(zip(tagName.indices, tagName)),
														id: \.0
													) { i, name in
														Label(tagName[i], systemImage: tagIcon[i])
															.swipeActions(edge: .trailing) {
																Button(role: .destructive) {
																} label: {
																	Label(
																		"Delete",
																		systemImage: "trash")
																}
															}
													}
													.onDelete(perform: deleteTag)
													.onMove(perform: moveTag)
												}
												.listRowBackground(Color.clear)
												.listRowSeparator(.hidden)

												Section {
													Button(role: .destructive) {
														tagName = [
															"Top Stories", "New Stories",
															"Best Stories", "Ask HN", "Show HN",
															"Jobs",
														]
														tagIcon = [
															"arrowshape.up", "newspaper", "trophy",
															"questionmark.app", "eye", "briefcase",
														]
													} label: {
														Text("Reset Tags")
													}
													.disabled(
														tagName == [
															"Top Stories", "New Stories",
															"Best Stories", "Ask HN", "Show HN",
															"Jobs",
														])
												}
												//											.listRowBackground(Color.clear)
												//											.listRowSeparator(.hidden)
											}
											.navigationTitle("Edit Tags")
											.toolbar {
												ToolbarItem(placement: .topBarLeading) {
													EditButton()
												}

												ToolbarItem(placement: .topBarTrailing) {
													Button {
														showingEditTagsSheet.toggle()
													} label: {
														Image(systemName: "xmark.circle.fill")
															.foregroundStyle(.secondary)
															.bold()
													}
													.buttonStyle(.plain)
												}
											}
										}
										.interactiveDismissDisabled()
										.presentationBackground(.regularMaterial)
										.presentationCornerRadius(32)
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
						//					.listRowInsets(EdgeInsets())
						//					.listRowSpacing(0)
						//					.listRowSeparator(.hidden)
					}

				}
				.textCase(nil)
				.listRowInsets(EdgeInsets())
				.onAppear {
					withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
						showingTopButtons = false
					}
				}
				.onDisappear {
					withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
						showingTopButtons = true
					}
				}

				if autoRefreshAlert {
					HStack {
						Image(systemName: "newspaper")
							.bold()

						Text("Checking for new stories...")
							.bold()
					}
				}

				if !monitor.isConnected && showOfflineMessage {
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

				if viewModel.isError {
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
					ForEach(Array(zip(viewModel.stories.indices, viewModel.stories)), id: \.0) {
						i, story in
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
						.disabled(!monitor.isConnected)
						.contextMenu {
							Section {
								NavigationLink {
									if #available(iOS 18.0, *) {
										StoryDetailView(story: story)
											.navigationTransition(
												.zoom(sourceID: story, in: namespace))
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
											.navigationTransition(
												.zoom(sourceID: story, in: namespace))
									} else {
										UserView(id: story.by)
									}
								} label: {
									Label("View Profile", systemImage: "person")
								}
							}

							Section {
								Button {
								} label: {
									Label("Upvote", systemImage: "arrowshape.up")
								}
							}

							Section {
								Button {
								} label: {
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
								Button(role: .destructive) {
								} label: {
									Label("Block Topic", systemImage: "minus.circle")
								}

								Button(role: .destructive) {
								} label: {
									Label("Block Poster", systemImage: "hand.raised")
								}
							}
						}
						.onAppear {
							// Stories are loaded all at once with concurrent fetching
						}
					}
					.listRowInsets(EdgeInsets())

					if viewModel.isLoaded && viewModel.stories.isEmpty {
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
					if !viewModel.isLoaded && !viewModel.isError {
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
			.contentMargins(0)
			.refreshable {
				self.currentTime = Date()

				Task {
					await refreshData()
				}
			}
			.toolbar {
				//				if showingTopButtons {
				//					ToolbarItem(placement: .topBarLeading) {
				//						Button {
				//							showingSearchSheet.toggle()
				//						} label: {
				//							Label("Search", systemImage: "magnifyingglass")
				//						}
				//					}
				//				}

				ToolbarItem(placement: .topBarLeading) {
					Button {
						showSignInRequiredSheet = true
						//                        SubmitPostView()
					} label: {
						Label("Submit Post", systemImage: "plus")
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					NavigationLink {
						LoginView()
					} label: {
						Label("Profile", systemImage: "person")
					}
				}

				//				if showingTopButtons {
				//					ToolbarItem(placement: .topBarTrailing) {
				//						NavigationLink {
				//							SettingsView()
				//						} label: {
				//							Label("Settings", systemImage: "gearshape")
				//						}
				//					}
				//				}
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

							OnboardingItem(
								title: "What you read is off the record.",
								description: "We don't collect any data from you.",
								icon: "newspaper", color: .red)
							OnboardingItem(
								title: "Throw trackers off your trail.",
								description: "Read articles without ads or trackers.",
								icon: "hand.raised.fill", color: .pink)
							OnboardingItem(
								title: "AI with privacy in mind.",
								description: "Your data is anonymized and isn't used for training.",
								icon: "brain.fill", color: .orange)
							OnboardingItem(
								title: "Free & open-source.",
								description: "Welcome to the community!", icon: "hand.wave.fill",
								color: .green)
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
			.navigationTitle(monitor.isConnected ? selectedTab : "Offline")
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

							selectedTabURL =
								switch selectedTab {
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
								viewModel.isError = true
								fatalError("[ERROR] selectedTab doesn't work")
							}

							selectedTabURL =
								switch selectedTab {
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
				}, including: .gesture
		)
	}
}

#Preview {
	TopStoriesView()
}
