//
//  Story.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation

struct Story: Codable, Hashable {
    var by: String
    var descendants: Int
    var id: Int
    var kids: [Int]?
    var score: Int
    var time: TimeInterval
    var title: String
    var type: String
    var url: String
}
