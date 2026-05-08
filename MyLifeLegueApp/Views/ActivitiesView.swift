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
                VStack(spacing: 10) {
                    // We iterate through every activity in our master store
                    ForEach(activityStore.activities) { activity in
                        // Reusing the ActivityView sub-component for each row
                        ActivityView(activity: activity.name, 
                                     timesWeekly: "Added on " + activity.date.formatted(date: .abbreviated, time: .omitted), 
                                     percentage: "", 
                                     symbol: activity.symbol)
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

// Sub-component that defines the look of a single activity row
struct ActivityView: View {
    
    let activity: String
    let timesWeekly: String
    let percentage: String
    let symbol: String
    
    var body: some View {
        
        Rectangle()
            .fill(.gray)
            .overlay {
                
                HStack {
                    
                    Image(systemName: symbol)
                        .font(.system(size: 25.0))
                    
                    VStack(alignment: .leading){
                        Text(activity)
                            .font(.system(size: 25.0, weight: .semibold, design: .default))
                        Text(timesWeekly)
                    }
                    
                    Spacer()
                    
                    Text(percentage)
                        .foregroundStyle(.green)
                }
                .padding(8)
            }
            // Fix height so they don't grow too large
            .frame(height: 80)
    }
}

#Preview {
    ActivitiesView()
        .environment(ActivityStore())
}
