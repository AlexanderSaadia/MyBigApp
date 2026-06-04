import SwiftUI

// MARK: - Stats & Records View
// This view provides a high-level overview of practice data and goal history.
struct StatsView: View {
    
    // MARK: - Environment & State
    
    // Access the shared activity data.
    @Environment(ActivityStore.self) private var activityStore
    
    // Tracks the current filter for the summary (Weekly, Monthly, Yearly).
    @State private var timeRange: TimeRange = .weekly
    
    // Controls the visibility of the "History Goals" pop-up sheet.
    @State private var showGoalHistory = false
    
    // Defines the possible time filters for the dashboard.
    enum TimeRange: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    // MARK: - Computed Properties
    
    // Filters the master activity list based on the user's selected time range.
    private func filteredActivities() -> [Activity] {
        let calendar = Calendar.current
        let now = Date()
        var result: [Activity] = []
        
        for activity in activityStore.activities {
            // We only include regular training sessions in these stats, not long-term goals.
            if activity.isGoal { continue }
            
            switch timeRange {
            case .weekly:
                // Check if the session happened in the same week as right now.
                if calendar.isDate(activity.date, equalTo: now, toGranularity: .weekOfYear) {
                    result.append(activity)
                }
            case .monthly:
                // Check if it happened in the same month.
                if calendar.isDate(activity.date, equalTo: now, toGranularity: .month) {
                    result.append(activity)
                }
            case .yearly:
                // Check if it happened in the same year.
                if calendar.isDate(activity.date, equalTo: now, toGranularity: .year) {
                    result.append(activity)
                }
            }
        }
        return result
    }
    
    // MARK: - Goal Helpers
    
    // Returns a list of all long-term goals that have been marked as completed.
    private func completedGoals() -> [Activity] {
        var result: [Activity] = []
        for activity in activityStore.activities {
            if activity.isGoal && activity.isCompleted {
                result.append(activity)
            }
        }
        return result
    }
    
    // Calculates the totals for Time, Distance, and Basketball Points across the filtered list.
    private var aggregateStats: (duration: Int, distance: Double, points: Int) {
        let activities = filteredActivities()
        var totalDuration: Double = 0
        var totalDistance: Double = 0
        var totalPoints: Int = 0
        
        for activity in activities {
            totalDuration += activity.duration
            totalDistance += activity.distance
            
            // Use our math helper to parse stats like "3/9" and add to the point total.
            totalPoints += calculatePoints(for: activity)
        }
        
        return (Int(totalDuration), totalDistance, totalPoints)
    }

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // SECTION 1: Summary Dashboard
                Section {
                    VStack(spacing: 20) {
                        // The segmented selector for Time Range.
                        Picker("Time Range", selection: $timeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        // Button to open the separate goal completion history.
                        Button(action: { showGoalHistory = true }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("History Goals")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.yellow.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(10)
                        }
                        
                        // Cards showing the calculated summary totals.
                        HStack(spacing: 15) {
                            StatSummaryCard(title: "Time", value: "\(aggregateStats.duration)", unit: "m", color: .blue)
                            StatSummaryCard(title: "Dist", value: String(format: "%.1f", aggregateStats.distance), unit: "km", color: .green)
                            StatSummaryCard(title: "Pts", value: "\(aggregateStats.points)", unit: "tot", color: .orange)
                        }
                    }
                    .padding(.vertical, 10)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                // SECTION 2: Complete Activity History
                Section(header: Text("Activity Records")) {
                    if activityStore.activities.isEmpty {
                        // Empty state.
                        Text("No activities recorded yet.")
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                    } else {
                        // Display sessions in reverse order (newest at the top).
                        ForEach(activityStore.activities.reversed()) { activity in
                            if !activity.isGoal {
                                // Tap an entry to see the full detail view.
                                NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                    ActivityRecordRow(activity: activity)
                                        .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                        .listRowSeparator(.hidden)
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                        // Allow swiping to delete items from history.
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats & Records")
            // Show the Goal history when the state is toggled.
            .sheet(isPresented: $showGoalHistory) {
                GoalHistoryView(goals: completedGoals())
            }
        }
    }
    
    // MARK: - Functions
    
    // Deletes items from the store based on their index in the reversed list.
    private func deleteItems(at offsets: IndexSet) {
        let reversedActivities = activityStore.activities.reversed()
        for index in offsets {
            let activityToDelete = Array(reversedActivities)[index]
            activityStore.deleteActivity(activityToDelete)
        }
    }
}

// MARK: - Goal History Sheet
// A simplified view for reviewing archived/finished goals.
struct GoalHistoryView: View {
    @Environment(\.dismiss) var dismiss // For the "Done" button.
    let goals: [Activity]
    
    var body: some View {
        NavigationStack {
            List {
                if goals.isEmpty {
                    Text("No goals completed yet.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(goals.reversed()) { goal in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                                Text(goal.name)
                                    .font(.headline)
                                Spacer()
                                Text(goal.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Show the completion note if one was added.
                            if !goal.completionNote.isEmpty {
                                Text(goal.completionNote)
                                    .font(.subheadline)
                                    .italic()
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.yellow.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Goal History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Summary Card Component
struct StatSummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    StatsView()
        .environment(ActivityStore())
}
