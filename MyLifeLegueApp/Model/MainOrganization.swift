import SwiftUI

struct PickerView: View {
    // MARK: - Stored properties
    
    // tracks whether we are showing the detailed "Push-Ups" list or the "Home" view dashboard
    // Explain: Replaced 'showActivity' logic with 'showPushUps' for the new primary alternate view
    @State private var showPushUps = false
    
    // tracks which tab is currently selected (1=Home, 2=Calendar, etc.)
    @State private var selectedTab = 1
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            // TabView provides the bottom navigation bar
            TabView(selection: $selectedTab) {
                
                // TAB 1: Home Dashboard or Push-Ups Timeline
                // Explain: Completely replaced ActivitiesView with PushUpsView as requested
                Group {
                    if showPushUps {
                        PushUpsView()
                    } else {
                        HomeView()
                    }
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(1)
                
                // TAB 2: The Multi-Mode Calendar
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
                
                // TAB 5: Stats & History
                StatsView()
                    .tabItem { 
                        Image(systemName: "chart.bar.xaxis") 
                        Text("Stats")
                    }
                    .tag(5)
            }
            // Title updates based on tab
            .navigationTitle(selectedTab == 1 ? "Life League" : "")
            
            // The toolbar is shared across the NavigationStack
            .toolbar {
                // We only show the "Push-Ups/Back" toggle if we are on the Home tab (tag 1)
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedTab == 1 {
                        Button(showPushUps ? "Back" : "Push-Ups") {
                            // Toggling this state causes the 'Group' in Tab 1 to switch views
                            showPushUps.toggle()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PickerView()
        .environment(ActivityStore())
}
