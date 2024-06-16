//
//  User.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation

struct User: Codable {
    var about: String
    var created: TimeInterval
    var id: Int
    var karma: Int
    var submitted: [Int]
}
