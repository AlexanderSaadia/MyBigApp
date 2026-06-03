import SwiftUI

struct ActivitiesView: View {
    @Environment(ActivityStore.self) private var activityStore
    
    var body: some View {
        List {
            let regularActivities = activityStore.activities.filter { !$0.isGoal }
            
            if regularActivities.isEmpty {
                Text("No activities logged yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(regularActivities.reversed()) { activity in
                    HStack {
                        Image(systemName: activity.symbol)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading) {
                            Text(activity.name)
                                .fontWeight(.semibold)
                            Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if activity.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Activities")
    }
}

#Preview {
    ActivitiesView()
        .environment(ActivityStore())
}
