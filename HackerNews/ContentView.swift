//
//  ContentView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import TipKit

struct ContentView: View {
	@AppStorage("showOnboarding") private var showOnboarding = AppSettings.showOnboarding
	
	var body: some View {
		TopStoriesView()
			.fullScreenCover(isPresented: $showOnboarding) {
				Onboarding(showOnboarding: $showOnboarding)
			}
			.task {
				//            try? Tips.resetDatastore()
				try? Tips.configure([
					.displayFrequency(.immediate),
					.datastoreLocation(.applicationDefault),
				])
			}
	}
}

#Preview {
	ContentView()
}
