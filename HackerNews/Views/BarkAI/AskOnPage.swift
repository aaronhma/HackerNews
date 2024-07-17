//
//  AskOnPage.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/11/24.
//

import SwiftUI
import SwiftOpenAI

struct AskOnPage: View {
    @AppStorage("apiKey") private var apiKey = AppSettings.apiKey
    
    //    @State private var ai = SwiftOpenAI(apiKey: "")
    
    var body: some View {
        VStack {
            Image(systemName: "brain")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Ask AI Unavailable")
            Text("Local LLM requires an iPhone 14 or later")
        }
        .padding()
        //        .onAppear {
        //                    Task {
        //                        do {
        //                            let result = try await ai.createChatCompletions(model: .gpt(.turbo),
        //                                                                                messages: [.init(text: "Write a paragraph about my beautiful 1-year-old dog male Maltese in 100 words or less.", role: .user)])
        //                            print(result)
        //                        } catch {
        //                            print(error)
        //                        }
        //                    }
        //                }
    }
}

#Preview {
    AskOnPage()
}
