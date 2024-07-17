//
//  Tips.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/10/24.
//

import TipKit

struct PinchToSummarizeDiscussionTip: Tip {
//    static let summaryEvent = Event(id: "summarize-discussion")
    static let tipViewedTimes = Event(id: "summarize-discussion")
    
    var title: Text {
        Text("Pinch to Summarize")
    }
    
    var message: Text? {
        Text("Too long of a discussion? Pinch to summarize the main points. [not working - wait until next release]")
    }
    
    var image: Image? {
        Image(systemName: "hand.pinch.fill")
    }
    
    var rules: [Rule] {
//        #Rule(Self.summaryEvent) { event in
//            event.donations.count == 0
//        }
        
        #Rule(Self.tipViewedTimes) { event in
            event.donations.count <= 5
        }
    }
    
    var actions: [Action] {
        [Action(id: "summarize-discussion", title: "Summarize Discussion")]
    }
}

struct PinchToSummarizeArticleTip: Tip {
    static let tipViewedTimes = Event(id: "summarize-discussion")
    
    var title: Text {
        Text("Pinch to Summarize")
    }
    
    var message: Text? {
        Text("Too long of an article? Pinch to summarize the main points. [not working - wait until next release]")
    }
    
    var image: Image? {
        Image(systemName: "hand.pinch.fill")
    }
    
    var rules: [Rule] {
//        #Rule(Self.summaryEvent) { event in
//            event.donations.count == 0
//        }
        
        #Rule(Self.tipViewedTimes) { event in
            event.donations.count <= 5
        }
    }
    
    var actions: [Action] {
        [Action(id: "summarize-discussion", title: "Summarize Discussion")]
    }
}
