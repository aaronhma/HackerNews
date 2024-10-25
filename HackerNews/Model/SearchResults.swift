//
//  SearchResults.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/17/24.
//

import Foundation

struct SearchResults: Codable {
    let hits: [Hit]
    
    struct Hit: Codable, Identifiable {
        let id = UUID()
        let objectID: String
        let title: String
        let points: Int
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.objectID = try container.decode(String.self, forKey: .objectID)
            self.points = try container.decode(Int.self, forKey: .points)
            
            if let title = try? container.decode(String.self, forKey: .title) {
                self.title = title
            } else if let storyTitle = try? container.decode(String.self, forKey: .storyTitle) {
                self.title = storyTitle
            } else {
                self.title = "[Error fetching story]"
            }
        }
        
        func encode(to encoder: Encoder) throws {
        }
        
        enum CodingKeys: String, CodingKey {
            case objectID
            case title
            case storyTitle = "story_title"
            case points
        }
    }
}
