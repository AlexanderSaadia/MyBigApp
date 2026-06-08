import SwiftUI

// MARK: - Journal View
// This view acts as a personal reflection space for the user.
// Currently, it acts as a placeholder for future diary/note-taking features.
struct JournalView: View {
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header text.
                Text("Journal")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                
                // Visual decorative icon.
                Image(systemName: "book.pages")
                    .font(.system(size: 100))
                    .foregroundColor(.blue.opacity(0.3))
                    .padding()
                
                // Informational text.
                Text("Your personal reflection space.")
                    .foregroundColor(.secondary)
            }
            // Set the navigation title.
            .navigationTitle("Journal")
        }
    }
}

// MARK: - Preview
#Preview {
    JournalView()
}
