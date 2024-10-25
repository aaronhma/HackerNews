//
//  BarkAI.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/10/24.
//

import SwiftUI

struct BarkAIView: View {
	@AppStorage("apiKey") private var apiKey = AppSettings.apiKey
	
	@State private var useChatGPT = true
	
	var body: some View {
		NavigationStack {
			List {
				if useChatGPT {
					Section {
						Text("Manage your usage and view OpenAI's pricing [here](https://openai.com/api/pricing/).")
					}
				}
				
				Section {
					Toggle(isOn: $useChatGPT.animation()) {
						Label("Use ChatGPT", systemImage: "wand.and.sparkles")
					}
					
					if useChatGPT {
						TextField("Enter your OpenAI API key", text: $apiKey)
						
						NavigationLink {
							NavigationStack {
								List {
									Section {
										Toggle(isOn: .constant(true)) {
											Label("Stream Responses", systemImage: "figure.run")
										}
										.disabled(true)
									} header: {
										Text("Bark AI Options")
									} footer: {
										Text("Stream responses availability vary.")
									}
									
									Section {
										Button {} label: {
											Text("GPT-4o-mini")
										}
										
										Button {} label: {
											Text("GPT-4o")
										}
									} header: {
										Text("OpenAI Model")
									} footer: {
										Text("GPT-4o supports text and vision, while GPT-3.5-Turbo supports text only.")
									}
								}
								.navigationTitle("OpenAI Settings")
							}
						} label: {
							Label("OpenAI Settings", systemImage: "gear")
						}
					} else {
						Text("This **iPhone 16 Pro Max** running **iOS 18.2** with **8GB RAM** is compatible. Features may be unavailable until the download is complete.")
					}
				} header: {
					Text(useChatGPT ? "OpenAI API Key" : "Local LLM")
				} footer: {
					Text(useChatGPT ? "Visit the [OpenAI Platform](https://platform.openai.com/login) to generate an API key." : "FOOTER_CHANGED_V2")
				}
				
				NavigationLink {
					NavigationStack {
						List {
							Section {
								Toggle(isOn: .constant(true)) {
									Label("Pinch to Summarize", systemImage: "hand.pinch")
								}
							} header: {
								Text("Pinch To Summarize")
							} footer: {
								Text("Too long of a discussion or article? Just ask Bark AI!")
							}
							
							Section {
								Toggle(isOn: .constant(true)) {
									Label("Ask on Page", systemImage: "wand.and.sparkles")
								}
							} header: {
								Text("Ask on Page")
							} footer: {
								Text("Get in-depth answers with Bark AI.")
							}
						}
					}
					.navigationTitle("Available Features")
				} label: {
					Label("Available Features", systemImage: "gear")
				}
			}
			.navigationTitle("Bark AI")
		}
	}
}

#Preview {
	BarkAIView()
}
