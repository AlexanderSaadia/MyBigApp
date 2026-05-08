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
    
    // An estimate of effort or energy (optional but good for stats)
    var calories: Int = 0
    
    // A general score or "XP" earned (1-100)
    var qualityScore: Int = 0
}
