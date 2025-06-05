//
//  HackerNewsApp.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import SwiftData

@main
struct HackerNewsApp: App {
	@StateObject private var networkMonitor = NetworkMonitor()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: StoryStorage.self)
				.onAppear {
					URLCache.shared.removeAllCachedResponses()
				}
				.sheet(isPresented: .constant(!(networkMonitor.isConnected ?? true))) {
					NoInternetView()
						.presentationDetents([.height(310)])
						.presentationCornerRadius(0)
						.presentationBackgroundInteraction(.disabled)
						.presentationBackground(.clear)
						.interactiveDismissDisabled()
				}

		}
	}
}
