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
                Section {
                    Text("Bark AI doesn't have a UI yet. These features will be available in a future release.")
                }
                
                Section {
                    Toggle(isOn: $useChatGPT.animation()) {
                        Label("Use ChatGPT", systemImage: "wand.and.sparkles")
                    }
                    
                    if useChatGPT {
                        TextField("Enter your OpenAI API key", text: $apiKey)
                    } else {
                        Text("Local LLM requires an iPhone 14 or later.")
                    }
                } header: {
                    Text(useChatGPT ? "OpenAI API Key" : "Local LLM")
                } footer: {
                    Text(useChatGPT ? "Visit the [OpenAI Platform](https://platform.openai.com/login) to generate an API key." : "FOOTER_CHANGED_V2")
                }
                
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
                
                Section {
                    Toggle(isOn: .constant(true)) {
                        Label("Stream Responses", systemImage: "figure.run")
                    }
                } header: {
                    Text("Bark AI Options")
                } footer: {
                    Text("Stream responses availability vary.")
                }
                
                if useChatGPT {
                    Section {
                        Button {} label: {
                            Text("GPT-3.5-Turbo")
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
            }
            .navigationTitle("Bark AI")
        }
    }
}

#Preview {
    BarkAIView()
}
