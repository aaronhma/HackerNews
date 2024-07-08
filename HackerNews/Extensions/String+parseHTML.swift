//
//  String+parseHTML.swift
//  HackerNews
//
//  Created by Aaron Ma on 7/5/24.
//

import SwiftSoup

extension String {
    func parseHTML() -> String {
        let BREAKPOINT = "}BR{"
        
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
