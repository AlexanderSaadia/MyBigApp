import SwiftUI
import PhotosUI

struct CompleteActivityView: View {
    // MARK: - Stored properties
    
    @Environment(ActivityStore.self) private var activityStore
    @Environment(\.dismiss) private var dismiss
    
    let activity: Activity
    
    // Performance Statistics
    @State private var duration: Double = 60
    @State private var effort: Int = 50
    
    // Basketball Specific Stats
    @State private var fg: Int = 0
    @State private var threes: Int = 0
    @State private var ft: Int = 0
    @State private var rebounds: Int = 0
    @State private var assists: Int = 0
    @State private var steals: Int = 0
    @State private var blocks: Int = 0
    
    // Notes & Photo
    @State private var completionNote: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // MARK: - Initializer
    init(activity: Activity) {
        self.activity = activity
        // Note: Initializing states with activity values if they exist
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
                
                gameStatisticsSection
                
                Section(header: Text("Completion Details")) {
                    TextField("Add a completion note...", text: $completionNote, axis: .vertical)
                        .lineLimit(3...5)
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Label("Add Photo", systemImage: "photo")
                            Spacer()
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
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                }
                
                completeButton
            }
            .navigationTitle("Complete Activity")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - View Sections
    
    private var gameStatisticsSection: some View {
        Section(header: Text("Game Statistics")) {
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
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Effort Level")
                    Spacer()
                    Text("\(effort)%")
                        .foregroundColor(.secondary)
                }
                Slider(value: Binding(get: { Double(effort) }, set: { effort = Int($0) }), in: 0...100)
            }
            
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
        dismiss()
    }
}

#Preview {
    CompleteActivityView(activity: Activity(name: "Test", date: Date(), symbol: "basketball.fill"))
        .environment(ActivityStore())
}
