import SwiftUI
import SwiftData

// MARK: - App Entry Point
// This is the main structure that launches your application.
@main
struct Life_Legue_AppApp: App {
    
    // MARK: - State Management
    
    // Create the store instance.
    @State private var activityStore = ActivityStore()
    
    // Define the database container (the "disk storage") for our models.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Activity.self,
            PushUpEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            PickerView()
                .environment(activityStore)
                // Inject the SwiftData context into the store so it can save to disk.
                .onAppear {
                    activityStore.setContext(sharedModelContainer.mainContext)
                }
        }
        // Attach the model container to the app.
        .modelContainer(sharedModelContainer)
    }
}
