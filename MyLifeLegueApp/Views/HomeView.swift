import SwiftUI

// The main dashboard of the application
struct HomeView: View {
    // MARK: - Stored properties
    
    // Access the shared store so we can display real data
    @Environment(ActivityStore.self) private var activityStore
    
    // Tracks the selected segment in the goals area
    @State private var selection = 1
    
    // MARK: - Functions
    
    func completedCount() -> Int {
        var total = 0
        for activity in activityStore.activities {
            if activity.isCompleted {
                total += 1
            }
        }
        return total
    }
    
    func todayActivities() -> [Activity] {
        var result: [Activity] = []
        let calendar = Calendar.current
        let today = Date()
        
        for activity in activityStore.activities {
            if calendar.isDate(activity.date, inSameDayAs: today) {
                result.append(activity)
            }
        }
        return result
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView { 
            VStack(spacing: 20) {
                
                // USER PROFILE SECTION
                // Displays the user's avatar and name at the top
                HStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.2) )
                        .frame(width: 50, height: 50)
                    
                    Text("Alexander Saadia")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // DASHBOARD STATS SECTION
                // A visual summary of the user's progress
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                        .frame(height: 160)
                    
                    VStack {
                        HStack {
                            Text("Activities Completed")
                                .fontWeight(.bold)
                            Spacer()
                            Text("View Stats")
                                .font(.caption)
                        }
                        Spacer()
                        // Placeholder for a progress chart
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 8)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Text("\(completedCount())")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                    }
                    .padding()
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // TODAY'S TASKS SECTION
                // A quick-look list of what needs to be done today
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Activities")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    let todaysItems = todayActivities()
                    
                    if todaysItems.isEmpty {
                        Text("No activities added for today yet.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        ForEach(todaysItems) { activity in
                            MainActivityView(activity: activity) {
                                activityStore.toggleCompletion(for: activity)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // GOALS TRACKING SECTION
                // Allows users to track long-term targets
                VStack(alignment: .leading, spacing: 10) {
                    Text("Goals")
                        .font(.headline)
                    
                    // Simple Box for goals
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.yellow)
                            .frame(height: 120)
                        
                        VStack {
                            Text("Active Goals")
                                .fontWeight(.bold)
                            Text("Your personalized targets will appear here.")
                                .font(.caption)
                                .italic()
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

// Sub-component for individual task rows on the home screen
struct MainActivityView: View {
    let activity: Activity
    var onConfirm: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(activity.name)
                    .fontWeight(.semibold)
                Text(activity.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if activity.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            } else {
                Button(action: onConfirm) {
                    Text("Confirm")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    PickerView()
        .environment(ActivityStore())
}
