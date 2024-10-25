//
//  AskOnPage.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/11/24.
//

import SwiftUI
import SwiftOpenAI

//struct AskOnPage: View {
//	@AppStorage("apiKey") private var apiKey = AppSettings.apiKey
//	
//	@State private var ai = SwiftOpenAI(apiKey: "")
//	
//	var body: some View {
//		VStack {
//			Image(systemName: "brain")
//				.imageScale(.large)
//				.foregroundStyle(Color.accentColor)
//			Text("Ask AI Unavailable")
//			Text("Local LLM requires an iPhone 14 or later")
//		}
//		.padding()
//		.onAppear {
//			Task {
//				do {
//					let result = try await ai.createChatCompletions(model: .gpt4o(.gpt_4o_2024_05_13),
//																	messages: [.init(text: "Write a paragraph about my beautiful 1-year-old dog male Maltese in 100 words or less.", role: .user)])
//					print(result)
//				} catch {
//					print(error)
//				}
//			}
//		}
//	}
//}

struct AskOnPage: View {
  @State var isFullScreenCoverPresented = false
  @State var isFullScreenViewVisible = false

  var body: some View {
	VStack {
	  Button("Show Full-Screen Modal") {
		isFullScreenCoverPresented = true
	  }
	}.fullScreenCover(isPresented: $isFullScreenCoverPresented) {
	  Group {
		if isFullScreenViewVisible {
			VStack {
			  Button("Dismiss") {
				  isFullScreenViewVisible = false
			  }
			  .frame(maxWidth: .infinity, maxHeight: .infinity)
			  .background(.yellow)
			}
			.onDisappear {
			  isFullScreenCoverPresented = false
			}
		}
	  }
	  .onAppear {
		isFullScreenViewVisible = true
	  }
	}
	.transaction({ transaction in
		transaction.disablesAnimations = true
		transaction.animation = .spring(duration: 0.5)
	})
  }
}

#Preview {
	AskOnPage()
}
