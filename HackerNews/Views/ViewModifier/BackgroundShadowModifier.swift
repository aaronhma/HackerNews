//
//  BackgroundShadowModifier.swift
//  HackerNews
//
//  Created by Aaron Ma on 11/22/24.
//

import SwiftUI

struct BackgroundShadowModifier: ViewModifier {
	@State private var isPressed = false

	func body(content: Content) -> some View {
		content
			.overlay(
				Rectangle()
					.fill(Color.black.opacity(0.2))
					.blur(radius: 15)
					.offset(x: 0, y: 1)
					.mask(content)
					.opacity(isPressed ? 1 : 0)
			)
			.scaleEffect(isPressed ? 0.92 : 1)
			.sensoryFeedback(.impact, trigger: isPressed)
			.animation(.easeInOut(duration: 0.1), value: isPressed)
			.simultaneousGesture(
				DragGesture(minimumDistance: 0)
				.onChanged { _ in
					isPressed = true
				}
				.onEnded { _ in
					isPressed = false
				}
			)
	}
}
