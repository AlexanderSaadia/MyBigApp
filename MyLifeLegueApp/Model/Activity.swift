import Foundation

// The Activity struct is our "Data Model". 
// It defines what a single activity is and what information it must contain.
struct Activity: Identifiable, Codable {
    // Identifiable: Allows SwiftUI to distinguish between different activities.
    var id = UUID()
    
    // Basic Info
    var name: String
    var date: Date
    var symbol: String
    var notes: String = ""
    
    // --- STATISTICS FIELDS ---
    // We add these fields so we can "measure" our progress.
    
    // How long the activity took (in minutes)
    var duration: Double = 0
    
    var effort: Int = 0
    var distance: Double = 0
    var fg: Int = 0
    var threes: Int = 0
    var rebounds: Int = 0
    var assists: Int = 0
    var steals: Int = 0
    var blocks: Int = 0
    var ft: Int = 0
    var extra: String = ""
    
    // Tracks if the activity was confirmed by the user
    var isCompleted: Bool = false
}
