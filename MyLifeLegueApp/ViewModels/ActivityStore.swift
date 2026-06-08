import Foundation
import SwiftData
import Observation

// MARK: - ActivityStore ViewModel
// This class manages the entire list of activities and goals for the application.
// We updated it to sync with SwiftData so data is saved permanently.
@Observable
class ActivityStore {
    
    // MARK: - Properties
    
    // The SwiftData context used for saving and deleting.
    private var modelContext: ModelContext?
    
    // The master list of activities.
    // In this version, we keep it as a normal array for the views to read,
    // and we update it whenever the database changes.
    var activities: [Activity] = []
    
    // MARK: - Initializer
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        // If we have a context, fetch the existing data.
        if modelContext != nil {
            fetchActivities()
        }
    }
    
    // MARK: - Methods
    
    // Manual trigger to ensure the database writes to disk.
    func save() {
        guard let context = modelContext else { 
            print("Warning: Attempted to save with nil context.")
            return 
        }
        do {
            try context.save()
            // Update local array after save.
            let descriptor = FetchDescriptor<Activity>(sortBy: [SortDescriptor(\.date)])
            self.activities = try context.fetch(descriptor)
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // Connects the store to the app's database.
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchActivities()
        // Run cleanup once when the context is first connected.
        cleanupOldUncompletedActivities()
    }
    
    // Loads all activities from the SwiftData database into our local array.
    func fetchActivities() {
        guard let context = modelContext else { return }
        
        // Create a request to get all Activities.
        let descriptor = FetchDescriptor<Activity>(sortBy: [SortDescriptor(\.date)])
        
        do {
            // Update our local array with data from the database.
            self.activities = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch activities: \(error)")
        }
    }
    
    // Removes activities that were planned for the past but never marked as completed.
    func cleanupOldUncompletedActivities() {
        guard let context = modelContext else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var deletedAny = false
        for activity in activities {
            let activityDate = calendar.startOfDay(for: activity.date)
            
            // If it's old and not finished, delete it from the database.
            if activityDate < today && !activity.isCompleted {
                context.delete(activity)
                deletedAny = true
            }
        }
        
        // Only trigger a save if we actually deleted something.
        if deletedAny {
            save()
        }
    }
    
    // Saves a new activity to SwiftData.
    func addActivity(_ activity: Activity) {
        guard let context = modelContext else { 
            print("Error: Cannot add activity, context is nil.")
            // Fallback for preview/testing: add to local array so it shows up at least.
            self.activities.append(activity)
            return 
        }
        // Add to database.
        context.insert(activity)
        // Ensure it's saved to disk.
        save()
    }
    
    // Switches the completion status of a specific activity.
    func toggleCompletion(for activity: Activity) {
        activity.isCompleted.toggle()
        save()
    }
    
    // Marks an activity as finished with a note and optional photo data.
    func completeActivity(_ activity: Activity, note: String = "", imageData: Data? = nil) {
        activity.isCompleted = true
        activity.completionNote = note
        activity.imageData = imageData
        save()
    }
    
    // Saves all statistics and marks the activity as done.
    func updateAndCompleteActivity(
        _ activity: Activity, 
        duration: Double, 
        effort: Int, 
        fg: String, 
        threes: String, 
        ft: String, 
        rebounds: String, 
        assists: String, 
        steals: String, 
        blocks: String, 
        note: String, 
        imageData: Data?
    ) {
        activity.isCompleted = true
        activity.duration = duration
        activity.effort = effort
        activity.fg = fg
        activity.threes = threes
        activity.ft = ft
        activity.rebounds = rebounds
        activity.assists = assists
        activity.steals = steals
        activity.blocks = blocks
        activity.completionNote = note
        activity.imageData = imageData
        save()
    }
    
    // Permanent deletion from SwiftData.
    func deleteActivity(_ activity: Activity) {
        guard let context = modelContext else { return }
        context.delete(activity)
        save()
    }
    
    // Returns activities for a specific day.
    func activities(for date: Date) -> [Activity] {
        var result: [Activity] = []
        let calendar = Calendar.current
        for activity in activities {
            if calendar.isDate(activity.date, inSameDayAs: date) {
                result.append(activity)
            }
        }
        return result
    }
}
