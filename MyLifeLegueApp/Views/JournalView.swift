import SwiftUI

struct JournalView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Journal")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                
                Image(systemName: "book.pages")
                    .font(.system(size: 100))
                    .foregroundColor(.blue.opacity(0.3))
                    .padding()
                
                Text("Your personal reflection space.")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Journal")
        }
    }
}

#Preview {
    JournalView()
        .environment(ActivityStore())
}
