//
//  RectKey.swift
//  HackerNews
//
//  Created by Aaron Ma on 5/26/25.
//

import SwiftUI

struct RectKey: PreferenceKey {
	static var defaultValue = CGRect.zero
	
	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}
