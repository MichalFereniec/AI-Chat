//
//  Extensions.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/3/24.
//
import Foundation

extension String {
    static var random: String {
        UUID().uuidString
    }
    
    static func randomHexColor() -> String {
        return "#\(UUID().uuidString.prefix(6))"
    }
}

extension Bool {
    static var random: Bool {
        Bool.random()
    }
}

extension Date {
    static var random: Date {
        let randomTimeInterval = TimeInterval.random(in: 0...2_000_000_000)
        return Date(timeIntervalSince1970: randomTimeInterval)
    }
    
    static func random(in range: Range<TimeInterval>) -> Date {
        let randomTimeInterval = TimeInterval.random(in: range)
        return Date(timeIntervalSince1970: randomTimeInterval)
    }
    
    static func random(in range: ClosedRange<TimeInterval>) -> Date {
        let randomTimeInterval = TimeInterval.random(in: range)
        return Date(timeIntervalSince1970: randomTimeInterval)
    }
    
    func truncatedToSeconds() -> Date {
        let timeInterval = floor(self.timeIntervalSince1970)
        return Date(timeIntervalSince1970: timeInterval)
    }
}
