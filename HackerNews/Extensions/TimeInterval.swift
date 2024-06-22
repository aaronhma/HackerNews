//
//  TimeInterval.swift
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
    
    func timeIntervalToString() -> String {
        let calendar = Calendar.current
        let unitFlags: Set<Calendar.Component> = [.year, .month, .weekOfYear, .day, .hour, .minute, .second]
        let components = calendar.dateComponents(unitFlags, from: Date(timeIntervalSince1970: self), to: Date())

        if let years = components.year, years > 0 {
            return years == 1 ? "1 year ago" : "\(years) years ago"
        } else if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        } else {
            return components.second == 1 ? "1 second ago" : "\(components.second ?? 0) seconds ago"
        }
    }
}
