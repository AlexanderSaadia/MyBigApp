import SwiftUI

// MARK: - Push-Ups Tracking View
// This view provides a specialized interface for logging push-up sets and visualizing them in a zigzag timeline.
struct PushUpsView: View {
    
    // MARK: - State Properties
    
    // Tracks the user's text input for the current session.
    @State private var pushUpCount: String = ""
    
    // Local list of push-up sessions.
    @State private var history: [PushUpEntry] = []
    
    // MARK: - Computed Properties
    
    // Finds the highest number of push-ups ever logged to set the horizontal scale of the zigzag.
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
                    // Empty state.
                    VStack(spacing: 10) {
                        Image(systemName: "figure.strengthtraining.functional")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No push-ups logged yet. Start today!")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    // GeometryReader is used to calculate the available width for the zigzag.
                    GeometryReader { geometry in
                        let width = geometry.size.width - 60 // Padding adjustment.
                        
                        VStack(alignment: .leading, spacing: 30) {
                            ForEach(0..<history.count, id: \.self) { index in
                                let entry = history[index]
                                // Pass the previous entry so we can draw a line between them.
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
                    // Set a minimum height for the ScrollView content so it is scrollable.
                    .frame(minHeight: CGFloat(history.count * 80))
                }
            }
        }
    }
    
    // MARK: - Functions
    
    // Converts the text input to an integer and saves it to history.
    private func logPushUps() {
        if let count = Int(pushUpCount) {
            let newEntry = PushUpEntry(count: count, timestamp: Date())
            history.append(newEntry)
            pushUpCount = ""
            
            // Resign the keyboard after logging.
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Timeline Row Component
// This component draws a single dot and its connecting line in the zigzag pattern.
struct TimelineRow: View {
    let entry: PushUpEntry
    let previousEntry: PushUpEntry?
    let maxCount: Int
    let availableWidth: CGFloat
    
    var body: some View {
        // Calculate horizontal position: (current / max) * width.
        let currentX = (CGFloat(entry.count) / CGFloat(maxCount)) * availableWidth
        
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                // DRAWING THE LINE: Connects the previous dot to the current dot.
                if let previous = previousEntry {
                    let prevX = (CGFloat(previous.count) / CGFloat(maxCount)) * availableWidth
                    Path { path in
                        // Start point (relative to this row).
                        path.move(to: CGPoint(x: prevX + 6, y: -15))
                        // End point (at the center of the current dot).
                        path.addLine(to: CGPoint(x: currentX + 6, y: 15))
                    }
                    .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                }
                
                // THE DOT AND LABEL: The visual point representing the data.
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
                // Physically move the dot to its calculated X position.
                .offset(x: currentX)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PushUpsView()
}
