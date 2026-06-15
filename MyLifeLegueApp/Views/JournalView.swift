import SwiftUI
import SwiftData

// MARK: - Journal View
// This view displays a list of daily reflections and allows adding new ones.
struct JournalView: View {
    
    // MARK: - Environment
    
    @Environment(ActivityStore.self) private var activityStore
    
    // MARK: - State Properties
    
    @State private var showingAddSheet = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if activityStore.journalEntries.isEmpty {
                    ContentUnavailableView(
                        "No Journal Entries",
                        systemImage: "pencil.and.list.clipboard",
                        description: Text("Start capturing your daily reflections and ratings.")
                    )
                } else {
                    List {
                        ForEach(activityStore.journalEntries) { entry in
                            JournalEntryCard(entry: entry)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Entry", systemImage: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddJournalView()
            }
        }
    }
    
    // MARK: - Functions
    
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = activityStore.journalEntries[index]
            activityStore.deleteJournalEntry(entry)
        }
    }
}

// MARK: - Journal Entry Card
struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Image(systemName: entry.isThumbsUp ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                        .foregroundStyle(entry.isThumbsUp ? .green : .red)
                        .font(.title3)
                    
                    Text("\(entry.rating)")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(ratingColor(entry.rating))
                        .clipShape(Circle())
                }
            }
            
            Text(entry.content)
                .font(.body)
                .lineLimit(3)
                .foregroundStyle(.primary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .clipShape(.rect(cornerRadius: 16))
    }
    
    private func ratingColor(_ rating: Int) -> Color {
        switch rating {
        case 8...10: return .green
        case 5...7: return .blue
        case 3...4: return .orange
        default: return .red
        }
    }
}

// MARK: - Preview
#Preview {
    let store = ActivityStore.preview
    store.addJournalEntry(JournalEntry(content: "Today was a great day! I finished my project and went for a run.", rating: 9, isThumbsUp: true))
    store.addJournalEntry(JournalEntry(content: "A bit slow today, but I got some reading done.", rating: 5, isThumbsUp: true))
    
    return JournalView()
        .environment(store)
}
