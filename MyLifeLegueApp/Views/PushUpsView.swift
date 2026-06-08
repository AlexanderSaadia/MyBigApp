import SwiftUI
import SwiftData

// MARK: - Push-Ups Tracking View
// This view provides a specialized interface for logging push-up sets and visualizing them in a zigzag timeline.
struct PushUpsView: View {
    
    // MARK: - Environment & State
    
    // Access the database context to save entries.
    @Environment(\.modelContext) var modelContext
    
    // --- ARRAY / COLLECTION ---
    // DATA FLOW: Automatically fetches all PushUpEntry objects from the database.
    // The @Query macro keeps this array up-to-date in real-time.
    @Query(sort: \PushUpEntry.timestamp, order: .forward) var history: [PushUpEntry]
    
    // --- INPUT: User types their result here ---
    @State private var pushUpCount: String = ""
    
    // MARK: - Computed Properties
    
    // --- OUTPUT CALCULATION: Finds the scale for the chart ---
    private var maxCount: Int {
        var currentMax = 1
        // --- ARRAY ITERATION ---
        // Loops through history to find the record holder.
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
                    // --- INPUT: TextField ---
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
                    // OUTPUT: Empty state.
                    VStack(spacing: 10) {
                        Image(systemName: "figure.strengthtraining.functional")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No push-ups logged yet. Start today!")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    // OUTPUT: The zigzag chart.
                    GeometryReader { geometry in
                        let width = geometry.size.width - 60 
                        
                        VStack(alignment: .leading, spacing: 30) {
                            // --- ARRAY ITERATION (UI) ---
                            // Loops through history to create a vertical timeline of dots.
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
    
    // --- DATA FLOW: Creates a new record and saves it to disk ---
    private func logPushUps() {
        if let count = Int(pushUpCount) {
            // DATA FLOW: Create entry object.
            let newEntry = PushUpEntry(count: count, timestamp: Date())
            // INPUT -> DB: Insert into context.
            modelContext.insert(newEntry)
            
            // Ensure the entry is written to physical storage.
            try? modelContext.save()
            
            // Reset input field.
            pushUpCount = ""
            
            // UI ACTION: Hide keyboard.
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
        // OUTPUT: Horizontal position based on the record count.
        let currentX = (CGFloat(entry.count) / CGFloat(maxCount)) * availableWidth
        
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                if let previous = previousEntry {
                    let prevX = (CGFloat(previous.count) / CGFloat(maxCount)) * availableWidth
                    // OUTPUT: Drawing lines between points in history.
                    Path { path in
                        path.move(to: CGPoint(x: prevX + 6, y: -15))
                        path.addLine(to: CGPoint(x: currentX + 6, y: 15))
                    }
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                }
                
                // OUTPUT: The dot and data card for this set.
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
