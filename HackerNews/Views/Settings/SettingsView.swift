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
	var width: CGFloat = 20
	var height: CGFloat = 20
	
	var body: some View {
		Image(systemName: icon)
			.resizable()
			.scaledToFit()
			.frame(width: width, height: height)
			.padding()
			.background(color)
			.foregroundStyle(style)
			.frame(width: width + 10, height: height + 10)
			.clipShape(RoundedRectangle(cornerRadius: 8))
	}
}

struct SettingsView: View {
	@State private var showSignOutDialog = false
	
	@Namespace() var namespace
	
	@AppStorage("accountUserName") private var accountUserName = AppSettings.accountUserName
	@AppStorage("accountAuth") private var accountAuth = AppSettings.accountAuth
	
	var body: some View {
		NavigationStack {
			List {
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
							Section {
								VStack {
									SettingsBoxView(icon: "questionmark.circle", color: .pink, width: 50, height: 50)
									
									Text("Accessibility")
										.font(.title)
										.bold()
									
									Text("Personalize your experience in ways that work best for you with vision accessibility, custom gestures, and the browsing experience.")
										.foregroundStyle(.secondary)
										.multilineTextAlignment(.center)
								}
							}
							
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
				}
				
				Section {
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
							Text("Saved & Upvoted Stories")
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
							Text("Blocked Topics, Websites & Users")
						} icon: {
							SettingsBoxView(icon: "hand.raised", color: .red)
						}
					}
				} header: {
					Text("Personalization")
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
				}
			}
			.navigationTitle("Settings")
		}
	}
}

#Preview {
	SettingsView()
}
