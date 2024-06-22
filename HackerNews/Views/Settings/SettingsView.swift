//
//  SettingsView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var iCloudSync = false
    @State private var suggestedForYou = true
    @State private var sharedWithYou = false
    
    @State private var clearCache = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cloud Sync") {
                    Toggle("Enable iCloud Sync", isOn: $iCloudSync)
                }
                
                Section("Personalization") {
                    Toggle("Show Suggested Stories", isOn: $suggestedForYou)
                    Toggle("Shared with You", isOn: $sharedWithYou)
                    
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                    
                    NavigationLink {} label: {
                        Label("Saved Stories", systemImage: "bookmark")
                    }
                    
                    NavigationLink {} label: {
                        Label("Liked Stories", systemImage: "hand.thumbsup")
                    }
                    
                    NavigationLink {} label: {
                        Label("Disliked Stories", systemImage: "hand.thumbsdown")
                    }
                    
                    NavigationLink {} label: {
                        Label("Blocked Topics", systemImage: "minus.circle")
                    }
                    
                    NavigationLink {} label: {
                        Label("Blocked Users", systemImage: "hand.raised")
                    }
                }
                
                Section("Data Usage") {
                    Button(role: .destructive) {
                        clearCache = true
                    } label: {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                    .confirmationDialog("All downloaded stories will be removed on the next app launch.", isPresented: $clearCache, titleVisibility: .visible) {
                        Button("Clear Cache", role: .destructive) {
                            URLCache.shared.removeAllCachedResponses()
                        }
                    }
                }
                
                Section("Hacker News v0.0.0-development") {
                    NavigationLink {} label: {
                        Text("Made with 💖 & 😀 by Aaron Ma.")
                    }
                    
                    NavigationLink {} label: {
                        Text("Acknowledgements")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
