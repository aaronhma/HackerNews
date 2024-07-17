//
//  BrowsingView.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/10/24.
//

import SwiftUI

struct BrowsingView: View {
    @AppStorage("browserPreferenceInApp") private var browserPreferenceInApp = AppSettings.browserPreferenceInApp
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        browserPreferenceInApp = true
                    } label: {
                        HStack {
                            Label("Built-in Internal Bark Browser", systemImage: "wand.and.sparkles")
                            
                            if browserPreferenceInApp {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Button {
                        browserPreferenceInApp = false
                    } label: {
                        HStack {
                            Label("Use External Browser", systemImage: "safari")
                            
                            if !browserPreferenceInApp {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("Link Behavior")
                } footer: {
                    if browserPreferenceInApp {
                        Text("You're getting the best reading experience possible! :)")
                    } else {
                        Text("Bark's AI features like Pinch to Summarize and ad blocking aren't available on external browsers.")
                    }
                }
                
                if browserPreferenceInApp {
                    Section("Privacy") {
                        Toggle(isOn: .constant(true)) {
                            Label("Block Known Ad Networks", systemImage: "x.square")
                        }
                        Toggle(isOn: .constant(true)) {
                            Label("Block Known Trackers", systemImage: "lock.shield")
                        }
                    }
                    
                    Section("Appearance") {
                        Toggle(isOn: .constant(true)) {
                            Label("Force Dark Mode", systemImage: "circle.lefthalf.filled")
                        }
                        
                        Toggle(isOn: .constant(true)) {
                            Label("Use Reader Mode", systemImage: "book.pages")
                        }
                    }
                }
            }
            .navigationTitle("Browsing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    BrowsingView()
}
