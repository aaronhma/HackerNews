//
//  SettingsView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

struct SettingsBoxView: View {
    var icon: String
    var color: Color
    
    var body: some View {
        Image(systemName: icon)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct SettingsView: View {
    @State private var iCloudSync = false
    @State private var suggestedForYou = true
    @State private var sharedWithYou = false
    
    @State private var openedNetwork = true
    @State private var openedNetworkOptions = true
    @State private var openedDataUsage = true
    @State private var clearCache = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cloud Sync") {
                    Toggle("Enable iCloud Sync", isOn: $iCloudSync)
                }
                
                Section("Display & Appearance") {
                    NavigationLink {
                        List {
                        }
                        .navigationTitle("Text & Font")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Font & Text", systemImage: "textformat.size")
                    }
                    
                    NavigationLink {
                        List {
                            Section("Left to Right") {
                                Label("Save Story", systemImage: "bookmark")
                                Label("Upvote Story", systemImage: "arrowshape.up")
                                Label("Share Story", systemImage: "square.and.arrow.up")
                            }
                            
                            Section("Right to Left") {
                                Label("Save Story", systemImage: "bookmark")
                                Label("Upvote Story", systemImage: "arrowshape.up")
                                Label("Share Story", systemImage: "square.and.arrow.up")
                            }
                        }
                        .navigationTitle("Swipe Actions")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Swipe Actions", systemImage: "hand.tap")
                    }
                    
                    NavigationLink {
                        List {
                        }
                        .navigationTitle("Accessibility")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Accessibility", systemImage: "questionmark.circle")
                    }
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
                        Label("Blocked Topics", systemImage: "minus.circle")
                    }
                    
                    NavigationLink {} label: {
                        Label("Blocked Users", systemImage: "hand.raised")
                    }
                }
                
                Section("Network & Data Usage") {
                    NavigationLink {
                        NavigationStack {
                            ScrollView {
                                VStack {
                                    GroupBox {
                                        if openedNetwork {
                                            Divider()
                                            
                                            VStack(alignment: .leading) {
                                                Toggle("Show Website Image Previews", isOn: .constant(true))
                                                    .bold()
                                                Text("Images will not display on section fronts to reduce data usage.")
                                                    .padding(.top, 5)
                                                    .foregroundStyle(.secondary)
                                                Divider()
                                                Toggle("Automatic Refresh", isOn: .constant(true))
                                                    .bold()
                                                Text("Content will not update automatically to reduce data usage.")
                                                    .padding(.top, 5)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(.top)
                                        }
                                    } label: {
                                        HStack {
                                            Label("Network", systemImage: "network")
                                            
                                            Spacer()
                                            
                                            Button {
                                                withAnimation {
                                                    openedNetwork.toggle()
                                                }
                                            } label: {
                                                Image(systemName: openedNetwork ? "chevron.down" : "chevron.right")
                                                    .tint(.secondary)
                                            }
                                            .symbolEffect(.bounce, value: openedNetwork)
                                        }
                                    }
                                    
                                    GroupBox {
                                        if openedNetworkOptions {
                                            Divider()
                                            
                                            VStack(alignment: .leading) {
                                                Toggle("Allow Cellular Access", isOn: .constant(true))
                                                    .bold()
                                                Text("Content will not update automatically on **Cellular**.")
                                                    .padding(.top, 5)
                                                    .foregroundStyle(.secondary)
                                                Divider()
                                                Toggle("Allow Low Data Mode Access", isOn: .constant(true))
                                                    .bold()
                                                Text("Content will not update automatically on **Low Data Mode**.")
                                                    .padding(.top, 5)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(.top)
                                        }
                                    } label: {
                                        HStack {
                                            Label("Network Options", systemImage: "list.star")
                                            
                                            Spacer()
                                            
                                            Button {
                                                withAnimation {
                                                    openedNetworkOptions.toggle()
                                                }
                                            } label: {
                                                Image(systemName: openedNetworkOptions ? "chevron.down" : "chevron.right")
                                                    .tint(.secondary)
                                            }
                                            .symbolEffect(.bounce, value: openedNetworkOptions)
                                        }
                                    }
                                    
                                    GroupBox {
                                        if openedDataUsage {
                                            Divider()
                                            
                                            VStack(alignment: .leading) {
                                                Toggle("Automatically Download Stories", isOn: .constant(true))
                                                    .bold()
                                                Text("Stories will automatically download for offline reading.")
                                                    .padding(.top, 5)
                                                    .foregroundStyle(.secondary)
                                                Divider()
                                                Button {
                                                    clearCache = true
                                                } label: {
                                                    HStack {
                                                        Spacer()
                                                        Label("Clear Cache", systemImage: "trash")
                                                            .foregroundStyle(.white)
                                                            .bold()
                                                        Spacer()
                                                    }
                                                    .padding(.vertical, 8)
                                                    .background(.red)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                }
                                                .confirmationDialog("All downloaded stories will be removed on the next app launch.", isPresented: $clearCache, titleVisibility: .visible) {
                                                    Button("Clear Cache", role: .destructive) {
                                                        URLCache.shared.removeAllCachedResponses()
                                                    }
                                                }
                                                .padding(.top)
                                                Text("All downloaded stories & content will be removed.")
                                                    .padding(.top, 5)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(.top)
                                        }
                                    } label: {
                                        HStack {
                                            Label("Data Usage", systemImage: "internaldrive")
                                            
                                            Spacer()
                                            
                                            Button {
                                                withAnimation {
                                                    openedDataUsage.toggle()
                                                }
                                            } label: {
                                                Image(systemName: openedDataUsage ? "chevron.down" : "chevron.right")
                                                    .tint(.secondary)
                                            }
                                            .symbolEffect(.bounce, value: openedDataUsage)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .navigationTitle("Network & Data Usage")
                        }
                    } label: {
                        Label("Network & Data Usage", systemImage: "network")
                    }
                }
                
                Section("Hacker News v0.0.0-development") {
                    NavigationLink {
                        Image(uiImage: Bundle.main.icon ?? UIImage())
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .accentColor, radius: 5)
                        
                        Text("bark for Hacker News")
                            .bold()
                            .font(.largeTitle)
                        
                        Text("Made with 💖 & 😀 by Aaron Ma.")
                        
                        NavigationLink {
                            List {
                                Section("API") {
                                    NavigationLink {
                                        ScrollView {
                                            Text("""
    The MIT License (MIT)
    
    Copyright (c) 2024 Y Combinator Hacker News
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    """)
                                            .navigationTitle("Hacker News")
                                        }
                                    } label: {
                                        Text("Hacker News")
                                    }
                                }
                                
                                Section("HTML Parser") {
                                    NavigationLink {
                                        ScrollView {
                                            Text("""
    MIT License
    
    Copyright (c) 2016 Nabil Chatbi
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    """)
                                            .navigationTitle("SwiftSoup")
                                        }
                                    } label: {
                                        Text("SwiftSoup")
                                    }
                                }
                            }
                            .navigationTitle("Acknowledgements")
                        } label: {
                            Text("Acknowledgements")
                        }
                    } label: {
                        Label("About This App", systemImage: "info.circle")
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
