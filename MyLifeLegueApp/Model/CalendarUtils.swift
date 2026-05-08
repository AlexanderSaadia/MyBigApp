//
//  CalendarUtils.swift
//  MyBigApp
//
//  Created by Gemini CLI on 08/05/26.
//

import Foundation

struct CalendarUtils {
    static let calendar = Calendar.current
    
    static func daysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }
        
        var result: [Date] = []
        var current = monthFirstWeek.start
        while current < monthLastWeek.end {
            result.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return result
    }
    
    static func daysInWeek(for date: Date) -> [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        
        var result: [Date] = []
        var current = weekInterval.start
        for _ in 0..<7 {
            result.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return result
    }
    
    static func monthsInYear(for date: Date) -> [Date] {
        guard let yearInterval = calendar.dateInterval(of: .year, for: date) else { return [] }
        
        var result: [Date] = []
        var current = yearInterval.start
        for _ in 0..<12 {
            result.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        return result
    }
    
    static func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    static func yearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    static func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    static func shortWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}
