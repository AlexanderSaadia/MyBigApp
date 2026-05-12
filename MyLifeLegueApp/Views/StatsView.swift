import SwiftUI

// This is the main "Stats & Records" dashboard.
// It shows high-level summaries and a list of all activities.
struct StatsView: View {
    @Environment(ActivityStore.self) private var activityStore
    @State private var timeRange: TimeRange = .weekly
    
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
                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                ActivityRecordRow(activity: activity)
                                    .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                    .listRowSeparator(.hidden)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Stats & Records")
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
