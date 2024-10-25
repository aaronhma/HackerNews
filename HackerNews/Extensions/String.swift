//
//  String.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/5/24.
//

import SwiftSoup
import Foundation

extension String {
    func isValidURL() -> Bool {
        guard self.count >= 10 else { return false } // http://a.a
        
        if let url = URLComponents(string: self) {
            if url.scheme != nil && !url.scheme!.isEmpty {
                let scheme = (url.scheme ?? "fail")
                return scheme == "http" || scheme == "https"
            }
        }
        
        return false
    }
    
    func parseHTML() -> String {
        let BREAKPOINT = "}30BR082{"
        
        do {
            var modifiedString = ""
            var currentIndex = self.startIndex
            
            while let range = self[currentIndex...].range(of: "<p>") {
                let index = range.lowerBound
                modifiedString += self[currentIndex..<index]
                modifiedString += BREAKPOINT
                currentIndex = range.upperBound
            }
            
            modifiedString += self[currentIndex...]
            
            return try SwiftSoup.parseBodyFragment(modifiedString).body()!.text().replacingOccurrences(of: BREAKPOINT, with: "\n\n")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
