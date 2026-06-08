import SwiftUI
import SwiftData

// MARK: - Stats & Records View
// This view provides a high-level overview of practice data and goal history.
struct StatsView: View {
    
    // MARK: - Environment & State
    
    // Access the shared activity data.
    @Environment(ActivityStore.self) private var activityStore
    
    // --- INPUT: Segmented filter choice ---
    @State private var timeRange: TimeRange = .weekly
    
    // --- INPUT: Toggle for sheet ---
    @State private var showGoalHistory = false
    
    // --- ARRAY: Definition of options ---
    enum TimeRange: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    // MARK: - Computed Properties
    
    // --- ARRAY FILTERING: Creates a sub-collection based on time ---
    private func filteredActivities() -> [Activity] {
        let calendar = Calendar.current
        let now = Date()
        var result: [Activity] = []
        
        // --- ARRAY ITERATION ---
        // Filters the master list from activityStore.
        for activity in activityStore.activities {
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
    
    // --- ARRAY FILTERING: Finds finished goals ---
    private func completedGoals() -> [Activity] {
        var result: [Activity] = []
        // --- ARRAY ITERATION ---
        for activity in activityStore.activities {
            if activity.isGoal && activity.isCompleted {
                result.append(activity)
            }
        }
        return result
    }
    
    // --- OUTPUT CALCULATION: Sums up stats from an array ---
    private var aggregateStats: (duration: Int, distance: Double, points: Int) {
        let activities = filteredActivities()
        var totalDuration: Double = 0
        var totalDistance: Double = 0
        var totalPoints: Int = 0
        
        // --- ARRAY ITERATION ---
        for activity in activities {
            totalDuration += activity.duration
            totalDistance += activity.distance
            
            // DATA FLOW: Calls a math helper to parse strings into integers.
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
                        // --- INPUT: Segmented Picker ---
                        Picker("Time Range", selection: $timeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        
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
                        
                        // --- OUTPUT: Summary cards showing calculated totals ---
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
                        // OUTPUT: Empty state.
                        Text("No activities recorded yet.")
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                    } else {
                        // --- ARRAY ITERATION (UI) ---
                        // DATA FLOW: Shows the master list in reverse order (newest first).
                        ForEach(activityStore.activities.reversed()) { activity in
                            if !activity.isGoal {
                                // OUTPUT: Navigation link to details.
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
                        // --- INPUT: Swipe to delete ---
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats & Records")
            // OUTPUT: Sheet showing goal history collection.
            .sheet(isPresented: $showGoalHistory) {
                GoalHistoryView(goals: completedGoals())
            }
        }
    }
    
    // MARK: - Functions
    
    // --- DATA FLOW: Deletes an item from the database based on its array index ---
    private func deleteItems(at offsets: IndexSet) {
        let reversedActivities = activityStore.activities.reversed()
        for index in offsets {
            let activityToDelete = Array(reversedActivities)[index]
            activityStore.deleteActivity(activityToDelete)
        }
    }
}

// MARK: - Goal History Sheet
struct GoalHistoryView: View {
    @Environment(\.dismiss) var dismiss
    // --- ARRAY: Passed in from parent ---
    let goals: [Activity]
    
    var body: some View {
        NavigationStack {
            List {
                if goals.isEmpty {
                    // OUTPUT: Empty state.
                    Text("No goals completed yet.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    // --- ARRAY ITERATION (UI) ---
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
                                // OUTPUT: Goal completion note.
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
        // OUTPUT: Specialized stat card.
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
        .environment(ActivityStore.preview)
        .modelContainer(ActivityStore.previewContainer)
}
