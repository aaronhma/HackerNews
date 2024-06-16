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
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sync") {
                    Toggle("Enable iCloud Sync", isOn: $iCloudSync)
                }
                
                Section("Personalization") {
                    Toggle("Suggested For You", isOn: $suggestedForYou)
                    Toggle("Shared with You", isOn: $sharedWithYou)
                    
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Text("History")
                    }
                    
                    NavigationLink {} label: {
                        Text("Saved Stories")
                    }
                    
                    NavigationLink {} label: {
                        Text("Liked Stories")
                    }
                    
                    NavigationLink {} label: {
                        Text("Disliked Stories")
                    }
                    
                    NavigationLink {} label: {
                        Text("Blocked Topics")
                    }
                    
                    NavigationLink {} label: {
                        Text("Blocked Users")
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
