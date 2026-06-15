import Foundation
import SwiftData

// MARK: - User Profile Model
// This defines the structure of the user's profile in the app.
@Model
final class UserProfile: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    
    // --- STORED DATA ---
    var name: String
    var bio: String
    var avatarData: Data?
    
    // MARK: - Initializer
    init(name: String = "New User", bio: String = "") {
        self.name = name
        self.bio = bio
    }
}
