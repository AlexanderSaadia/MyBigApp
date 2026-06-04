import Foundation

// MARK: - Push-Up Entry Model
// Defines a single session of push-ups.
struct PushUpEntry: Identifiable, Codable {
    // Unique identifier for the entry.
    var id = UUID()
    
    // The number of push-ups performed.
    var count: Int
    
    // The exact date and time the session was logged.
    var timestamp: Date
}
