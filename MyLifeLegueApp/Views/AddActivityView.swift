import SwiftUI

struct AddActivityView: View {
    // MARK: - Stored properties
    
    @Environment(ActivityStore.self) private var activityStore
    
    @State private var name: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedSymbol: String = "basketball.fill"
    
    // --- New State for Basketball Statistics ---
    @State private var duration: Double = 60
    @State private var effort: Int = 50
    @State private var distance: Double = 0
    @State private var fg: Int = 0
    @State private var threes: Int = 0
    @State private var rebounds: Int = 0
    @State private var assists: Int = 0
    @State private var steals: Int = 0
    @State private var blocks: Int = 0
    @State private var ft: Int = 0
    @State private var extra: String = ""
    
    private let symbols = ["basketball.fill", "figure.basketball", "figure.walk", "figure.run", "book.fill", "gamecontroller.fill", "dumbbell", "figure.pool.swim"]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // SECTION 1: Identity
                Section(header: Text("Basic Info")) {
                    TextField("Activity Name", text: $name)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                }
                
                // SECTION 2: Basketball Statistics
                Section(header: Text("Game Statistics")) {
                    Stepper("Duration: \(Int(duration)) mins", value: $duration, in: 0...300, step: 5)
                    
                    VStack(alignment: .leading) {
                        Text("Effort Level: \(effort)%")
                        Slider(value: Binding(get: { Double(effort) }, set: { effort = Int($0) }), in: 0...100)
                    }
                    
                    Stepper("Distance: \(String(format: "%.1f", distance)) km", value: $distance, in: 0...50, step: 0.5)
                    
                    // Visual Counters for quick entry
                    VStack(spacing: 15) {
                        HStack {
                            StatCounter(label: "FG", value: $fg, color: .orange)
                            StatCounter(label: "3s", value: $threes, color: .orange)
                            StatCounter(label: "FT", value: $ft, color: .orange)
                        }
                        
                        HStack {
                            StatCounter(label: "REB", value: $rebounds, color: .blue)
                            StatCounter(label: "AST", value: $assists, color: .blue)
                            StatCounter(label: "STL", value: $steals, color: .red)
                            StatCounter(label: "BLK", value: $blocks, color: .red)
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                Section(header: Text("Extra Notes")) {
                    TextField("Enter details...", text: $extra, axis: .vertical)
                        .lineLimit(3...5)
                }
                
                // SECTION 3: Visuals
                Section(header: Text("Symbol")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(symbols, id: \.self) { symbol in
                                Image(systemName: symbol)
                                    .font(.title)
                                    .padding(10)
                                    .background(selectedSymbol == symbol ? Color.accentColor.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        selectedSymbol = symbol
                                    }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
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
            .navigationTitle("Add Activity")
        }
    }
    
    // MARK: - Functions
    
    private func addActivity() {
        // We now include the new stats in the activity creation
        let newActivity = Activity(
            name: name, 
            date: selectedDate, 
            symbol: selectedSymbol,
            duration: duration,
            effort: effort,
            distance: distance,
            fg: fg,
            threes: threes,
            rebounds: rebounds,
            assists: assists,
            steals: steals,
            blocks: blocks,
            ft: ft,
            extra: extra,
            isCompleted: false // New activities start as unconfirmed
        )
        
        activityStore.addActivity(newActivity)
        
        // Reset the form
        name = ""
        duration = 60
        effort = 50
        distance = 0
        fg = 0
        threes = 0
        rebounds = 0
        assists = 0
        steals = 0
        blocks = 0
        ft = 0
        extra = ""
    }
}

// Custom view for stat counters that shows the number prominently
struct StatCounter: View {
    let label: String
    @Binding var value: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .frame(width: 45, height: 45)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            HStack(spacing: 10) {
                Button(action: { if value > 0 { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.secondary)
                }
                Button(action: { value += 1 }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(color)
                }
            }
            .font(.title3)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AddActivityView()
        .environment(ActivityStore())
}
