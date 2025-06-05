//
//  NoInternetView.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/4/25.
//

import SwiftUI

struct NoInternetView: View {
	var body: some View {
		VStack(spacing: 20) {
			ContentUnavailableView {
				Label {
					Text("No Internet Connectivity")
						.font(.title3)
						.fontWeight(.semibold)
				} icon: {
					Image(systemName: "wifi.exclamationmark")
						.font(.system(size: 150, weight: .semibold))
						.frame(height: 100)
				}
			}
			
			Text("Waiting for internet connection...")
				.font(.caption)
				.foregroundStyle(.background)
				.padding(.vertical, 12)
				.frame(maxWidth: .infinity)
				.background(Color.primary)
				.padding(.top, 10)
				.padding(.horizontal, -20)
		}
		.fontDesign(.rounded)
		.padding([.horizontal, .top], 20)
		.background(.background)
		.clipShape(.rect(cornerRadius: 20))
		.padding(.horizontal, 20)
		.padding(.bottom, 10)
		.frame(height: 310)
	}
}

#Preview {
    NoInternetView()
}
