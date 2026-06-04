import Foundation

// The Activity struct is our "Data Model". 
// It defines what a single activity is and what information it must contain.
struct Activity: Identifiable, Codable, Equatable {
    // Identifiable: Allows SwiftUI to distinguish between different activities.
    var id = UUID()
    
    // Basic Info
    var name: String
    var date: Date
    var symbol: String
    
    // --- STATISTICS FIELDS ---
    // We add these fields so we can "measure" our progress.
    
    // How long the activity took (in minutes)
    var duration: Double = 0
    
    var effort: Int = 0
    var distance: Double = 0
    
    // Changed to String to support fractional entries like "3/9"
    var fg: String = "0"
    var threes: String = "0"
    var rebounds: String = "0"
    var assists: String = "0"
    var steals: String = "0"
    var blocks: String = "0"
    var ft: String = "0"
    
    var extra: String = ""
    
    // Tracks if the activity was confirmed by the user
    var isCompleted: Bool = false
    
    // Tracks if this activity is a long-term goal
    var isGoal: Bool = false
    
    // NEW: Optional image data for activity
    var imageData: Data? = nil
    
    // NEW: Optional note added when the user completes a goal
    var completionNote: String = ""
}
