//
//  Storage.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation
import SwiftData

enum UserOpinion: Codable {
    case liked
    case disliked
    case unknown
}

@Model
class StoryStorage {
    @Attribute(.allowsCloudEncryption) var id: Int
    @Attribute(.allowsCloudEncryption) var userOpinion: UserOpinion
    @Attribute(.allowsCloudEncryption) var saved: Bool
    
    init(id: Int, userOpinion: UserOpinion, saved: Bool) {
        self.id = id
        self.userOpinion = userOpinion
        self.saved = saved
    }
}
