//
//  CGFloat+interpolate.swift
//  HackerNews
//
//  Created by Aaron Ma on 5/26/25.
//

import SwiftUI

extension CGFloat {
	func interpolate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
		let x = self
		let length = inputRange.count - 1
		
		if x <= inputRange[0] {
			return outputRange[0]
		}
		
		for i in 1...length {
			let x1 = inputRange[i - 1]
			let x2 = inputRange[i]
			
			let y1 = outputRange[i - 1]
			let y2 = outputRange[i]
			
			if x <= inputRange[i] {
				return y1 + ((y2 - y1) / (x2 - x1)) * (x - x1)
			}
		}
		
		return outputRange[length]
	}
}
