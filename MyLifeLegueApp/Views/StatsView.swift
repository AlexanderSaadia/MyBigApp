import SwiftUI

// This is the main "Stats & Records" dashboard.
// It shows high-level summaries and a list of all activities.
struct StatsView: View {
    @Environment(ActivityStore.self) private var activityStore
    @State private var timeRange: TimeRange = .weekly
    
    // Tracks if the Goal History side sheet is visible
    @State private var showGoalHistory = false
    
    enum TimeRange: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    // MARK: - Computed Properties for Filtered Stats
    
    private func filteredActivities() -> [Activity] {
        let calendar = Calendar.current
        let now = Date()
        var result: [Activity] = []
        
        for activity in activityStore.activities {
            // We only include regular activities in the main stats, not goals
            if activity.isGoal { continue }
            
            switch timeRange {
            case .weekly:
                if calendar.isDate(activity.date, equalTo: now, toGranularity: .weekOfYear) {
                    result.append(activity)
                }
            case .monthly:
                if calendar.isDate(activity.date, equalTo: now, toGranularity: .month) {
                    result.append(activity)
                }
            case .yearly:
                if calendar.isDate(activity.date, equalTo: now, toGranularity: .year) {
                    result.append(activity)
                }
            }
        }
        return result
    }
    
    // MARK: - Goal Helpers
    
    // Explain: Returns all goals that have been marked as completed
    private func completedGoals() -> [Activity] {
        var result: [Activity] = []
        for activity in activityStore.activities {
            if activity.isGoal && activity.isCompleted {
                result.append(activity)
            }
        }
        return result
    }
    
    private var aggregateStats: (duration: Int, distance: Double, points: Int) {
        let activities = filteredActivities()
        var totalDuration: Double = 0
        var totalDistance: Double = 0
        var totalPoints: Int = 0
        
        for activity in activities {
            totalDuration += activity.duration
            totalDistance += activity.distance
            // Points calculation: 2s (FG - 3s) * 2 + 3s * 3 + FT * 1
            let twos = activity.fg - activity.threes
            totalPoints += (twos * 2) + (activity.threes * 3) + activity.ft
        }
        
        return (Int(totalDuration), totalDistance, totalPoints)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // SECTION 1: Time Range Picker & Summary
                Section {
                    VStack(spacing: 20) {
                        Picker("Time Range", selection: $timeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        // Explain: Button to open the separate Goals History view
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
                
                // SECTION 2: Activity List (History)
                Section(header: Text("Activity Records")) {
                    if activityStore.activities.isEmpty {
                        Text("No activities recorded yet.")
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                    } else {
                        ForEach(activityStore.activities.reversed()) { activity in
                            // We only show non-goals in the general activity records
                            if !activity.isGoal {
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
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats & Records")
            .sheet(isPresented: $showGoalHistory) {
                GoalHistoryView(goals: completedGoals())
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let reversedActivities = activityStore.activities.reversed()
        for index in offsets {
            let activityToDelete = Array(reversedActivities)[index]
            activityStore.deleteActivity(activityToDelete)
        }
    }
}

// MARK: - Goal History Side View
// Explain: A dedicated view for browsing finished goals and their notes
struct GoalHistoryView: View {
    @Environment(\.dismiss) var dismiss
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

// MARK: - Sub-components

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

#Preview {
    StatsView()
        .environment(ActivityStore())
}
