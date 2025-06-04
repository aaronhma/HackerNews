//
//  StoriesTab.swift
//  HackerNews
//
//  Created by Aaron Ma on 5/26/25.
//

import SwiftUI

struct StoriesTab: Identifiable {
	private(set) var id: Tab
	var size = CGSize.zero
	var minX = CGFloat.zero
	
	enum Tab: String, CaseIterable {
		case topStories = "Top Stories"
		case newStories = "New Stories"
		case bestStories = "Best Stories"
		case askHN = "Ask HN"
		case showHN = "Show HN"
		case jobs = "Jobs"
	}
	
	var icon: String {
		switch self.id {
		case .topStories:
			"arrowshape.up"
		case .newStories:
			"newspaper"
		case .bestStories:
			"trophy"
		case .askHN:
			"questionmark.app"
		case .showHN:
			"eye"
		case .jobs:
			"briefcase"
		}
	}
	
	var url: String {
		switch self.id {
		case .topStories:
			"https://hacker-news.firebaseio.com/v0/topstories.json"
		case .newStories:
			"https://hacker-news.firebaseio.com/v0/newstories.json"
		case .bestStories:
			"https://hacker-news.firebaseio.com/v0/beststories.json"
		case .askHN:
			"https://hacker-news.firebaseio.com/v0/askstories.json"
		case .showHN:
			"https://hacker-news.firebaseio.com/v0/showstories.json"
		case .jobs:
			"https://hacker-news.firebaseio.com/v0/jobstories.json"
		}
	}
}

extension StoriesTab {
	static var tabs: [StoriesTab] = [.init(id: .topStories), .init(id: .newStories), .init(id: .bestStories), .init(id: .askHN), .init(id: .showHN), .init(id: .jobs)]
}
