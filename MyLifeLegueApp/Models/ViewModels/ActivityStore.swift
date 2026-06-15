import Foundation
import SwiftData
import Observation

// MARK: - ActivityStore ViewModel
// This class manages the entire list of activities and goals for the application.
// We updated it to sync with SwiftData so data is saved permanently.
@MainActor
@Observable
class ActivityStore {
    
    // MARK: - Properties
    
    // The SwiftData context used for saving and deleting.
    private var modelContext: ModelContext?
    
    // --- ARRAY / COLLECTION ---
    // This is the master list where ALL activities and goals are kept.
    // DATA FLOW: It is populated from the database and used by all Views to display information.
    var activities: [Activity] = []
    
    // The master list of all journal entries.
    var journalEntries: [JournalEntry] = []
    
    // The user's profile.
    var userProfile: UserProfile?
    
    // MARK: - Initializer
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        // If we have a context, fetch the existing data.
        if modelContext != nil {
            fetchActivities()
            fetchJournalEntries()
            fetchUserProfile()
        }
    }
    
    // MARK: - Methods
    
    // DATA FLOW: This method ensures that all temporary changes are written to the physical disk.
    func save() {
        guard let context = modelContext else { 
            print("Warning: Attempted to save with nil context.")
            return 
        }
        do {
            try context.save()
            // Update local arrays after save to keep the UI in sync.
            let activityDescriptor = FetchDescriptor<Activity>(sortBy: [SortDescriptor(\.date)])
            self.activities = try context.fetch(activityDescriptor)
            
            let journalDescriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
            self.journalEntries = try context.fetch(journalDescriptor)
            
            fetchUserProfile()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // Connects the store to the app's database.
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchActivities()
        fetchJournalEntries()
        fetchUserProfile()
        // Run cleanup once when the context is first connected.
        cleanupOldUncompletedActivities()
    }
    
    // Loads the user profile from the database.
    func fetchUserProfile() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try context.fetch(descriptor)
            if let firstProfile = profiles.first {
                self.userProfile = firstProfile
            } else {
                // Create a default profile if none exists.
                let defaultProfile = UserProfile(name: "Alexander Saadia", bio: "Starting my journey.")
                context.insert(defaultProfile)
                save()
                self.userProfile = defaultProfile
            }
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }
    
    // Loads all activities from the SwiftData database into our local array.
    func fetchActivities() {
        guard let context = modelContext else { return }
        
        // --- ARRAY ITERATION (Internal) ---
        // We query the database to get everything, sorted by date.
        let descriptor = FetchDescriptor<Activity>(sortBy: [SortDescriptor(\.date)])
        
        do {
            // Update our local master list.
            self.activities = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch activities: \(error)")
        }
    }
    
    // Loads all journal entries from the database.
    func fetchJournalEntries() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            self.journalEntries = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch journal entries: \(error)")
        }
    }
    
    // Removes activities that were planned for the past but never marked as completed.
    func cleanupOldUncompletedActivities() {
        guard let context = modelContext else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var deletedAny = false
        // --- ARRAY ITERATION ---
        // We loop through the master list to find "stale" activities.
        for activity in activities {
            let activityDate = calendar.startOfDay(for: activity.date)
            
            // If it's old and not finished, delete it from the database.
            if activityDate < today && !activity.isCompleted {
                context.delete(activity)
                deletedAny = true
            }
        }
        
        // Only trigger a save if we actually deleted something.
        if deletedAny {
            save()
        }
    }
    
    // --- INPUT HANDLER ---
    // DATA FLOW: Takes a new Activity object and adds it to the persistent database.
    func addActivity(_ activity: Activity) {
        guard let context = modelContext else { 
            print("Error: Cannot add activity, context is nil.")
            self.activities.append(activity)
            return 
        }
        context.insert(activity)
        save()
    }
    
    // --- INPUT HANDLER ---
    // Updates a specific activity's completion status.
    func toggleCompletion(for activity: Activity) {
        activity.isCompleted.toggle()
        save()
    }
    
    // --- INPUT HANDLER ---
    // Finalizes an activity with a note and photo.
    func completeActivity(_ activity: Activity, note: String = "", imageData: Data? = nil) {
        activity.isCompleted = true
        activity.completionNote = note
        activity.imageData = imageData
        save()
    }
    
    // --- INPUT HANDLER (Batch Update) ---
    // Updates all performance metrics at once.
    func updateAndCompleteActivity(
        _ activity: Activity, 
        duration: Double, 
        effort: Int, 
        fg: String, 
        threes: String, 
        ft: String, 
        rebounds: String, 
        assists: String, 
        steals: String, 
        blocks: String, 
        note: String, 
        imageData: Data?
    ) {
        activity.isCompleted = true
        activity.duration = duration
        activity.effort = effort
        activity.fg = fg
        activity.threes = threes
        activity.ft = ft
        activity.rebounds = rebounds
        activity.assists = assists
        activity.steals = steals
        activity.blocks = blocks
        activity.completionNote = note
        activity.imageData = imageData
        save()
    }
    
    // Removes an activity forever.
    func deleteActivity(_ activity: Activity) {
        guard let context = modelContext else { return }
        context.delete(activity)
        save()
    }
    
    // --- INPUT HANDLER ---
    // Adds a new journal entry.
    func addJournalEntry(_ entry: JournalEntry) {
        guard let context = modelContext else {
            self.journalEntries.insert(entry, at: 0)
            return
        }
        context.insert(entry)
        save()
    }
    
    // Removes a journal entry.
    func deleteJournalEntry(_ entry: JournalEntry) {
        guard let context = modelContext else { return }
        context.delete(entry)
        save()
    }
    
    // MARK: - Preview Helper
    static let previewContainer: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Activity.self, PushUpEntry.self, JournalEntry.self, UserProfile.self, configurations: config)
    }()
    
    static let preview: ActivityStore = {
        let store = ActivityStore()
        store.setContext(previewContainer.mainContext)
        return store
    }()
    
    // --- OUTPUT HELPER ---
    // DATA FLOW: Filters the master list to show only items for a specific date.
    func activities(for date: Date) -> [Activity] {
        var result: [Activity] = []
        let calendar = Calendar.current
        // --- ARRAY ITERATION ---
        for activity in activities {
            if calendar.isDate(activity.date, inSameDayAs: date) {
                result.append(activity)
            }
        }
        return result
    }
    
    // Finds a journal entry for a specific date.
    func journalEntry(for date: Date) -> JournalEntry? {
        let calendar = Calendar.current
        for entry in journalEntries {
            if calendar.isDate(entry.date, inSameDayAs: date) {
                return entry
            }
        }
        return nil
    }
}
