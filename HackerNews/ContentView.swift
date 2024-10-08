//
//  ContentView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import TipKit

struct ContentView: View {
    @State private var selectedTab = Tab.TopStories
    
    @AppStorage("showOnboarding") private var showOnboarding = AppSettings.showOnboarding
    
    enum Tab {
        case TopStories
        case Search
        case Profile
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
            
            LoginView()
                .tag(Tab.Profile)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            
            SettingsView()
                .tag(Tab.Settings)
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            Onboarding(showOnboarding: $showOnboarding)
        }
        .onAppear {
            print("show onboarding? \(showOnboarding)")
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
