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

		func fetchStories(from urlString: String, limit: Int = 30) async throws {
			isError = false
			isLoaded = false
			stories = []

			let url = URL(string: urlString)!
			let (data, _) = try await URLSession.shared.data(from: url)
			let ids = try JSONDecoder().decode([Int].self, from: data)

			stories = try await withThrowingTaskGroup(of: Story.self) { group in
				for id in ids.prefix(limit) {
					group.addTask { try await self.fetchStory(withID: id) }
				}
				var stories = [Story]()
				for try await item in group {
					stories.append(item)
				}
				return stories
			}

			isLoaded = true
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
	}
}
