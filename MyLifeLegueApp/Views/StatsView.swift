import SwiftUI

// This is the "Statistics Playground"
// It calculates and displays summaries of all the data in our ActivityStore.
struct StatsView: View {
    // Access our shared data
    @Environment(ActivityStore.self) private var activityStore
    
    // --- Computed Properties for Statistics ---
    // In Computer Science, this is called "Data Aggregation"
    
    var totalActivities: Int {
        return activityStore.activities.count
    }
    
    var totalDurationMinutes: Int {
        var total: Double = 0
        for activity in activityStore.activities {
            total += activity.duration
        }
        return Int(total)
    }
    
    var totalCalories: Int {
        var total: Int = 0
        for activity in activityStore.activities {
            total += activity.calories
        }
        return total
    }
    
    var averageQuality: Int {
        if activityStore.activities.isEmpty { return 0 }
        var total: Int = 0
        for activity in activityStore.activities {
            total += activity.qualityScore
        }
        return total / activityStore.activities.count
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // HEADER CARD
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: 150)
                        
                        VStack {
                            Text("Your Lifetime Stats")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(totalActivities)")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Activities Completed")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    
                    // STATS GRID
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        StatCard(title: "Total Time", value: "\(totalDurationMinutes)", unit: "mins", color: .orange)
                        StatCard(title: "Calories", value: "\(totalCalories)", unit: "kcal", color: .red)
                        StatCard(title: "Avg. Effort", value: "\(averageQuality)", unit: "%", color: .green)
                        StatCard(title: "Level", value: "\(totalActivities / 5 + 1)", unit: "Rank", color: .purple)
                    }
                    .padding(.horizontal)
                    
                    // INSIGHTS SECTION
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Weekly Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("You've spent \(totalDurationMinutes / 60) hours and \(totalDurationMinutes % 60) minutes improving yourself this week!")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Stats Playground")
        }
    }
}

// A reusable card component for individual stats
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    StatsView()
        .environment(ActivityStore())
}
