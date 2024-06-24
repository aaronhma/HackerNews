//
//  Ask.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/23/24.
//

import Foundation

struct Ask: Codable {
    var by: String
    var descendants: Int
    var id: Int
    var kids: [Int]?
    var score: Int
    var text: String
    var time: TimeInterval
    var title: String
    var type: String
}
