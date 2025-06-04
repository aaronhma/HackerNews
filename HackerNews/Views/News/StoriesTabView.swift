//
//  StoriesTabView.swift
//  HackerNews
//
//  Created by Aaron Ma on 5/26/25.
//

import SwiftUI

struct StoriesTabView: View {
	@State private var tabs = StoriesTab.tabs
	
	@State private var activeTab = StoriesTab.Tab.topStories
	
	@State private var tabBarScrollState: StoriesTab.Tab?
	@State private var mainViewScrollState: StoriesTab.Tab?
	
	@State private var progress = CGFloat.zero
	
    var body: some View {
		ScrollView(.horizontal) {
			HStack(spacing: 20) {
				ForEach($tabs) { $tab in
					Button {
						withAnimation(.snappy) {
							activeTab = tab.id
							mainViewScrollState = tab.id
							tabBarScrollState = tab.id
						}
					} label: {
						Label(tab.id.rawValue, systemImage: tab.icon)
							.padding(.vertical, 12)
							.foregroundStyle(activeTab == tab.id ? Color.primary : .gray)
							.contentShape(.rect)
							.symbolEffect(.bounce, value: activeTab == tab.id)
					}
					.sensoryFeedback(.selection, trigger: activeTab)
					.buttonStyle(.plain)
					.rect { rect in
						tab.size = rect.size
						tab.minX = rect.minX
					}
				}
			}
			.scrollTargetLayout()
		}
		.scrollPosition(id: .init(get: {
			return tabBarScrollState
		}, set: { _ in
			
		}), anchor: .center)
		.overlay(alignment: .bottom) {
			ZStack(alignment: .leading) {
				Rectangle()
					.fill(.gray.opacity(0.3))
					.frame(height: 1)
				
				let inputRange = tabs.indices.compactMap { return CGFloat($0) }
				let outputRange = tabs.compactMap { return $0.size.width }
				let outputPositionRange = tabs.compactMap { return $0.minX }
				let indicatorWidth = progress.interpolate(inputRange: inputRange, outputRange: outputRange)
				let indicatorPosition = progress.interpolate(inputRange: inputRange, outputRange: outputPositionRange)
				
				Rectangle()
					.fill(.primary)
					.frame(width: indicatorWidth, height: 1.5)
					.offset(x: indicatorPosition)
			}
		}
		.safeAreaPadding(.horizontal, 15)
		.scrollIndicators(.hidden)
		
		GeometryReader {
			let size = $0.size
			
			ScrollView(.horizontal) {
				LazyHStack(spacing: 0) {
					ForEach(tabs) { tab in
						Text(tab.id.rawValue)
							.frame(width: size.width, height: size.height)
							.contentShape(.rect)
					}
				}
				.scrollTargetLayout()
				.rect { rect in
					progress = -rect.minX / size.width
				}
			}
			.scrollPosition(id: $mainViewScrollState)
			.scrollIndicators(.hidden)
			.scrollTargetBehavior(.paging)
			.onChange(of: mainViewScrollState) { oldValue, newValue in
				if let newValue {
					withAnimation(.snappy) {
						tabBarScrollState = newValue
						activeTab = newValue
					}
				}
			}
		}
    }
}

#Preview {
    StoriesTabView()
}
