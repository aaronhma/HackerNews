//
//  View+rect.swift
//  HackerNews
//
//  Created by Aaron Ma on 5/26/25.
//

import SwiftUI

extension View {
	@ViewBuilder
	func rect(completion: @escaping (CGRect) -> ()) -> some View {
		self
			.overlay {
				GeometryReader {
					let rect = $0.frame(in: .scrollView(axis: .horizontal))
					
					Color.clear
						.preference(key: RectKey.self, value: rect)
						.onPreferenceChange(RectKey.self, perform: completion)
				}
			}
	}
}
