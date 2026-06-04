import SwiftUI
import PhotosUI

// MARK: - Complete Activity View
// This view is shown when a user finishes a future activity.
// It allows them to fill in the final results (stats, photos, notes) before saving.
struct CompleteActivityView: View {
    
    // MARK: - Environment & State
    
    @Environment(ActivityStore.self) private var activityStore
    @Environment(\.dismiss) private var dismiss // Used to close the sheet.
    
    let activity: Activity // The activity being completed.
    
    // PERFORMANCE STATISTICS
    @State private var duration: Double = 60
    @State private var effort: Int = 50
    
    // BASKETBALL SPECIFIC STATS
    @State private var fg: String = "0"
    @State private var threes: String = "0"
    @State private var ft: String = "0"
    @State private var rebounds: String = "0"
    @State private var assists: String = "0"
    @State private var steals: String = "0"
    @State private var blocks: String = "0"
    
    // NOTES & PHOTO
    @State private var completionNote: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // MARK: - Initializer
    
    // The initializer pre-fills the form with any existing values from the activity.
    init(activity: Activity) {
        self.activity = activity
        
        // Initialize state variables using the activity's current data.
        _duration = State(initialValue: activity.duration > 0 ? activity.duration : 60)
        _effort = State(initialValue: activity.effort > 0 ? activity.effort : 50)
        _fg = State(initialValue: activity.fg)
        _threes = State(initialValue: activity.threes)
        _ft = State(initialValue: activity.ft)
        _rebounds = State(initialValue: activity.rebounds)
        _assists = State(initialValue: activity.assists)
        _steals = State(initialValue: activity.steals)
        _blocks = State(initialValue: activity.blocks)
        _completionNote = State(initialValue: activity.completionNote)
        _selectedImageData = State(initialValue: activity.imageData)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // TOP SECTION: Confirms which session the user is completing.
                Section(header: Text("Activity Summary")) {
                    HStack {
                        Image(systemName: activity.symbol)
                            .foregroundColor(.blue)
                        Text(activity.name)
                            .fontWeight(.bold)
                        Spacer()
                        Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // STATISTICS SECTION: Allows editing of results before final save.
                gameStatisticsSection
                
                // COMPLETION SECTION: Add final thoughts and an optional photo.
                Section(header: Text("Completion Details")) {
                    TextField("Add a completion note...", text: $completionNote, axis: .vertical)
                        .lineLimit(3...5)
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Label("Add Photo", systemImage: "photo")
                            Spacer()
                            // Show thumbnail of selected image.
                            if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            // Asynchronously load the selected image data.
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }
                
                // The confirmation button to mark the session as finished.
                completeButton
            }
            .navigationTitle("Complete Activity")
            .toolbar {
                // Allow user to close the form without saving.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - View Sections
    
    private var gameStatisticsSection: some View {
        Section(header: Text("Game Statistics")) {
            // Duration input.
            HStack {
                Text("Duration (mins)")
                Spacer()
                TextField("60", value: $duration, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 50)
                Stepper("", value: $duration, in: 0...300, step: 5)
                    .labelsHidden()
            }
            
            // Effort level input.
            VStack(alignment: .leading) {
                HStack {
                    Text("Effort Level")
                    Spacer()
                    Text("\(effort)%")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(get: { Double(effort) }, set: { effort = Int($0) }), in: 0...100)
            }
            
            // Horizontal grid of the specific basketball counters.
            statCountersScroll
        }
    }
    
    private var statCountersScroll: some View {
        let rows = [
            GridItem(.fixed(70)),
            GridItem(.fixed(70))
        ]
        
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 20) {
                // Link each counter to its corresponding state variable.
                StatCounter(label: "FG", value: $fg, color: .orange)
                StatCounter(label: "3s", value: $threes, color: .orange)
                StatCounter(label: "FT", value: $ft, color: .orange)
                StatCounter(label: "REB", value: $rebounds, color: .blue)
                StatCounter(label: "AST", value: $assists, color: .blue)
                StatCounter(label: "STL", value: $steals, color: .red)
                StatCounter(label: "BLK", value: $blocks, color: .red)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
        }
    }
    
    private var completeButton: some View {
        Button(action: completeActivity) {
            Text("Finish Activity")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    // MARK: - Functions
    
    // Updates the activity in the store with all the new stats and closes the sheet.
    private func completeActivity() {
        activityStore.updateAndCompleteActivity(
            activity,
            duration: duration,
            effort: effort,
            fg: fg,
            threes: threes,
            ft: ft,
            rebounds: rebounds,
            assists: assists,
            steals: steals,
            blocks: blocks,
            note: completionNote,
            imageData: selectedImageData
        )
        // Close the pop-up sheet.
        dismiss()
    }
}

// MARK: - Preview
#Preview {
    CompleteActivityView(activity: Activity(name: "Test", date: Date(), symbol: "basketball.fill"))
        .environment(ActivityStore())
}
