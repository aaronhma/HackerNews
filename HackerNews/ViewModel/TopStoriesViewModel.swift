//
//  TopStoriesViewModel.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/3/25.
//

import Foundation
import SwiftUI

extension TopStoriesView {
	@Observable
	class ViewModel {
		var stories = [Story]()
		var isError = false
		var isLoaded = false
		var isLoadingMore = false

		// Pagination state
		private var allStoryIds: [Int] = []
		private var currentOffset = 0
		private let batchSize = 20  // Load 20 at a time for smoother experience

		// Caching
		private var storyCache: [Int: Story] = [:]
		private var lastFetchTime: Date?
		private let cacheTimeout: TimeInterval = 300  // 5 minutes

		// Debouncing
		private var loadMoreTask: Task<Void, Never>?
		private var isLoadingInProgress = false

		func fetchStories(from urlString: String, limit: Int = 20) async throws {
			isError = false
			isLoaded = false
			stories = []
			currentOffset = 0
			allStoryIds = []

			let url = URL(string: urlString)!
			let (data, _) = try await URLSession.shared.data(from: url)
			let ids = try JSONDecoder().decode([Int].self, from: data)

			allStoryIds = ids
			lastFetchTime = Date()

			// Load first batch
			stories = try await loadBatch(from: 0, limit: limit)

			isLoaded = true
			currentOffset = limit
		}

		func loadMore() async {
			// Prevent multiple simultaneous loads
			guard !isLoadingInProgress else { return }
			guard !isLoadingMore else { return }
			guard !isError else { return }
			guard currentOffset < allStoryIds.count else { return }

			isLoadingInProgress = true

			// Cancel any pending load
			loadMoreTask?.cancel()

			// Debounce: create new task
			loadMoreTask = Task {
				// Add delay for debouncing
				try? await Task.sleep(nanoseconds: 500_000_000)  // 500ms
				guard !Task.isCancelled else {
					isLoadingInProgress = false
					return
				}

				isLoadingMore = true

				do {
					let newStories = try await loadBatch(from: currentOffset, limit: batchSize)

					guard !Task.isCancelled else {
						isLoadingMore = false
						isLoadingInProgress = false
						return
					}

					// Append to existing stories with animation
					await MainActor.run {
						withAnimation(.easeInOut(duration: 0.3)) {
							stories.append(contentsOf: newStories)
							currentOffset += batchSize
						}
						isLoadingMore = false
						isLoadingInProgress = false
					}
				} catch {
					guard !Task.isCancelled else {
						isLoadingMore = false
						isLoadingInProgress = false
						return
					}
					isError = true
					isLoadingMore = false
					isLoadingInProgress = false
				}
			}

			await loadMoreTask?.value
		}

		private func loadBatch(from offset: Int, limit: Int) async throws -> [Story] {
			let endIndex = min(offset + limit, allStoryIds.count)
			let idsToFetch = Array(allStoryIds[offset..<endIndex])

			// Check cache validity
			let isCacheValid = lastFetchTime.map { Date().timeIntervalSince($0) < cacheTimeout } ?? false

			return try await withThrowingTaskGroup(of: Story?.self) { group in
				for id in idsToFetch {
					group.addTask {
						// Return cached story if available and cache is valid
						if isCacheValid, let cachedStory = self.storyCache[id] {
							return cachedStory
						}

						// Fetch from network
						do {
							let story = try await self.fetchStory(withID: id)
							self.storyCache[id] = story
							return story
						} catch {
							// Skip failed stories instead of failing entire batch
							return nil
						}
					}
				}

				var fetchedStories = [Story]()
				for try await story in group {
					if let story = story {
						fetchedStories.append(story)
					}
				}
				return fetchedStories
			}
		}

		private func fetchStory(withID id: Int) async throws -> Story {
			let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
			let (data, _) = try await URLSession.shared.data(from: url)
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .secondsSince1970
			var story = try decoder.decode(Story.self, from: data)

			if story.url == nil {
				story.url = "https://news.ycombinator.com/item?id=\(story.id)"
			}

			return story
		}

		func clearCache() {
			storyCache.removeAll()
			lastFetchTime = nil
		}

		var hasMore: Bool {
			currentOffset < allStoryIds.count
		}
	}
}
