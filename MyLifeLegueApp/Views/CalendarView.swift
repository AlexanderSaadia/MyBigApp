import SwiftUI

// Defines the 4 different zoom levels for our calendar
enum CalendarViewMode: String, CaseIterable {
    case daily = "Day"
    case weekly = "Week"
    case monthly = "Month"
    case yearly = "Year"
}

struct CalendarView: View {
    // MARK: - Stored properties
    
    // Grabs the shared data store from the app's environment
    @Environment(ActivityStore.self) private var activityStore
    
    // Tracks which mode (Day/Week/Month/Year) the user is currently looking at
    @State private var viewMode: CalendarViewMode = .monthly
    
    // The specific date being focused on in the calendar
    @State private var selectedDate: Date = Date()
    
    // MARK: - Computed properties
    
    // Dynamically generates the header title (e.g., "May 2026") based on the selected date
    private var titleForMode: String {
        switch viewMode {
        case .daily, .weekly, .monthly:
            return CalendarUtils.monthName(from: selectedDate) + " " + CalendarUtils.yearString(from: selectedDate)
        case .yearly:
            return CalendarUtils.yearString(from: selectedDate)
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                // Segmented picker allows user to switch between calendar modes
                Picker("View Mode", selection: $viewMode) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content area: Displays a different sub-view depending on the selected mode
                Group {
                    switch viewMode {
                    case .daily:
                        DailyCalendarView(date: selectedDate)
                    case .weekly:
                        WeeklyCalendarView(date: selectedDate)
                    case .monthly:
                        MonthlyCalendarView(selectedDate: $selectedDate)
                    case .yearly:
                        YearlyCalendarView(selectedDate: $selectedDate, viewMode: $viewMode)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(titleForMode)
            .toolbar {
                // Toolbar buttons for jumping forward/backward in time
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Button(action: { moveDate(by: -1) }) {
                            Image(systemName: "chevron.left")
                        }
                        Button(action: { moveDate(by: 1) }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Functions
    
    // Increments or decrements the selected date by one unit of the current view mode
    private func moveDate(by value: Int) {
        let calendar = Calendar.current
        switch viewMode {
        case .daily:
            selectedDate = calendar.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
        case .weekly:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) ?? selectedDate
        case .monthly:
            selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
        case .yearly:
            selectedDate = calendar.date(byAdding: .year, value: value, to: selectedDate) ?? selectedDate
        }
    }
}

// MARK: - Daily View
// Displays a detailed list of activities for a single day.
struct DailyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    let date: Date
    
    var body: some View {
        // Query the store for activities matching this specific date
        let activities = activityStore.activities(for: date)
        
        if activities.isEmpty {
            // Empty state view
            VStack {
                Spacer()
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
                Text("No activities for this day")
                    .foregroundColor(.gray)
                Spacer()
            }
        } else {
            // List view of the day's activities
            List {
                ForEach(activities) { activity in
                    HStack {
                        Image(systemName: activity.symbol)
                            .foregroundColor(.blue)
                        Text(activity.name)
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Weekly View
// Provides a row-by-row overview of the entire week.
struct WeeklyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    let date: Date
    
    var body: some View {
        // Get the 7 dates for the week
        let days = CalendarUtils.daysInWeek(for: date)
        
        ScrollView {
            VStack(spacing: 15) {
                // Generate a row for each day of the week
                ForEach(days, id: \.self) { day in
                    WeeklyDayRow(day: day)
                }
            }
            .padding(.vertical)
        }
    }
}

// Sub-component for a single day's row in the Weekly view
struct WeeklyDayRow: View {
    @Environment(ActivityStore.self) private var activityStore
    let day: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(CalendarUtils.shortWeekday(from: day))
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(CalendarUtils.dayNumber(from: day))
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Check for activities on this specific day
            let activities = activityStore.activities(for: day)
            if activities.isEmpty {
                Text("No activities")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                // Horizontal scroll of icons representing activities
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(activities) { activity in
                            VStack {
                                Image(systemName: activity.symbol)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text(activity.name)
                                    .font(.caption2)
                            }
                            .frame(width: 60)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            Divider()
                .padding(.top, 5)
        }
    }
}

// MARK: - Monthly View
// Displays a standard 7-column calendar grid.
struct MonthlyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    @Binding var selectedDate: Date
    
    // Grid configuration for 7 columns (one for each day of the week)
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        // Get all dates needed for the month's grid
        let days = CalendarUtils.daysInMonth(for: selectedDate)
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        
        VStack {
            // Header for weekday labels
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
            
            // The actual calendar grid
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(days, id: \.self) { day in
                    let isToday = Calendar.current.isDateInToday(day)
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                    let activities = activityStore.activities(for: day)
                    // Dim days that aren't part of the current month
                    let isOtherMonth = !Calendar.current.isDate(day, equalTo: selectedDate, toGranularity: .month)
                    
                    VStack {
                        Text(CalendarUtils.dayNumber(from: day))
                            .font(.body)
                            .foregroundColor(isOtherMonth ? .gray.opacity(0.5) : (isSelected ? .white : .primary))
                            .frame(width: 30, height: 30)
                            .background(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.3) : Color.clear))
                            .clipShape(Circle())
                        
                        // Small blue dot indicates that activities exist for this day
                        HStack(spacing: 2) {
                            if !activities.isEmpty {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                    .onTapGesture {
                        // Updating selectedDate here causes the whole view to refresh
                        selectedDate = day
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Show detailed activity list for the day selected in the grid
            DailyCalendarView(date: selectedDate)
        }
    }
}

// MARK: - Yearly View
// Provides a bird's eye view of all 12 months in the year.
struct YearlyCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarViewMode
    
    // 3 columns for months
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        let months = CalendarUtils.monthsInYear(for: selectedDate)
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(months, id: \.self) { month in
                    VStack {
                        Text(CalendarUtils.monthName(from: month).prefix(3))
                            .font(.headline)
                        
                        // Mini preview grid for the month
                        MiniMonthView(month: month)
                            .frame(height: 80)
                    }
                    .padding(5)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(10)
                    .onTapGesture {
                        // Tapping a month zooms in to the Monthly view for that month
                        selectedDate = month
                        viewMode = .monthly
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Mini Month View for Yearly view
// A simple non-interactive grid of dots to represent a month.
struct MiniMonthView: View {
    let month: Date
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    
    var body: some View {
        let days = CalendarUtils.daysInMonth(for: month)
        
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(days, id: \.self) { day in
                let isCurrentMonth = Calendar.current.isDate(day, equalTo: month, toGranularity: .month)
                
                // Dim dots for days that belong to next/previous months
                Circle()
                    .fill(isCurrentMonth ? Color.blue.opacity(0.3) : Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    PickerView()
        .environment(ActivityStore())
}
