import SwiftUI

// The main dashboard of the application
struct HomeView: View {
    // Tracks the selected segment in the goals area
    @State private var selection = 1
    
    var body: some View {
        ScrollView { 
            VStack(spacing: 20) {
                
                // USER PROFILE SECTION
                // Displays the user's avatar and name at the top
                HStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
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
                    
                    MainActivityView(activity: "Running", checkmark: true)
                    MainActivityView(activity: "Basketball", checkmark: true)
                    MainActivityView(activity: "Meditating", checkmark: false)
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
    let activity: String
    let checkmark: Bool
    
    var body: some View {
        HStack {
            Text(activity)
            Spacer()
            // Displays a filled checkmark if completed, or an empty circle if not
            Image(systemName: checkmark ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(checkmark ? .green : .secondary)
                .font(.title2)
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
