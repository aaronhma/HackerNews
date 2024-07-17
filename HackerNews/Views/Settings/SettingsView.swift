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
    @State private var suggestedForYou = true
    @State private var sharedWithYou = false
    
    @State private var showSignOutDialog = false
    
    @Namespace() var namespace
    
    @AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
    @AppStorage("accountAuth") private var accountAuth = AppSettings.accountAuth
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        if !accountUserName.isEmpty && !accountAuth.isEmpty {
                            if #available(iOS 18.0, *) {
                                UserView(id: accountUserName)
                                    .navigationTransition(.zoom(sourceID: -1, in: namespace))
                            } else {
                                UserView(id: accountUserName)
                            }
                        } else {
                            if #available(iOS 18.0, *) {
                                LoginView()
                                    .navigationTransition(.zoom(sourceID: -1, in: namespace))
                            } else {
                                LoginView()
                            }
                        }
                    } label: {
                        if !accountUserName.isEmpty && !accountAuth.isEmpty {
                            HStack {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.orange)
                                
                                VStack(alignment: .leading) {
                                    Text(accountUserName)
                                        .lineLimit(1)
                                        .bold()
                                    
                                    Text("Manage your account")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading, 3)
                                
                                Spacer()
                            }
                        } else {
                            HStack {
                                Image(systemName: "y.square.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(.orange)
                                
                                VStack(alignment: .leading) {
                                    Text("Hacker News Account")
                                        .bold()
                                    
                                    Text("Sign in to access your profile, submit posts, upvote, and more.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading, 3)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    if !accountUserName.isEmpty && !accountAuth.isEmpty {
                        Button(role: .destructive) {
                            showSignOutDialog = true
                        } label: {
                            Text("Sign out")
                        }
                        .confirmationDialog("Are you sure you'd like to sign out? You won't be able to upvote or reply to comments.", isPresented: $showSignOutDialog, titleVisibility: .visible) {
                            Button("Sign out", role: .destructive) {
                                URLCache.shared.removeAllCachedResponses()
                                accountUserName = ""
                                accountAuth = ""
                            }
                        }
                    }
                } header: {
                    Text("Account")
                } footer: {
                    if !accountUserName.isEmpty && !accountAuth.isEmpty {
                        Text("Authentication token: \(accountAuth)")
                    } else {
                        Text("One account for everything YC.")
                    }
                }
                .onAppear {
                    print("Authentication token: \(accountAuth)")
                }
                
                Section {
                    Toggle(isOn: $iCloudSync) {
                        Label {
                            Text("Enable iCloud Sync")
                        } icon: {
                            SettingsBoxView(icon: "icloud", color: .black.opacity(0.5))
                        }
                    }
                    .disabled(true)
                } header: {
                    Text("Cloud Sync")
                } footer: {
                    Text("iCloud Sync isn't available on this device.")
                }
                
                Section {
                    NavigationLink {
                        if #available(iOS 18.0, *) {
                            TextSizeView()
                                .navigationTransition(.zoom(sourceID: 0, in: namespace))
                        } else {
                            TextSizeView()
                        }
                    } label: {
                        Label {
                            Text("Text Size & Font")
                        } icon: {
                            SettingsBoxView(icon: "textformat.size", color: .teal)
                        }
                    }
                    
                    NavigationLink {
                        if #available(iOS 18.0, *) {
                            BarkAIView()
                                .navigationTransition(.zoom(sourceID: 1, in: namespace))
                        } else {
                            BarkAIView()
                        }
                    } label: {
                        Label {
                            Text("Bark AI")
                        } icon: {
                            SettingsBoxView(icon: "brain", color: .brown)
                        }
                    }
                    
                    NavigationLink {
                        if #available(iOS 18.0, *) {
                            BrowsingView()
                                .navigationTransition(.zoom(sourceID: 2, in: namespace))
                        } else {
                            BrowsingView()
                        }
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
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                Spacer()
                            }
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
                        if #available(iOS 18.0, *) {
                            HistoryView()
                                .navigationTransition(.zoom(sourceID: 0, in: namespace))
                        } else {
                            HistoryView()
                        }
                    } label: {
                        Label {
                            Text("History")
                        } icon: {
                            SettingsBoxView(icon: "clock.arrow.circlepath", color: .cyan)
                        }
                    }
                    
                    NavigationLink {
                        List {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                Spacer()
                            }
                        }
                    } label: {
                        Label {
                            Text("Saved Stories")
                        } icon: {
                            SettingsBoxView(icon: "bookmark", color: .indigo)
                        }
                    }
                    
                    NavigationLink {
                        List {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                Spacer()
                            }
                        }
                    } label: {
                        Label {
                            Text("Upvoted Stories")
                        } icon: {
                            SettingsBoxView(icon: "arrowshape.up", color: .mint)
                        }
                    }
                    
                    NavigationLink {
                        List {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                Spacer()
                            }
                        }
                    } label: {
                        Label {
                            Text("Blocked Topics")
                        } icon: {
                            SettingsBoxView(icon: "minus.circle", color: .red)
                        }
                    }
                    
                    NavigationLink {
                        List {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.extraLarge)
                                Spacer()
                            }
                        }
                    } label: {
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
                        if #available(iOS 18.0, *) {
                            NetworkView()
                                .navigationTransition(.zoom(sourceID: 420, in: namespace))
                        } else {
                            NetworkView()
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
                        if #available(iOS 18.0, *) {
                            AboutView()
                                .navigationTransition(.zoom(sourceID: 69, in: namespace))
                        } else {
                            AboutView()
                        }
                    } label: {
                        Label {
                            Text("About This App")
                        } icon: {
                            SettingsBoxView(icon: "info.circle", color: .blue.opacity(0.75))
                        }
                    }
                } header: {
                    Text("bark for Hacker News")
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
