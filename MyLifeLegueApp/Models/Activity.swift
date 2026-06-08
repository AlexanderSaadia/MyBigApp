import Foundation
import SwiftData

// MARK: - Activity Model
// This defines the structure of a single "Activity" in our app.
// We added @Model so SwiftData can automatically save and load these objects.
@Model
final class Activity: Identifiable {
    // A unique identifier for every activity created.
    @Attribute(.unique) var id: UUID = UUID()
    
    // --- INPUT FIELDS (Stored Data) ---
    // These properties store the data that comes from user input forms.
    
    // The display name of the activity.
    var name: String
    
    // The date and time when the activity is scheduled or happened.
    var date: Date
    
    // An SF Symbol name used to represent this activity visually.
    var symbol: String
    
    // --- STATISTICS INPUTS ---
    
    // The total time spent on the activity in minutes.
    var duration: Double = 0
    
    // A percentage value (0-100) representing how hard the user worked.
    var effort: Int = 0
    
    // The physical distance covered during the activity in kilometers.
    var distance: Double = 0
    
    // Field Goals: Stored as a string to allow formats like "5/10".
    var fg: String = "0"
    
    // Three-pointers.
    var threes: String = "0"
    
    // Rebounds.
    var rebounds: String = "0"
    
    // Assists.
    var assists: String = "0"
    
    // Steals.
    var steals: String = "0"
    
    // Blocks.
    var blocks: String = "0"
    
    // Free Throws.
    var ft: String = "0"
    
    // Initial extra details.
    var extra: String = ""
    
    // Status flag (Input from completion toggle).
    var isCompleted: Bool = false
    
    // Goal flag (Distinguishes between a plan and a target).
    var isGoal: Bool = false
    
    // Binary data for a photo (Input from PhotosPicker).
    @Attribute(.externalStorage) var imageData: Data? = nil
    
    // Note added during completion.
    var completionNote: String = ""
    
    // MARK: - Initializer
    // DATA FLOW: This initializer is the entry point for creating new activity data.
    init(
        name: String,
        date: Date,
        symbol: String,
        duration: Double = 0,
        effort: Int = 0,
        distance: Double = 0,
        fg: String = "0",
        threes: String = "0",
        rebounds: String = "0",
        assists: String = "0",
        steals: String = "0",
        blocks: String = "0",
        ft: String = "0",
        extra: String = "",
        isCompleted: Bool = false,
        isGoal: Bool = false,
        imageData: Data? = nil,
        completionNote: String = ""
    ) {
        self.name = name
        self.date = date
        self.symbol = symbol
        self.duration = duration
        self.effort = effort
        self.distance = distance
        self.fg = fg
        self.threes = threes
        self.rebounds = rebounds
        self.assists = assists
        self.steals = steals
        self.blocks = blocks
        self.ft = ft
        self.extra = extra
        self.isCompleted = isCompleted
        self.isGoal = isGoal
        self.imageData = imageData
        self.completionNote = completionNote
    }
}
