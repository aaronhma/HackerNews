//
//  URL.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation

extension URL {
    func hostURL() -> String {
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            if let host = components.host {
                return host
            }
        }
        
        return ""
    }
    
    func prettify() -> URL {
        var absoluteString = self.absoluteString
        
        if let hashIndex = absoluteString.firstIndex(of: "#") {
            absoluteString = String(absoluteString[..<hashIndex])
        }
        
        if let queryIndex = absoluteString.firstIndex(of: "?") {
            absoluteString = String(absoluteString[..<queryIndex])
        }
        
        if !absoluteString.isEmpty && absoluteString.last == "/" {
            absoluteString = String(absoluteString.dropLast())
        }
        
        return URL(string: absoluteString)!
    }
}
