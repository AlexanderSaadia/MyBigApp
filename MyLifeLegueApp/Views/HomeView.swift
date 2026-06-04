import SwiftUI

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
    
    // State for completion note alert
    @State private var showNoteAlert = false
    @State private var selectedActivity: Activity?
    @State private var completionNote: String = ""
    
    // MARK: - Functions
    
    // Filters the master list to show only goals that are not yet finished
    func activeGoals() -> [Activity] {
        var result: [Activity] = []
        for activity in activityStore.activities {
            // We only include it if it's marked as a goal and is not completed
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
        }
    }
    
    private var homeContent: some View {
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
                        Spacer()
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
                                selectedActivity = activity
                                showNoteAlert = true
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // GOALS TRACKING SECTION
                // Allows users to track long-term targets
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Goals")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    // INPUT SECTION: For creating a new goal (RESIZED & RESTYLED)
                    // Explain: This section is now smaller, colored golden, and includes time selection
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            TextField("Goal name...", text: $newGoalName)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(8)
                            
                            Button(action: {
                                // Add the new goal to the store
                                let newGoal = Activity(
                                    name: newGoalName,
                                    date: goalTargetDate,
                                    symbol: "target",
                                    isGoal: true
                                )
                                activityStore.addActivity(newGoal)
                                
                                // Reset fields
                                newGoalName = ""
                                goalTargetDate = Date()
                            }) {
                                // Explain: "Add" button placed to the far right of the text field
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
                    .background(Color.yellow.opacity(0.2)) // Golden color background
                    .cornerRadius(12)
                    
                    // LIST SECTION: Shows all current goals
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
                                    // Explain: Trigger the note alert when completing a goal
                                    selectedActivity = goal
                                    showNoteAlert = true
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
        .alert("Complete Goal", isPresented: $showNoteAlert) {
            TextField("Write a little note...", text: $completionNote)
            Button("Cancel", role: .cancel) { completionNote = "" }
            Button("Confirm") {
                if let activity = selectedActivity {
                    activityStore.completeActivity(activity, note: completionNote)
                }
                completionNote = ""
            }
        } message: {
            Text("Would you like to add a note to this achievement?")
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
