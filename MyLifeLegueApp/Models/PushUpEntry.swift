import Foundation
import SwiftData

// MARK: - Push-Up Entry Model
// Defines a single session of push-ups.
// Added @Model so SwiftData can save this history permanently.
@Model
final class PushUpEntry: Identifiable {
    // A unique identifier for every set of push-ups logged.
    @Attribute(.unique) var id: UUID = UUID()
    
    // --- INPUT FIELDS ---
    
    // The number of push-ups performed (User Input).
    var count: Int
    
    // The exact date and time the session was logged (Automatic Input).
    var timestamp: Date
    
    // MARK: - Initializer
    // DATA FLOW: Used to create a new record when the user taps "Log Session".
    init(count: Int, timestamp: Date) {
        self.count = count
        self.timestamp = timestamp
    }
}
