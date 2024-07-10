//
//  ContentView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = Tab.TopStories
    
    @AppStorage("__ShowCopyright") private var __ShowCopyright = AppSettings.__ShowCopyright
    @AppStorage("showOnboarding") private var showOnboarding = AppSettings.showOnboarding
    
    enum Tab {
        case TopStories
        case Search
        case Settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TopStoriesView()
                .tag(Tab.TopStories)
                .tabItem {
                    Label("Hacker News", systemImage: "newspaper")
                }
            
            Search()
                .tag(Tab.Search)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            SettingsView()
                .tag(Tab.Settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .fullScreenCover(isPresented: $__ShowCopyright) {
            Onboarding(drm: $__ShowCopyright, showOnboarding: $showOnboarding)
        }
        .onAppear {
            __ShowCopyright = true
            print("show onboarding? \(showOnboarding)")
        }
    }
}

#Preview {
    ContentView()
}
