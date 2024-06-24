//
//  Job.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/23/24.
//

import Foundation

struct Job: Codable {
    var by: String
    var id: Int
    var score: Int
    var text: String
    var time: TimeInterval
    var title: String
    var type: String
    var url: String
}
