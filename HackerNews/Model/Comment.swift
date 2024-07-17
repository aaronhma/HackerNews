//
//  Comment.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation

struct Comment: Codable, Hashable, Identifiable {
    var by: String
    var id: Int
    var kids: [Int]?
    var parent: Int
    var text: String
    var time: TimeInterval
    var type: String
}
