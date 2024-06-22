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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: StoryStorage.self)
                .onAppear {
                    URLCache.shared.removeAllCachedResponses()
                }
        }
    }
}
