import SwiftUI
import SwiftData

// MARK: - Main Tab View
// This view acts as the root container for the app's primary navigation.
// It sets up the bottom tab bar and switches between the main feature sections.
struct PickerView: View {
    
    // MARK: - State Properties
    
    // This state variable tracks which tab is currently being viewed by the user.
    // 1 = Home, 2 = Calendar, 3 = Add, 4 = Journal, 5 = Stats.
    @State private var selectedTab = 1
    
    // MARK: - Body
    
    var body: some View {
        // TabView is the standard SwiftUI component for a bottom navigation bar.
        TabView(selection: $selectedTab) {
            
            // TAB 1: Home Dashboard
            // We wrap each main view in its own NavigationStack to fix the navigation title issue.
            HomeView()
                .tabItem {
                    // The icon shown in the tab bar.
                    Image(systemName: "house.fill")
                    // The text label shown below the icon.
                    Text("Home")
                }
                // The tag identifies this specific tab for the $selectedTab binding.
                .tag(1)
            
            // TAB 2: Calendar Section
            CalendarView()
                .tabItem { 
                    Image(systemName: "calendar") 
                    Text("Calendar")
                }
                .tag(2)
            
            // TAB 3: Add New Activity Form
            AddActivityView()
                .tabItem { 
                    Image(systemName: "plus.circle.fill") 
                    Text("Add")
                }
                .tag(3)
            
            // TAB 4: Personal Journal
            JournalView()
                .tabItem { 
                    Image(systemName: "book.fill") 
                    Text("Journal")
                }
                .tag(4)
            
            // TAB 5: Statistics & History
            StatsView()
                .tabItem { 
                    Image(systemName: "chart.bar.xaxis") 
                    Text("Stats")
                }
                .tag(5)
        }
    }
}

// MARK: - Preview
#Preview {
    PickerView()
        .environment(ActivityStore.preview)
        .modelContainer(ActivityStore.previewContainer)
}
