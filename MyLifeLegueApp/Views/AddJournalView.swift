import SwiftUI
import SwiftData

// MARK: - Add Journal View
// This view allows the user to create a new journal entry with a rating and sentiment.
struct AddJournalView: View {
    
    // MARK: - Environment
    
    @Environment(ActivityStore.self) private var activityStore
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State Properties
    
    @State private var date: Date = Date()
    @State private var content: String = ""
    @State private var rating: Int = 5
    @State private var isThumbsUp: Bool = true
    @State private var hasSaved: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reflection") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                        .overlay(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("How was your day?")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 8)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                
                Section("Rating & Sentiment") {
                    HStack {
                        Text("Day Rating")
                        Spacer()
                        Text("\(rating)/10")
                            .bold()
                            .foregroundStyle(.purple)
                    }
                    
                    Slider(value: Binding(
                        get: { Double(rating) },
                        set: { rating = Int($0) }
                    ), in: 1...10, step: 1)
                    .tint(.purple)
                    
                    Picker("Sentiment", selection: $isThumbsUp) {
                        Image(systemName: "hand.thumbsup.fill")
                            .tag(true)
                        Image(systemName: "hand.thumbsdown.fill")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(content.isEmpty)
                    .bold()
                }
            }
            .sensoryFeedback(.success, trigger: hasSaved)
        }
    }
    
    // MARK: - Functions
    
    private func saveEntry() {
        let newEntry = JournalEntry(
            date: date,
            content: content,
            rating: rating,
            isThumbsUp: isThumbsUp
        )
        activityStore.addJournalEntry(newEntry)
        hasSaved = true
        
        // Provide a small delay for haptics before dismissing.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
        }
    }
}

// MARK: - Preview
#Preview {
    AddJournalView()
        .environment(ActivityStore.preview)
}
