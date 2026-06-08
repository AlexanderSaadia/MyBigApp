import SwiftUI
import SwiftData

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
    
    // --- INPUT: Tracks which mode (Day/Week/Month/Year) is active ---
    @State private var viewMode: CalendarViewMode = .monthly
    
    // --- INPUT: The date currently being viewed ---
    @State private var selectedDate: Date = Date()
    
    // MARK: - Computed Properties
    
    // --- OUTPUT: Dynamic header title ---
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
                // --- INPUT: Segmented Picker ---
                Picker("View Mode", selection: $viewMode) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // OUTPUT CONTENT: Switches based on the 'viewMode' input.
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
                // --- INPUT: Time travel buttons ---
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
    
    // --- DATA FLOW: Updates the selectedDate state ---
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
struct DayCell: View {
    @Environment(ActivityStore.self) private var activityStore
    // --- INPUT: A specific calendar day ---
    let day: Date
    let isSelected: Bool
    let isToday: Bool
    let isOtherMonth: Bool
    let scale: CGFloat
    
    var body: some View {
        // --- ARRAY FILTERING: Finds items for THIS specific day cell ---
        let activities = activityStore.activities(for: day)
        
        VStack(spacing: 2 * scale) {
            // OUTPUT: The day number.
            Text(CalendarUtils.dayNumber(from: day))
                .font(.system(size: 16 * scale))
                .foregroundColor(isOtherMonth ? .gray.opacity(0.5) : (isSelected ? .white : .primary))
                .frame(width: 30 * scale, height: 30 * scale)
                .background(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.3) : Color.clear))
                .clipShape(Circle())
            
            // --- OUTPUT (Activity Dots) ---
            HStack(spacing: 2 * scale) {
                if !activities.isEmpty {
                    // --- ARRAY ITERATION (Internal Dots) ---
                    ForEach(0..<min(activities.count, 3), id: \.self) { index in
                        let activity = activities[index]
                        Circle()
                            .fill(activity.isGoal ? Color.orange : Color.red)
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
    // --- INPUT: The selected date to display ---
    let date: Date
    
    var body: some View {
        // --- ARRAY FILTERING: Gets items from the store for this date ---
        let activities = activityStore.activities(for: date)
        
        if activities.isEmpty {
            // OUTPUT: Empty state.
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
            // --- ARRAY ITERATION (UI) ---
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
                        
                        // OUTPUT: Status icon.
                        if activity.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
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
struct WeeklyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    let date: Date
    
    var body: some View {
        // --- ARRAY: Collection of 7 days in the week ---
        let days = CalendarUtils.daysInWeek(for: date)
        
        ScrollView {
            VStack(spacing: 15) {
                // --- ARRAY ITERATION (UI) ---
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
            
            // --- ARRAY FILTERING: Items for this row ---
            let activities = activityStore.activities(for: day)
            if activities.isEmpty {
                Text("No activities")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        // --- ARRAY ITERATION (UI) ---
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
struct MonthlyCalendarView: View {
    @Environment(ActivityStore.self) private var activityStore
    // --- INPUT/OUTPUT: Two-way binding for date selection ---
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            // OUTPUT: Grid of days.
            MonthGridView(month: selectedDate, selectedDate: $selectedDate)
            
            Divider()
            
            // OUTPUT: Detailed list for the selected day.
            DailyCalendarView(date: selectedDate)
        }
    }
}

// MARK: - Yearly View
struct YearlyCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarViewMode
    
    var body: some View {
        // --- ARRAY: Collection of 12 months ---
        let months = CalendarUtils.monthsInYear(for: selectedDate)
        
        ScrollView {
            VStack(spacing: 30) {
                // --- ARRAY ITERATION (UI) ---
                ForEach(months, id: \.self) { month in
                    VStack(alignment: .leading) {
                        Text(CalendarUtils.monthName(from: month))
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        MonthGridView(month: month, selectedDate: $selectedDate, onDayTapped: { day in
                            // --- INPUT: Tap jumps from Year to Day mode ---
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
struct MonthGridView: View {
    let month: Date
    @Binding var selectedDate: Date
    var onDayTapped: ((Date) -> Void)? = nil
    
    // --- ARRAY SETUP ---
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        // --- ARRAY: Collection of all days in the month ---
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
                // --- ARRAY ITERATION (UI) ---
                ForEach(days, id: \.self) { day in
                    let isToday = Calendar.current.isDateInToday(day)
                    let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                    let isOtherMonth = !Calendar.current.isDate(day, equalTo: month, toGranularity: .month)
                    
                    DayCell(day: day, isSelected: isSelected, isToday: isToday, isOtherMonth: isOtherMonth, scale: 1.0)
                        .onTapGesture {
                            // --- INPUT: Tap to select a day ---
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
        .environment(ActivityStore.preview)
        .modelContainer(ActivityStore.previewContainer)
}
