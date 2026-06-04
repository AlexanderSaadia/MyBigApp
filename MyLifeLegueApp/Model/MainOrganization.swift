import SwiftUI

struct PickerView: View {
    // MARK: - Stored properties
    
    // tracks which tab is currently selected (1=Home, 2=Calendar, etc.)
    @State private var selectedTab = 1
    
    // MARK: - Body
    var body: some View {
        // TabView provides the bottom navigation bar
        TabView(selection: $selectedTab) {
            
            // TAB 1: Home Dashboard
            HomeView()
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
    }
}

#Preview {
    PickerView()
        .environment(ActivityStore())
}
