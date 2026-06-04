import Foundation
import Observation

// MARK: - ActivityStore ViewModel
// This class manages the entire list of activities and goals for the application.
// It uses the @Observable macro so that any SwiftUI view using it will update automatically.
@Observable
class ActivityStore {
    
    // MARK: - Properties
    
    // The master source of truth for all activities.
    // Every time this array changes, SwiftUI will refresh the relevant views.
    var activities: [Activity] = []
    
    // MARK: - Initializer
    
    init() {
        // We load sample data to ensure the app doesn't look empty on first launch.
        self.activities = [
            Activity(name: "Basketball Training", date: Date(), symbol: "basketball.fill", duration: 60, effort: 80, distance: 3.5, fg: "12/20", threes: "4/10", rebounds: "5", assists: "8", steals: "2", blocks: "1", ft: "5/6", extra: "Focused on shooting form", isCompleted: true),
            Activity(name: "Game Day", date: Date(), symbol: "figure.basketball", duration: 40, effort: 95, distance: 4.2, fg: "15/30", threes: "2/8", rebounds: "10", assists: "5", steals: "3", blocks: "2", ft: "4/4", extra: "Double-double!", isCompleted: false)
        ]
        
        // We clean up any uncompleted activities from past days to keep the list relevant.
        cleanupOldUncompletedActivities()
    }
    
    // MARK: - Methods
    
    // Removes activities that were planned for the past but never marked as completed.
    func cleanupOldUncompletedActivities() {
        // Get the current calendar and today's start time (midnight).
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // A temporary array to hold the activities we want to keep.
        var keptActivities: [Activity] = []
        for activity in activities {
            // Get the start of the day for the activity's date.
            let activityDate = calendar.startOfDay(for: activity.date)
            
            // We keep the activity if it's for today/future, or if it was already finished.
            if activityDate >= today || activity.isCompleted {
                keptActivities.append(activity)
            }
        }
        // Update the main list with our filtered results.
        self.activities = keptActivities
    }
    
    // Appends a new activity or goal to our central list.
    func addActivity(_ activity: Activity) {
        activities.append(activity)
    }
    
    // Switches the completion status of a specific activity.
    func toggleCompletion(for activity: Activity) {
        // Find the specific activity in our array by its unique ID.
        for index in 0..<activities.count {
            if activities[index].id == activity.id {
                // Flip the boolean value (true to false, or false to true).
                activities[index].isCompleted.toggle()
                break
            }
        }
    }
    
    // Marks an activity as finished with a note and optional photo data.
    func completeActivity(_ activity: Activity, note: String = "", imageData: Data? = nil) {
        for index in 0..<activities.count {
            if activities[index].id == activity.id {
                // Set the completion state and store the provided note/image.
                activities[index].isCompleted = true
                activities[index].completionNote = note
                activities[index].imageData = imageData
                break
            }
        }
    }
    
    // A comprehensive update function that saves all statistics and marks the activity as done.
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
        for index in 0..<activities.count {
            if activities[index].id == activity.id {
                // Apply all the new values from the completion form.
                activities[index].isCompleted = true
                activities[index].duration = duration
                activities[index].effort = effort
                activities[index].fg = fg
                activities[index].threes = threes
                activities[index].ft = ft
                activities[index].rebounds = rebounds
                activities[index].assists = assists
                activities[index].steals = steals
                activities[index].blocks = blocks
                activities[index].completionNote = note
                activities[index].imageData = imageData
                break
            }
        }
    }
    
    // Permanent deletion of an activity from the store.
    func deleteActivity(_ activity: Activity) {
        // We find the index of the item that matches the ID.
        var indexToRemove: Int?
        for index in 0..<activities.count {
            if activities[index].id == activity.id {
                indexToRemove = index
                break
            }
        }
        
        // If we found it, remove it from the array.
        if let index = indexToRemove {
            activities.remove(at: index)
        }
    }
    
    // Returns a filtered list of activities that occur on the specified calendar day.
    func activities(for date: Date) -> [Activity] {
        var result: [Activity] = []
        let calendar = Calendar.current
        
        for activity in activities {
            // Check if the activity date falls on the same day as the input date.
            if calendar.isDate(activity.date, inSameDayAs: date) {
                result.append(activity)
            }
        }
        return result
    }
}
