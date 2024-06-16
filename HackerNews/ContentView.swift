//
//  ContentView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TopStoriesView()
                .tabItem {
                    Label("Hacker News", systemImage: "newspaper")
                }
            
            Text("Search for a user...")
                .tabItem {
                    Label("User Search", systemImage: "person")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
}
