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
            Activity(name: "Running", date: Date(), symbol: "figure.run"),
            Activity(name: "Studying", date: Date(), symbol: "book.fill")
        ]
    }
    
    // MARK: - Functions
    
    // Adds a new activity to our master list.
    func addActivity(_ activity: Activity) {
        activities.append(activity)
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
