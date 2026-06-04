import Foundation

// MARK: - Calendar Utilities
// This helper struct provides static functions for common date formatting and calendar logic.
struct CalendarUtils {
    
    // Returns the full name of the month for a given date (e.g., "January").
    static func monthName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    // Returns the year as a string (e.g., "2026").
    static func yearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
    
    // Returns just the day number (e.g., "15").
    static func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // Returns the first three letters of the weekday (e.g., "Mon").
    static func shortWeekday(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    // Generates an array of all dates in the current month, including padding days to fill the grid.
    static func daysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        // Find the first day of the month.
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        let firstDayOfMonth = monthInterval.start
        
        // Find the last day of the month.
        let lastDayOfMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
        
        // Find the weekday of the first day to know how much padding we need (e.g., if month starts on Tuesday).
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        let paddingDays = weekday - 1
        
        var days: [Date] = []
        
        // Add padding days from the previous month so the first day aligns correctly in the week.
        for i in (0..<paddingDays).reversed() {
            if let day = calendar.date(byAdding: .day, value: -i - 1, to: firstDayOfMonth) {
                days.append(day)
            }
        }
        
        // Add all actual days of the current month.
        var currentDay = firstDayOfMonth
        while currentDay < lastDayOfMonth {
            days.append(currentDay)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) {
                currentDay = nextDay
            } else {
                break
            }
        }
        
        // Add padding days from the next month to finish the last week of the grid.
        let remainingDays = 42 - days.count // standard 6-row calendar grid has 42 cells
        for i in 1...remainingDays {
            if let day = calendar.date(byAdding: .day, value: i - 1, to: lastDayOfMonth) {
                days.append(day)
            }
        }
        
        return days
    }
    
    // Returns all 7 days of the week that the given date falls into.
    static func daysInWeek(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        // Find the Sunday of the current week.
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        let firstDayOfWeek = weekInterval.start
        
        var days: [Date] = []
        for i in 0..<7 {
            // Increment day by day to get the full week.
            if let day = calendar.date(byAdding: .day, value: i, to: firstDayOfWeek) {
                days.append(day)
            }
        }
        return days
    }
    
    // Returns the first day of every month for the year of the given date.
    static func monthsInYear(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        // Find the start of the year (January 1st).
        guard let yearInterval = calendar.dateInterval(of: .year, for: date) else { return [] }
        let firstDayOfYear = yearInterval.start
        
        var months: [Date] = []
        for i in 0..<12 {
            // Increment month by month to get the full year.
            if let month = calendar.date(byAdding: .month, value: i, to: firstDayOfYear) {
                months.append(month)
            }
        }
        return months
    }
}
