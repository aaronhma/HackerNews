//
//  View+apply.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/5/24.
//

import SwiftUI

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
