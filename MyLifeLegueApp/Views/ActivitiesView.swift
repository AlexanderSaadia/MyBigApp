import SwiftUI

// This view shows a vertical list of every activity the user has ever added.
struct ActivitiesView: View {
    // MARK: - Stored properties
    
    // Access the shared store so we can display the actual data
    @Environment(ActivityStore.self) private var activityStore
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Text ("Activities")
                    .font(.system(size: 21.0, weight: .regular, design: .default))
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 15) {
                    // We show the latest activities first
                    let reversedActivities = activityStore.activities.reversed()
                    
                    if activityStore.activities.isEmpty {
                        Text("No activities recorded yet.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(Array(reversedActivities)) { activity in
                            // Tapping an activity now takes you to the detailed "Cool Design" page
                            NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                ActivityRecordRow(activity: activity)
                            }
                            .buttonStyle(.plain) // Keep the row looking clean
                        }
                    }
                }
                .padding()
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // This button is decorative here as the back action 
                        // is actually handled by 'showActivity' in PickerView.
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
    }
}

#Preview {
    ActivitiesView()
        .environment(ActivityStore())
}
