import SwiftUI

// MARK: - App Entry Point
// This is the main structure that launches your application.
@main
struct Life_Legue_AppApp: App {
    
    // MARK: - State Management
    
    // We create a single instance of ActivityStore here at the top level.
    // This is the "Shared Store" that holds all your data while the app is running.
    @State private var activityStore = ActivityStore()
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            // We start by showing the PickerView, which contains our bottom tabs.
            PickerView()
                // We inject our activityStore into the "Environment".
                // This allows any view inside PickerView to access the data without needing to pass it manually.
                .environment(activityStore)
        }
    }
}
