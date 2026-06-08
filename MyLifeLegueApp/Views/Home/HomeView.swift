import SwiftUI
import SwiftData

// MARK: - Home Dashboard View
// This is the primary landing page of the app, showing progress, today's tasks, and active goals.
struct HomeView: View {
    
    // MARK: - Environment & State
    
    // Access the shared data store that was injected at the app level.
    @Environment(ActivityStore.self) private var activityStore
    
    // Tracks if we are showing the "Push-Ups" list instead of the home content.
    @State private var showPushUps = false
    
    // Input state for creating a new goal.
    @State private var newGoalName: String = ""
    @State private var goalTargetDate: Date = Date()
    
    // Tracks which activity is currently being finished, so we can pass it to the sheet.
    @State private var selectedActivity: Activity?
    
    // MARK: - Functions
    
    // Logic to determine what happens when a "Confirm" button is clicked.
    private func handleConfirm(for activity: Activity) {
        let calendar = Calendar.current
        // Strip the time from today and the activity date to compare just the calendar day.
        let today = calendar.startOfDay(for: Date())
        let activityDate = calendar.startOfDay(for: activity.date)
        
        if activityDate >= today {
            // If the activity is today or in the future, we show the full recording sheet.
            selectedActivity = activity
        } else {
            // If the activity is from the past, we mark it done immediately with 0 stats.
            activityStore.completeActivity(activity)
        }
    }
    
    // Helper to find goals that are still in progress.
    func activeGoals() -> [Activity] {
        var result: [Activity] = []
        for activity in activityStore.activities {
            if activity.isGoal && !activity.isCompleted {
                result.append(activity)
            }
        }
        return result
    }
    
    // Count how many activities the user has ever finished.
    func completedCount() -> Int {
        var total = 0
        for activity in activityStore.activities {
            if activity.isCompleted {
                total += 1
            }
        }
        return total
    }
    
    // Get all activities scheduled for the current calendar day.
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
                    // Switch to the push-ups timeline if the toggle is active.
                    PushUpsView()
                } else {
                    // Show the standard dashboard.
                    homeContent
                }
            }
            // Update the navigation bar title based on what we are showing.
            .navigationTitle(showPushUps ? "Push-Ups" : "Life League")
            .toolbar {
                // Top-right button to toggle between Home and Push-Ups.
                ToolbarItem(placement: .topBarTrailing) {
                    Button(showPushUps ? "Back" : "Push-Ups") {
                        showPushUps.toggle()
                    }
                }
            }
            // Displays the completion form as a pop-up sheet when an activity is selected.
            .sheet(item: $selectedActivity) { activity in
                CompleteActivityView(activity: activity)
            }
        }
    }
    
    // MARK: - Dashboard Content
    
    private var homeContent: some View {
        ScrollView { 
            VStack(spacing: 20) {
                
                // USER PROFILE: Simple header with name and avatar.
                HStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.2) )
                        .frame(width: 50, height: 50)
                    Text("Alexander Saadia")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                
                // STATS OVERVIEW: A big blue card showing total completions.
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
                
                // TODAY'S LIST: Shows what is planned for right now.
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Activities")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    let todaysItems = todayActivities()
                    if todaysItems.isEmpty {
                        // Empty state if nothing is planned.
                        Text("No activities added for today yet.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(10)
                    } else {
                        // List every item using the MainActivityView component.
                        ForEach(todaysItems) { activity in
                            MainActivityView(activity: activity) {
                                // Trigger the confirmation logic when clicked.
                                handleConfirm(for: activity)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // GOALS SECTION: Allows quick entry of new long-term targets.
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Goals")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    // Input form for a new goal.
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("Goal name...", text: $newGoalName)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                            Button(action: {
                                // Create and add the goal.
                                let newGoal = Activity(
                                    name: newGoalName,
                                    date: goalTargetDate,
                                    symbol: "target",
                                    isGoal: true
                                )
                                activityStore.addActivity(newGoal)
                                // Clear the form.
                                newGoalName = ""
                                goalTargetDate = Date()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            .disabled(newGoalName.isEmpty)
                        }
                        // Date picker for the goal's deadline.
                        DatePicker("Target Time:", selection: $goalTargetDate, displayedComponents: [.date, .hourAndMinute])
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(12)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                    
                    // List of current active goals.
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

// MARK: - Main Activity Row Component
// A smaller view used specifically on the Home dashboard for a single activity.
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
                // Show only the time for today's tasks.
                Text(activity.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            // Toggle between a checkmark and a confirm button based on completion status.
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

// MARK: - Preview
#Preview {
    // Create an in-memory container for the preview.
    let schema = Schema([Activity.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container: ModelContainer
    do {
        container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
    
    let store = ActivityStore()
    store.setContext(container.mainContext)
    
    return HomeView()
        .environment(store)
}
