import SwiftUI

struct AddActivityView: View {
    // MARK: - Stored properties
    
    @Environment(ActivityStore.self) private var activityStore
    
    @State private var name: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedSymbol: String = "figure.walk"
    
    // --- New State for Statistics ---
    @State private var duration: Double = 30 // Default to 30 mins
    @State private var calories: Int = 100
    @State private var qualityScore: Int = 50
    
    private let symbols = ["figure.walk", "figure.run", "book.fill", "gamecontroller.fill", "basketball.fill", "dumbbell", "figure.pool.swim"]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // SECTION 1: Identity
                Section(header: Text("Basic Info")) {
                    TextField("Activity Name", text: $name)
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                }
                
                // SECTION 2: Statistics (The "Playground" data)
                Section(header: Text("Statistics / Metrics")) {
                    // Stepper is great for precise increments
                    Stepper("Duration: \(Int(duration)) mins", value: $duration, in: 5...300, step: 5)
                    
                    // A slider is good for broad estimates
                    VStack(alignment: .leading) {
                        Text("Est. Calories: \(calories)")
                        Slider(value: Binding(get: { Double(calories) }, set: { calories = Int($0) }), in: 0...1000, step: 10)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Quality / Effort Score: \(qualityScore)%")
                        Slider(value: Binding(get: { Double(qualityScore) }, set: { qualityScore = Int($0) }), in: 0...100)
                    }
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
            calories: calories,
            qualityScore: qualityScore
        )
        
        activityStore.addActivity(newActivity)
        
        // Reset the form
        name = ""
        duration = 30
        calories = 100
        qualityScore = 50
    }
}

#Preview {
    AddActivityView()
        .environment(ActivityStore())
}
