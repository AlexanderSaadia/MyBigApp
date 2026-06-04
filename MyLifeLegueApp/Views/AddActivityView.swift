import SwiftUI
import PhotosUI

struct AddActivityView: View {
    // MARK: - Stored properties
    
    @Environment(ActivityStore.self) private var activityStore
    
    // Basic Information
    @State private var name: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedSymbol: String = "basketball.fill"
    @State private var extra: String = ""
    
    // Photo Selection
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // Performance Statistics
    @State private var duration: Double = 60
    @State private var effort: Int = 50
    
    // Basketball Specific Stats (Changed to String)
    @State private var fg: String = "0"
    @State private var threes: String = "0"
    @State private var ft: String = "0"
    @State private var rebounds: String = "0"
    @State private var assists: String = "0"
    @State private var steals: String = "0"
    @State private var blocks: String = "0"
    
    private let symbols = ["basketball.fill", "sportscourt.fill", "figure.basketball", "figure.basketball.fill", "trophy.fill"]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                gameStatisticsSection
                extraNotesSection
                symbolSelectionSection
                addActivityButton
            }
            .navigationTitle("Add Activity")
        }
    }
    
    // MARK: - View Sections
    
    private var basicInfoSection: some View {
        Section(header: Text("Basic Info")) {
            TextField("Activity Name", text: $name)
            DatePicker("Date & Time", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
            
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
    }
    
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
    
    private var extraNotesSection: some View {
        Section(header: Text("Extra Notes")) {
            TextField("Enter details...", text: $extra, axis: .vertical)
                .lineLimit(3...5)
        }
    }
    
    private var symbolSelectionSection: some View {
        Section(header: Text("Symbol")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(symbols, id: \.self) { symbol in
                        Image(systemName: symbol)
                            .font(.title)
                            .padding(10)
                            .background(selectedSymbol == symbol ? Color.accentColor.opacity(0.2) : Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onTapGesture { selectedSymbol = symbol }
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }
    
    private var addActivityButton: some View {
        Button(action: addActivity) {
            Text("Add Activity")
                .frame(maxWidth: .infinity)
                .padding()
                .background(name.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(name.isEmpty)
    }
    
    // MARK: - Functions
    
    private func addActivity() {
        let newActivity = Activity(
            name: name, 
            date: selectedDate, 
            symbol: selectedSymbol,
            duration: duration,
            effort: effort,
            distance: 0.0,
            fg: fg,
            threes: threes,
            rebounds: rebounds,
            assists: assists,
            steals: steals,
            blocks: blocks,
            ft: ft,
            extra: extra,
            isCompleted: false,
            imageData: selectedImageData
        )
        
        activityStore.addActivity(newActivity)
        resetForm()
    }
    
    private func resetForm() {
        name = ""
        selectedDate = Date()
        selectedSymbol = "basketball.fill"
        duration = 60
        effort = 50
        fg = "0"
        threes = "0"
        rebounds = "0"
        assists = "0"
        steals = "0"
        blocks = "0"
        ft = "0"
        extra = ""
        selectedItem = nil
        selectedImageData = nil
    }
}

#Preview {
    AddActivityView()
        .environment(ActivityStore())
}
