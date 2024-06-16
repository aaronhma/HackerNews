//
//  TimeInterval+convertToDateComponents.swift
//  HackerNews
//
//  Created by Aaron Ma on 6/15/24.
//

import Foundation

extension TimeInterval {
    func convertToDateComponents() -> DateComponents {
        let date = Date(timeIntervalSince1970: self)
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        return dateComponents
    }
}
