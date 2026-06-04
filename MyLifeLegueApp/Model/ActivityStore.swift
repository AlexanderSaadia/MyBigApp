//
//  ActivityStore.swift
//  MyBigApp
//
//  Created by Gemini CLI on 08/05/26.
//

import Foundation
import Observation

// ActivityStore is our "State Manager". 
// It is the central place where all activities are kept while the app is running.
@Observable
class ActivityStore {
    // MARK: - Stored properties
    
    // The master list of all activities created by the user.
    // Because this class is @Observable, any view using this array will 
    // automatically refresh when items are added or removed.
    var activities: [Activity] = []
    
    // MARK: - Initializer
    init() {
        // Load some sample data so the app doesn't look empty when first opened.
        // In a real app, this might load from a database or file.
        self.activities = [
            Activity(name: "Basketball Training", date: Date(), symbol: "basketball.fill", duration: 60, effort: 80, distance: 3.5, fg: "12/20", threes: "4/10", rebounds: "5", assists: "8", steals: "2", blocks: "1", ft: "5/6", extra: "Focused on shooting form", isCompleted: true),
            Activity(name: "Game Day", date: Date(), symbol: "figure.basketball", duration: 40, effort: 95, distance: 4.2, fg: "15/30", threes: "2/8", rebounds: "10", assists: "5", steals: "3", blocks: "2", ft: "4/4", extra: "Double-double!", isCompleted: false)
        ]
        
        // Clean up any uncompleted activities from past days
        cleanupOldUncompletedActivities()
    }
    
    // MARK: - Functions
    
    // Automatically deletes activities that were planned for yesterday or earlier
    // but were never marked as "completed".
    func cleanupOldUncompletedActivities() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var keptActivities: [Activity] = []
        for activity in activities {
            let activityDate = calendar.startOfDay(for: activity.date)
            
            // We keep it if:
            // 1. It is for today (or future)
            // 2. OR it was already completed
            if activityDate >= today || activity.isCompleted {
                keptActivities.append(activity)
            }
        }
        self.activities = keptActivities
    }
    
    // Adds a new activity to our master list.
    func addActivity(_ activity: Activity) {
        activities.append(activity)
    }
    
    // Changes the completion status of an activity
    func toggleCompletion(for activity: Activity) {
        for index in 0..<activities.count {
            if activities[index].id == activity.id {
                activities[index].isCompleted.toggle()
                break
            }
        }
    }
    
    // NEW: Completes an activity with an optional note and image
    // Explain: Allows users to record a specific note and photo when finishing a goal or task
    func completeActivity(_ activity: Activity, note: String = "", imageData: Data? = nil) {
        for index in 0..<activities.count {
            if activities[index].id == activity.id {
                activities[index].isCompleted = true
                activities[index].completionNote = note
                activities[index].imageData = imageData
                break
            }
        }
    }
    
    // NEW: Completes an activity with all updated statistics
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
    
    // Removes an activity from our master list.
    func deleteActivity(_ activity: Activity) {
        var indexToRemove: Int?
        for index in 0..<activities.count {
            if activities[index].id == activity.id {
                indexToRemove = index
                break
            }
        }
        
        if let index = indexToRemove {
            activities.remove(at: index)
        }
    }
    
    // Helper function used by the Calendar: 
    // It filters the master list to find only activities that happened on a specific day.
    func activities(for date: Date) -> [Activity] {
        var result: [Activity] = []
        let calendar = Calendar.current
        
        // We iterate through every activity and check if the 'day/month/year' matches the requested date.
        for activity in activities {
            if calendar.isDate(activity.date, inSameDayAs: date) {
                result.append(activity)
            }
        }
        return result
    }
}
