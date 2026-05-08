//
//  ActivityStore.swift
//  MyBigApp
//
//  Created by Gemini CLI on 08/05/26.
//

import Foundation
import Observation

@Observable
class ActivityStore {
    // MARK: - Stored properties
    var activities: [Activity] = []
    
    // MARK: - Initializer
    init() {
        // Load some sample data for preview/demo purposes if needed
        self.activities = [
            Activity(name: "Running", date: Date(), symbol: "figure.run"),
            Activity(name: "Studying", date: Date(), symbol: "book.fill")
        ]
    }
    
    // MARK: - Functions
    func addActivity(_ activity: Activity) {
        activities.append(activity)
    }
    
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
