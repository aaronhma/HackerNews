//
//  SettingsView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI

struct SettingsBoxView: View {
    var icon: String
    var style: Color = .white
    var color: Color
    
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .padding()
            .background(color)
            .foregroundStyle(style)
            .frame(width: 30, height: 30)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct SettingsView: View {
    @State private var iCloudSync = false
    @State private var fontSize = 12
    @State private var suggestedForYou = true
    @State private var sharedWithYou = false
    
    @State private var openedNetwork = true
    @State private var openedNetworkOptions = false
    @State private var openedDataUsage = false
    @State private var clearCache = false
    
    var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0"
    }
    
    @AppStorage("__ShowCopyright") private var __ShowCopyright = AppSettings.__ShowCopyright
    @AppStorage("showOnboarding") private var showOnboarding = AppSettings.showOnboarding
    @AppStorage("browserPreferenceInApp") private var browserPreferenceInApp = AppSettings.browserPreferenceInApp
    
    var intProxy: Binding<Double>{
            Binding<Double>(get: {
                return Double(fontSize)
            }, set: {
                print($0.description)
                fontSize = Int($0)
            })
        }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $iCloudSync) {
                        Label {
                            Text("Enable iCloud Sync")
                        } icon: {
                            SettingsBoxView(icon: "icloud", color: .black.opacity(0.5))
                        }
                    }
                } header: {
                    Text("Cloud Sync")
                } footer: {
                    Text("iCloud Sync isn't available on this device.")
                }
                
                Section {
                    NavigationLink {
                        List {
                            Section("Text Size") {
                                VStack {
                                    Slider(value: intProxy, in: 4...100, step: 1.0)
                                    Text("Font size: \(fontSize)")
                                }
                            }
                            
                            Section("Font") {
                                Text("San Francisco (iOS System)")
                            }
                        }
                        .navigationTitle("Text Size & Font")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label {
                            Text("Text Size & Font")
                        } icon: {
                            SettingsBoxView(icon: "textformat.size", color: .teal)
                        }
                    }
                    
                    NavigationLink {
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
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    browserPreferenceInApp = false
                                } label: {
                                    HStack {
                                        Label("Use External Browser", systemImage: "safari")
                                        
                                        if !browserPreferenceInApp {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
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
                                    Toggle("Block Known Ad Networks", isOn: .constant(true))
                                    Toggle("Block Known Trackers", isOn: .constant(true))
                                }
                                
                                Section("Appearance") {
                                    Toggle("Force Dark Mode", isOn: .constant(true))
                                }
                            }
                            
                            Section {
                                Toggle("Show AI Summary Options", isOn: .constant(true))
                            } header: {
                                Text("AI Summary")
                            } footer: {
                                Text("You need your own ChatGPT API key.")
                            }
                        }
                        .navigationTitle("Browsing")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label {
                            Text("Browsing")
                        } icon: {
                            SettingsBoxView(icon: "safari", color: .blue)
                        }
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
                        Label {
                            Text("Swipe Actions")
                        } icon: {
                            SettingsBoxView(icon: "hand.tap", color: .green)
                        }
                    }
                    
                    NavigationLink {
                        List {
                        }
                        .navigationTitle("Accessibility")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label {
                            Text("Accessibility")
                        } icon: {
                            SettingsBoxView(icon: "questionmark.circle", color: .pink)
                        }
                    }
                } header: {
                    Text("Display & Appearance")
                } footer: {
                    Text("Personalize your experience in ways that work best for you with vision accessibility, custom gestures, and the browsing experience.")
                }
                
                Section {
                    Toggle(isOn: $suggestedForYou) {
                        Label {
                            Text("Show Suggested Stories")
                        } icon: {
                            SettingsBoxView(icon: "medal.star", color: .orange)
                        }
                    }
                    Toggle(isOn: $sharedWithYou) {
                        Label {
                            Text("Shared with You")
                        } icon: {
                            SettingsBoxView(icon: "sharedwithyou", color: .purple)
                        }
                    }
                    
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label {
                            Text("History")
                        } icon: {
                            SettingsBoxView(icon: "clock.arrow.circlepath", color: .cyan)
                        }
                    }
                    
                    NavigationLink {} label: {
                        Label {
                            Text("Saved Stories")
                        } icon: {
                            SettingsBoxView(icon: "bookmark", color: .indigo)
                        }
                    }
                    
                    NavigationLink {} label: {
                        Label {
                            Text("Upvoted Stories")
                        } icon: {
                            SettingsBoxView(icon: "arrowshape.up", color: .mint)
                        }
                    }
                    
                    NavigationLink {} label: {
                        Label {
                            Text("Blocked Topics")
                        } icon: {
                            SettingsBoxView(icon: "minus.circle", color: .red)
                        }
                    }
                    
                    NavigationLink {} label: {
                        Label {
                            Text("Blocked Users")
                        } icon: {
                            SettingsBoxView(icon: "hand.raised", color: .red)
                        }
                    }
                } header: {
                    Text("Personalization")
                } footer: {
                    Text("Customize your personalized news feed and jump back into stories that interest you.")
                }
                
                Section {
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
                                    .sensoryFeedback(.impact, trigger: openedNetwork)
                                    
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
                                    .sensoryFeedback(.impact, trigger: openedNetworkOptions)
                                    
                                    GroupBox {
                                        if openedDataUsage {
                                            Divider()
                                            VStack {
                                                ProgressView(value: 100, total: 100)
                                                    .progressViewStyle(.linear)
                                                    .padding(.vertical)
                                                    .overlay {
                                                        Text("1GB/1GB allocated")
                                                            .bold()
                                                            .font(.system(size: 8))
                                                    }
                                            }
                                            
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
                                    .sensoryFeedback(.impact, trigger: openedDataUsage)
                                }
                                .padding(.horizontal)
                            }
                            .navigationTitle("Network & Data Usage")
                        }
                    } label: {
                        Label {
                            Text("Network & Data Usage")
                        } icon: {
                            SettingsBoxView(icon: "network", color: .blue)
                        }
                    }
                } header: {
                    Text("Network & Data Usage")
                } footer: {
                    Text("Find out how much data you're using, set data restrictions, and manage network settings.")
                }
                
                Section {
                    NavigationLink {
                        Image(uiImage: Bundle.main.icon ?? UIImage())
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .accentColor, radius: 5)
                        
                        Text("bark for Hacker News")
                            .bold()
                            .font(.largeTitle)
                        
                        Text("v\(appVersion)")
                            .foregroundStyle(.secondary)
                        
                        Text("Made with 💖 & 😀\nby **Aaron Ma**.")
                            .multilineTextAlignment(.center)
                        
                        Button {} label: {
                            HStack {
                                Spacer()
                                Label("Twitter", systemImage: "bird.fill")
                                    .bold()
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .background(.blue.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.blue, lineWidth: 2)
                            }
                        }
                        .padding(.horizontal)
                        
                        Text("With 🥰 from Cupertino, CA.")
                        
                        Button {
                            __ShowCopyright = true
                            showOnboarding = true
                        } label: {
                            Text("Show Onboarding")
                        }
                        
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
                        Label {
                            Text("About This App")
                        } icon: {
                            SettingsBoxView(icon: "info.circle", color: .blue.opacity(0.75))
                        }
                    }
                } header: {
                    Text("Hacker News v\(appVersion)")
                } footer: {
                    Text("Get the latest experimental features, manage app updates and generate system reports for debugging purposes.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
