//
//  CalendarView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

enum CalendarViewMode: String, CaseIterable {
    case daily = "Day"
    case weekly = "Week"
    case monthly = "Month"
    case yearly = "Year"
}

struct CalendarView: View {
    // MARK: - Stored properties
    @Environment(ActivityStore.self) private var activityStore
    @State private var viewMode: CalendarViewMode = .monthly
    @State private var selectedDate: Date = Date()
    
    // MARK: - Computed properties
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
                Picker("View Mode", selection: $viewMode) {
                    ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
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
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        let days = CalendarUtils.daysInMonth(for: selectedDate)
        let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
        
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
                    let activities = activityStore.activities(for: day)
                    let isOtherMonth = !Calendar.current.isDate(day, equalTo: selectedDate, toGranularity: .month)
                    
                    VStack {
                        Text(CalendarUtils.dayNumber(from: day))
                            .font(.body)
                            .foregroundColor(isOtherMonth ? .gray.opacity(0.5) : (isSelected ? .white : .primary))
                            .frame(width: 30, height: 30)
                            .background(isSelected ? Color.blue : (isToday ? Color.blue.opacity(0.3) : Color.clear))
                            .clipShape(Circle())
                        
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
                        selectedDate = day
                    }
                }
            }
            .padding()
            
            Divider()
            
            // Show activities for selected day
            DailyCalendarView(date: selectedDate)
        }
    }
}

// MARK: - Yearly View
struct YearlyCalendarView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalendarViewMode
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        let months = CalendarUtils.monthsInYear(for: selectedDate)
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(months, id: \.self) { month in
                    VStack {
                        Text(CalendarUtils.monthName(from: month).prefix(3))
                            .font(.headline)
                        
                        MiniMonthView(month: month)
                            .frame(height: 80)
                    }
                    .padding(5)
                    .background(Color.secondary.opacity(0.05))
                    .cornerRadius(10)
                    .onTapGesture {
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
struct MiniMonthView: View {
    let month: Date
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    
    var body: some View {
        let days = CalendarUtils.daysInMonth(for: month)
        
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(days, id: \.self) { day in
                let isCurrentMonth = Calendar.current.isDate(day, equalTo: month, toGranularity: .month)
                
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
