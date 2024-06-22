//
//  NetworkMonitor.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation
import Network

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Hacker News - Network Monitor")
    
    var isActive = false
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.isActive = path.status == .satisfied

            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }

        monitor.start(queue: queue)
    }
}
