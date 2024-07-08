//
//  Color+random.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/7/24.
//

import SwiftUI

extension Color {
    static func random(randomOpacity: Bool = false) -> Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            opacity: randomOpacity ? .random(in: 0...1) : 1
        )
    }
}
