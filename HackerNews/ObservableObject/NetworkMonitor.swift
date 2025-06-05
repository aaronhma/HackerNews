//
//  NetworkMonitor.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
	@Published var isConnected: Bool = false
	
	init() {
		startMonitoring()
	}
	
	private var queue = DispatchQueue(label: "bark for Hacker News - Network Status Monitor")
	private var monitor = NWPathMonitor()
	
	private func startMonitoring() {
		monitor.pathUpdateHandler = { path in
			Task { @MainActor in
				self.isConnected = path.status == .satisfied
			}
		}
		
		monitor.start(queue: queue)
	}
}
