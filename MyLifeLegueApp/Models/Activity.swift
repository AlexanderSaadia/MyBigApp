import Foundation

// MARK: - Activity Model
// This defines the structure of a single "Activity" in our app.
// It conforms to Identifiable (so it can be used in Lists) and Codable (for potential saving/loading).
struct Activity: Identifiable, Codable, Equatable {
    // A unique identifier for every activity created, so SwiftUI knows which is which.
    var id = UUID()
    
    // The display name of the activity (e.g., "Morning Practice").
    var name: String
    
    // The date and time when the activity is scheduled or happened.
    var date: Date
    
    // An SF Symbol name used to represent this activity visually (e.g., "basketball.fill").
    var symbol: String
    
    // --- STATISTICS FIELDS ---
    
    // The total time spent on the activity in minutes.
    var duration: Double = 0
    
    // A percentage value (0-100) representing how hard the user worked.
    var effort: Int = 0
    
    // The physical distance covered during the activity in kilometers.
    var distance: Double = 0
    
    // Field Goals: Stored as a string to allow formats like "5/10" or just "5".
    var fg: String = "0"
    
    // Three-pointers: Stored as a string to allow fractional tracking.
    var threes: String = "0"
    
    // Rebounds grabbed during the session.
    var rebounds: String = "0"
    
    // Assists made during the session.
    var assists: String = "0"
    
    // Steals recorded during the session.
    var steals: String = "0"
    
    // Blocks recorded during the session.
    var blocks: String = "0"
    
    // Free Throws: Stored as a string to allow fractional tracking.
    var ft: String = "0"
    
    // Any extra text details or thoughts added when the activity was first created.
    var extra: String = ""
    
    // A boolean flag that tracks if the user has confirmed this activity as finished.
    var isCompleted: Bool = false
    
    // A boolean flag that marks this activity as a long-term goal rather than a single session.
    var isGoal: Bool = false
    
    // Optional binary data for an image selected from the photo library.
    var imageData: Data? = nil
    
    // A separate note added specifically during the completion phase of an activity.
    var completionNote: String = ""
}
