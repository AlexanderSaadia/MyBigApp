import Foundation
import SwiftData

// MARK: - Push-Up Entry Model
// Defines a single session of push-ups.
// Added @Model so SwiftData can save this history permanently.
@Model
final class PushUpEntry: Identifiable {
    // Unique identifier for the entry.
    @Attribute(.unique) var id: UUID = UUID()
    
    // The number of push-ups performed.
    var count: Int
    
    // The exact date and time the session was logged.
    var timestamp: Date
    
    // MARK: - Initializer
    init(count: Int, timestamp: Date) {
        self.count = count
        self.timestamp = timestamp
    }
}
