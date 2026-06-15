import Foundation
import SwiftData

// MARK: - Journal Entry Model
// This defines the structure of a single "Journal Entry" in our app.
// We use @Model so SwiftData can automatically save and load these objects.
@Model
final class JournalEntry: Identifiable {
    // A unique identifier for every journal entry created.
    @Attribute(.unique) var id: UUID = UUID()
    
    // --- STORED DATA ---
    
    // The date and time when the journal entry was created.
    var date: Date
    
    // The text content of the journal entry.
    var content: String
    
    // A rating for the day from 1 to 10.
    var rating: Int
    
    // A boolean indicating if the day was a "Thumbs Up" (true) or "Thumbs Down" (false).
    var isThumbsUp: Bool
    
    // MARK: - Initializer
    // DATA FLOW: This initializer is the entry point for creating new journal entries.
    init(
        date: Date = Date(),
        content: String = "",
        rating: Int = 5,
        isThumbsUp: Bool = true
    ) {
        self.date = date
        self.content = content
        self.rating = rating
        self.isThumbsUp = isThumbsUp
    }
}
