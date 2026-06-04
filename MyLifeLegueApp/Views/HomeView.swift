import SwiftUI
import PhotosUI

// The main dashboard of the application
struct HomeView: View {
    // MARK: - Stored properties
    
    // Access the shared store so we can display real data
    @Environment(ActivityStore.self) private var activityStore
    
    // tracks whether we are showing the detailed "Push-Ups" list or the "Home" view dashboard
    @State private var showPushUps = false
    
    // Tracks the selected segment in the goals area
    @State private var selection = 1
    
    // New properties for goal creation
    @State private var newGoalName: String = ""
    @State private var goalTargetDate: Date = Date()
    
    // State for completion flow
    @State private var selectedActivity: Activity?
    
    // MARK: - Functions
    
    private func handleConfirm(for activity: Activity) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let activityDate = calendar.startOfDay(for: activity.date)
        
        if activityDate >= today {
            // Activity is today or in the future: show the detailed completion sheet
            selectedActivity = activity
        } else {
            // Activity is from a past day: complete automatically (no stats needed)
            activityStore.completeActivity(activity)
        }
    }
    
    // Filters the master list to show only goals that are not yet finished
    func activeGoals() -> [Activity] {
        var result: [Activity] = []
        for activity in activityStore.activities {
            if activity.isGoal && !activity.isCompleted {
                result.append(activity)
            }
        }
        return result
    }
    
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
        NavigationStack {
            Group {
                if showPushUps {
                    PushUpsView()
                } else {
                    homeContent
                }
            }
            .navigationTitle(showPushUps ? "Push-Ups" : "Life League")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(showPushUps ? "Back" : "Push-Ups") {
                        showPushUps.toggle()
                    }
                }
            }
            // Use .sheet(item:) for cleaner state management and automatic reset
            .sheet(item: $selectedActivity) { activity in
                CompleteActivityView(activity: activity)
            }
        }
    }
    
    private var homeContent: some View {
        ScrollView { 
            VStack(spacing: 20) {
                
                // USER PROFILE SECTION
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
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                        .frame(height: 160)
                    VStack {
                        HStack {
                            Text("Activities Completed")
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 8)
                            .frame(width: 60, height: 60)
                            .overlay {
                                Text("\(completedCount())")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        Spacer()
                    }
                    .padding()
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // TODAY'S TASKS SECTION
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
                                handleConfirm(for: activity)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // GOALS TRACKING SECTION
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Goals")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("Goal name...", text: $newGoalName)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                            Button(action: {
                                let newGoal = Activity(
                                    name: newGoalName,
                                    date: goalTargetDate,
                                    symbol: "target",
                                    isGoal: true
                                )
                                activityStore.addActivity(newGoal)
                                newGoalName = ""
                                goalTargetDate = Date()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            .disabled(newGoalName.isEmpty)
                        }
                        DatePicker("Target Time:", selection: $goalTargetDate, displayedComponents: [.date, .hourAndMinute])
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(12)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                    
                    let goals = activeGoals()
                    if goals.isEmpty {
                        Text("No active goals.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        ForEach(goals) { goal in
                            HStack {
                                Image(systemName: "target")
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading) {
                                    Text(goal.name)
                                        .fontWeight(.semibold)
                                    Text("Due: \(goal.date.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    handleConfirm(for: goal)
                                }) {
                                    Image(systemName: "circle")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(10)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
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
                HStack {
                    if activity.isGoal {
                        Image(systemName: "target")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                    Text(activity.name)
                        .fontWeight(.semibold)
                }
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
    HomeView()
        .environment(ActivityStore())
}
