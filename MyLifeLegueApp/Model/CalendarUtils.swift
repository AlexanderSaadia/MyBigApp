//
//  CalendarUtils.swift
//  MyBigApp
//
//  Created by Gemini CLI on 08/05/26.
//

import Foundation

// CalendarUtils is a "Utility" struct.
// It contains "pure" logic functions that help us calculate date math without 
// worrying about the user interface.
struct CalendarUtils {
    // We use the 'current' calendar which respects the user's local settings (e.g. 12/24h, first day of week).
    static let calendar = Calendar.current
    
    // Generates an array of all dates that should be visible in a standard monthly calendar grid.
    // This includes the days of the current month plus leading/trailing days from adjacent weeks.
    static func daysInMonth(for date: Date) -> [Date] {
        // Finding the boundaries of the month
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else { return [] }
        
        var result: [Date] = []
        
        // Calculate total days to display (usually 35 or 42 for a full grid)
        let components = calendar.dateComponents([.day], from: monthFirstWeek.start, to: monthLastWeek.end)
        let numberOfDays = components.day ?? 0
        
        // This is a "bounded loop" - it has a fixed start and end point, making it safe and crash-proof.
        for dayOffset in 0..<numberOfDays {
            if let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: monthFirstWeek.start) {
                result.append(nextDate)
            }
        }
        
        return result
    }
    
    // Calculates the 7 days that make up the week of a given date.
    static func daysInWeek(for date: Date) -> [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        
        var result: [Date] = []
        // Standard week is always 7 days
        for dayOffset in 0..<7 {
            if let nextDate = calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start) {
                result.append(nextDate)
            }
        }
        return result
    }
    
    // Calculates the start date for each of the 12 months in the year of a given date.
    static func monthsInYear(for date: Date) -> [Date] {
        guard let yearInterval = calendar.dateInterval(of: .year, for: date) else { return [] }
        
        var result: [Date] = []
        // Standard year is always 12 months
        for monthOffset in 0..<12 {
            if let nextDate = calendar.date(byAdding: .month, value: monthOffset, to: yearInterval.start) {
                result.append(nextDate)
            }
        }
        return result
    }
    
    // MARK: - Formatting Helpers
    // These functions transform raw Date objects into human-readable Strings.
    
    static func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM" // Returns e.g. "January"
        return formatter.string(from: date)
    }
    
    static func yearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy" // Returns e.g. "2026"
        return formatter.string(from: date)
    }
    
    static func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // Returns e.g. "8"
        return formatter.string(from: date)
    }
    
    static func shortWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Returns e.g. "Fri"
        return formatter.string(from: date)
    }
}
