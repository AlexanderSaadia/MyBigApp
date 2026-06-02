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

// MARK: - Sub-views

struct DayCell: View {
    @Environment(ActivityStore.self) private var activityStore
    let day: Date
    let isSelected: Bool
    let isToday: Bool
    let isOtherMonth: Bool
    let scale: CGFloat
    
    var body: some View {
        let activities = activityStore.activities(for: day)
        
        VStack(spacing: 2 * scale) {
            Text(CalendarUtils.dayNumber(from: day))
                .font(.system(size: 16 * scale))
                .foregroundColor(isOtherMonth ? .gray.opacity(0.5) : (isSelected ? .white : .primary))
                .frame(width: 30 * scale, height: 30 * scale)
                .background(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.3) : Color.clear))
                .clipShape(Circle())
            
            // Red spots for activities
            HStack(spacing: 2 * scale) {
                if !activities.isEmpty {
                    ForEach(0..<min(activities.count, 3), id: \.self) { _ in
                        Circle()
                            .fill(Color.red)
                            .frame(width: 4 * scale, height: 4 * scale)
                    }
                    if activities.count > 3 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 4 * scale, height: 4 * scale)
                            .overlay(
                                Text("+")
                                    .font(.system(size: 6 * scale))
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
            .frame(height: 4 * scale)
        }
    }
}

// MARK: - Daily View
struct DailyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    let date: Date
    
    var body: some View {
        let activities = activityStore.activities(for: date)
        
        if activities.isEmpty {
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
struct WeeklyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    let date: Date
    
    var body: some View {
        let days = CalendarUtils.daysInWeek(for: date)
        
        ScrollView {
            VStack(spacing: 15) {
                ForEach(days, id: \.self) { day in
                    WeeklyDayRow(day: day)
                }
            }
            .padding(.vertical)
        }
    }
}

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
            
            let activities = activityStore.activities(for: day)
            if activities.isEmpty {
                Text("No activities")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
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
struct MonthlyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            MonthGridView(month: selectedDate, selectedDate: $selectedDate)
            
            Divider()
            
            DailyCalendarView(date: selectedDate)
        }
    }
}

// MARK: - Yearly View
struct YearlyCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarViewMode
    
    var body: some View {
        let months = CalendarUtils.monthsInYear(for: selectedDate)
        
        ScrollView {
            VStack(spacing: 30) {
                ForEach(months, id: \.self) { month in
                    VStack(alignment: .leading) {
                        Text(CalendarUtils.monthName(from: month))
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        MonthGridView(month: month, selectedDate: $selectedDate, onDayTapped: { day in
                            selectedDate = day
                            viewMode = .daily
                        })
                    }
                    .padding(.vertical)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Reusable Month Grid
struct MonthGridView: View {
    let month: Date
    @Binding var selectedDate: Date
    var onDayTapped: ((Date) -> Void)? = nil
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        let days = CalendarUtils.daysInMonth(for: month)
        
        VStack {
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(days, id: \.self) { day in
                    let isToday = Calendar.current.isDateInToday(day)
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                    let isOtherMonth = !Calendar.current.isDate(day, equalTo: month, toGranularity: .month)
                    
                    DayCell(day: day, isSelected: isSelected, isToday: isToday, isOtherMonth: isOtherMonth, scale: 1.0)
                        .onTapGesture {
                            if let onDayTapped = onDayTapped {
                                onDayTapped(day)
                            } else {
                                selectedDate = day
                            }
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    CalendarView()
        .environment(ActivityStore())
}
