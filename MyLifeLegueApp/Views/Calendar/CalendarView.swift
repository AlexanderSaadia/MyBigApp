import SwiftUI

// MARK: - Calendar View Mode
// Defines the 4 different zoom levels for our calendar interface.
enum CalendarViewMode: String, CaseIterable {
    case daily = "Day"
    case weekly = "Week"
    case monthly = "Month"
    case yearly = "Year"
}

// MARK: - Main Calendar View
// This view provides a multi-mode interactive calendar for browsing activities by date.
struct CalendarView: View {
    
    // MARK: - Environment & State
    
    // Access the shared data store from the app's environment.
    @Environment(ActivityStore.self) private var activityStore
    
    // Tracks which mode (Day/Week/Month/Year) the user is currently looking at.
    @State private var viewMode: CalendarViewMode = .monthly
    
    // The specific date being focused on in the calendar.
    @State private var selectedDate: Date = Date()
    
    // MARK: - Computed Properties
    
    // Dynamically generates the header title (e.g., "May 2026") based on the selected date and mode.
    private var titleForMode: String {
        switch viewMode {
        case .daily, .weekly, .monthly:
            // Combine month and year for most modes.
            return CalendarUtils.monthName(from: selectedDate) + " " + CalendarUtils.yearString(from: selectedDate)
        case .yearly:
            // Show only the year in yearly mode.
            return CalendarUtils.yearString(from: selectedDate)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack {
                // Segmented picker allows user to switch between calendar zoom levels.
                Picker("View Mode", selection: $viewMode) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // CONTENT AREA: Displays a different sub-view depending on the selected mode.
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
            // Set the dynamic navigation title.
            .navigationTitle(titleForMode)
            .toolbar {
                // Navigation buttons for jumping forward or backward in time.
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
    
    // Shifts the selected date by one unit of the current view mode (e.g., +1 month or -1 year).
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

// MARK: - Day Cell Component
// Represents a single day box in the monthly or yearly grid.
struct DayCell: View {
    @Environment(ActivityStore.self) private var activityStore
    let day: Date
    let isSelected: Bool
    let isToday: Bool
    let isOtherMonth: Bool
    let scale: CGFloat
    
    var body: some View {
        // Fetch all activities for this specific day.
        let activities = activityStore.activities(for: day)
        
        VStack(spacing: 2 * scale) {
            // The day number.
            Text(CalendarUtils.dayNumber(from: day))
                .font(.system(size: 16 * scale))
                // Dim the color if the day belongs to the previous/next month.
                .foregroundColor(isOtherMonth ? .gray.opacity(0.5) : (isSelected ? .white : .primary))
                .frame(width: 30 * scale, height: 30 * scale)
                // Highlight the background if selected or today.
                .background(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.3) : Color.clear))
                .clipShape(Circle())
            
            // ACTIVITY INDICATORS: Small dots shown below the day number.
            HStack(spacing: 2 * scale) {
                if !activities.isEmpty {
                    // Show up to 3 dots to indicate activity volume.
                    ForEach(0..<min(activities.count, 3), id: \.self) { index in
                        let activity = activities[index]
                        Circle()
                            // Goals are orange dots, regular activities are red dots.
                            .fill(activity.isGoal ? Color.orange : Color.red)
                            .frame(width: 4 * scale, height: 4 * scale)
                    }
                    // If there are more than 3, show a plus sign.
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
// Shows a list of activities for the selected date.
struct DailyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    let date: Date
    
    // State used if we want to add quick notes (not currently triggered by main Home flow).
    @State private var showNoteAlert = false
    @State private var selectedActivity: Activity?
    @State private var completionNote: String = ""
    
    var body: some View {
        let activities = activityStore.activities(for: date)
        
        if activities.isEmpty {
            // State shown when no sessions are logged for this day.
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
            // List of all sessions for the day.
            List {
                ForEach(activities) { activity in
                    HStack {
                        Image(systemName: activity.isGoal ? "target" : activity.symbol)
                            .foregroundColor(activity.isGoal ? .orange : .blue)
                        
                        VStack(alignment: .leading) {
                            Text(activity.name)
                                .fontWeight(.semibold)
                            if activity.isGoal {
                                Text("Goal")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Spacer()
                        
                        // Status indicator or quick complete button.
                        if activity.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            // Link or button to complete the session.
                            Text("Pending")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

// MARK: - Weekly View
// Displays the 7 days of the week in a vertical list format.
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

// MARK: - Weekly Row Component
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
                // Horizontal scroll of activity icons for this day.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(activities) { activity in
                            VStack {
                                Image(systemName: activity.isGoal ? "target" : activity.symbol)
                                    .font(.title2)
                                    .foregroundColor(activity.isGoal ? .orange : .blue)
                                Text(activity.name)
                                    .font(.caption2)
                            }
                            .frame(width: 60)
                            .padding(8)
                            .background(activity.isGoal ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
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
// Standard grid layout for the current month.
struct MonthlyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            // The grid of days.
            MonthGridView(month: selectedDate, selectedDate: $selectedDate)
            
            Divider()
            
            // The activity list for whichever day is tapped.
            DailyCalendarView(date: selectedDate)
        }
    }
}

// MARK: - Yearly View
// Shows 12 months as small grids in a scrolling list.
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
                        
                        // Small month grid that jumps to Daily view when a day is tapped.
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

// MARK: - Reusable Month Grid Component
// A 7-column grid layout representing a single month.
struct MonthGridView: View {
    let month: Date
    @Binding var selectedDate: Date
    var onDayTapped: ((Date) -> Void)? = nil
    
    // 7 columns for the days of the week.
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        let days = CalendarUtils.daysInMonth(for: month)
        
        VStack {
            // Header for Sunday through Saturday labels.
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal)
            
            // The actual day cells.
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(days, id: \.self) { day in
                    let isToday = Calendar.current.isDateInToday(day)
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                    let isOtherMonth = !Calendar.current.isDate(day, equalTo: month, toGranularity: .month)
                    
                    DayCell(day: day, isSelected: isSelected, isToday: isToday, isOtherMonth: isOtherMonth, scale: 1.0)
                        .onTapGesture {
                            // Update selection or trigger navigation callback.
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

// MARK: - Preview
#Preview {
    CalendarView()
        .environment(ActivityStore())
}
