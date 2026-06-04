import SwiftUI
import SwiftData

// MARK: - Push-Ups Tracking View
// This view provides a specialized interface for logging push-up sets and visualizing them in a zigzag timeline.
struct PushUpsView: View {
    
    // MARK: - Environment & State
    
    // Access the database context to save entries.
    @Environment(\.modelContext) var modelContext
    
    // Query existing pushup history from SwiftData.
    @Query(sort: \PushUpEntry.timestamp, order: .forward) var history: [PushUpEntry]
    
    // Tracks the user's text input for the current session.
    @State private var pushUpCount: String = ""
    
    // MARK: - Computed Properties
    
    // Finds the highest number of push-ups ever logged to set the horizontal scale.
    private var maxCount: Int {
        var currentMax = 1
        for entry in history {
            if entry.count > currentMax {
                currentMax = entry.count
            }
        }
        return currentMax
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            
            // INPUT SECTION: Where the user types their result.
            VStack(spacing: 12) {
                Text("How many push-ups did you do?")
                    .font(.headline)
                
                HStack {
                    TextField("0", text: $pushUpCount)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                        .frame(width: 100)
                    
                    Button(action: logPushUps) {
                        Text("Log Session")
                            .fontWeight(.bold)
                            .padding()
                            .background(pushUpCount.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(pushUpCount.isEmpty)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(15)
            .padding(.horizontal)
            
            Divider()
            
            // TIMELINE SECTION: The visual zigzag progress chart.
            ScrollView {
                if history.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "figure.strengthtraining.functional")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No push-ups logged yet. Start today!")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    GeometryReader { geometry in
                        let width = geometry.size.width - 60 
                        
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(0..<history.count, id: \.self) { index in
                                let entry = history[index]
                                let previousEntry = index > 0 ? history[index-1] : nil
                                
                                TimelineRow(
                                    entry: entry, 
                                    previousEntry: previousEntry,
                                    maxCount: maxCount,
                                    availableWidth: width
                                )
                            }
                        }
                    }
                    .padding()
                    .frame(minHeight: CGFloat(history.count * 80))
                }
            }
        }
    }
    
    // MARK: - Functions
    
    // Saves a new entry to the SwiftData database.
    private func logPushUps() {
        if let count = Int(pushUpCount) {
            // Create a new model object.
            let newEntry = PushUpEntry(count: count, timestamp: Date())
            // Insert it into the database context.
            modelContext.insert(newEntry)
            
            pushUpCount = ""
            
            // Hide keyboard.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Timeline Row Component
struct TimelineRow: View {
    let entry: PushUpEntry
    let previousEntry: PushUpEntry?
    let maxCount: Int
    let availableWidth: CGFloat
    
    var body: some View {
        let currentX = (CGFloat(entry.count) / CGFloat(maxCount)) * availableWidth
        
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                if let previous = previousEntry {
                    let prevX = (CGFloat(previous.count) / CGFloat(maxCount)) * availableWidth
                    Path { path in
                        path.move(to: CGPoint(x: prevX + 6, y: -15))
                        path.addLine(to: CGPoint(x: currentX + 6, y: 15))
                    }
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                }
                
                HStack(alignment: .center, spacing: 10) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                        .shadow(radius: 2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("\(entry.count)")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text("Push-ups")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 2)
                }
                .offset(x: currentX)
            }
        }
    }
}

#Preview {
    PushUpsView()
        .modelContainer(for: PushUpEntry.self, inMemory: true)
}
