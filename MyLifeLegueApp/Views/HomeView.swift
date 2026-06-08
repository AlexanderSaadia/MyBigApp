import SwiftUI
import SwiftData

// MARK: - Home Dashboard View
// This is the primary landing page of the app, showing progress, today's tasks, and active goals.
struct HomeView: View {
    
    // MARK: - Environment & State
    
    // Access the shared data store that was injected at the app level.
    @Environment(ActivityStore.self) private var activityStore
    
    // --- INPUT: Toggles between views ---
    @State private var showPushUps = false
    
    // --- INPUT: Form fields for creating a Goal ---
    @State private var newGoalName: String = ""
    @State private var goalTargetDate: Date = Date()
    
    // --- INPUT: Tracks which activity is selected for completion ---
    @State private var selectedActivity: Activity?
    
    // MARK: - Functions
    
    // --- DATA FLOW: Decides whether to show a sheet or finish an activity immediately ---
    private func handleConfirm(for activity: Activity) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let activityDate = calendar.startOfDay(for: activity.date)
        
        if activityDate >= today {
            // OUTPUT: Triggers a pop-up sheet.
            selectedActivity = activity
        } else {
            // INPUT -> STORE: Sends command to finalize data.
            activityStore.completeActivity(activity)
        }
    }
    
    // --- ARRAY FILTERING: Finds in-progress goals ---
    func activeGoals() -> [Activity] {
        var result: [Activity] = []
        // --- ARRAY ITERATION ---
        for activity in activityStore.activities {
            if activity.isGoal && !activity.isCompleted {
                result.append(activity)
            }
        }
        return result
    }
    
    // --- OUTPUT: A single calculated number ---
    func completedCount() -> Int {
        var total = 0
        // --- ARRAY ITERATION ---
        for activity in activityStore.activities {
            if activity.isCompleted {
                total += 1
            }
        }
        return total
    }
    
    // --- ARRAY FILTERING: Gets items for "Today" ---
    func todayActivities() -> [Activity] {
        var result: [Activity] = []
        let calendar = Calendar.current
        let today = Date()
        
        // --- ARRAY ITERATION ---
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
                    // OUTPUT: Specialized Push-Ups view.
                    PushUpsView()
                } else {
                    // OUTPUT: Main Dashboard.
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
            // OUTPUT: The completion form as a pop-up sheet.
            .sheet(item: $selectedActivity) { activity in
                CompleteActivityView(activity: activity)
            }
        }
    }
    
    // MARK: - Dashboard Content
    
    private var homeContent: some View {
        ScrollView { 
            VStack(spacing: 20) {
                
                // OUTPUT: User profile header.
                HStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.2) )
                        .frame(width: 50, height: 50)
                    Text("Alexander Saadia")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                
                // OUTPUT: Big blue card showing the "completedCount" array calculation.
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
                
                // OUTPUT LIST: Today's activities.
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
                        // --- ARRAY ITERATION (UI) ---
                        // Loops through today's filtered array to create visual cards.
                        ForEach(todaysItems) { activity in
                            MainActivityView(activity: activity) {
                                handleConfirm(for: activity)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // GOALS SECTION
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Goals")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    // --- INPUT FORM: Creates new data ---
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("Goal name...", text: $newGoalName)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                            Button(action: {
                                // DATA FLOW: Creates an object and sends it to the store.
                                let newGoal = Activity(
                                    name: newGoalName,
                                    date: goalTargetDate,
                                    symbol: "target",
                                    isGoal: true
                                )
                                activityStore.addActivity(newGoal)
                                // Reset inputs.
                                newGoalName = ""
                                goalTargetDate = Date()
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            .disabled(newGoalName.isEmpty)
                        }
                        // --- INPUT: Date Picker ---
                        DatePicker("Target Time:", selection: $goalTargetDate, displayedComponents: [.date, .hourAndMinute])
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(12)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(12)
                    
                    // OUTPUT LIST: Active goals.
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
                        // --- ARRAY ITERATION (UI) ---
                        // Loops through the active goals array to show them on the home screen.
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
struct MainActivityView: View {
    let activity: Activity
    var onConfirm: () -> Void
    
    var body: some View {
        // OUTPUT: Visual row for a single item in an array.
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

// MARK: - Preview
#Preview {
    HomeView()
        .environment(ActivityStore.preview)
        .modelContainer(ActivityStore.previewContainer)
}
