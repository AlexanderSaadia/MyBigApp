import SwiftUI

// MARK: - Data Model for a single push-up entry
struct PushUpEntry: Identifiable, Codable {
    var id = UUID()
    var count: Int
    var timestamp: Date
}

// MARK: - Main Push-Ups View
struct PushUpsView: View {
    // MARK: - Stored properties
    
    // Tracks the current input number
    @State private var pushUpCount: String = ""
    
    // The list of all push-up sessions
    // In a full app, this would be moved to ActivityStore for persistence
    @State private var history: [PushUpEntry] = []
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            
            // INPUT SECTION
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
            
            // TIMELINE SECTION
            // Explain: Displays push-up history in a vertical timeline format
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
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(history.reversed()) { entry in
                            TimelineRow(entry: entry, isLast: entry.id == history.first?.id)
                        }
                    }
                    .padding()
                }
            }
        }
        // Explain: Title is now managed by the parent NavigationStack in PickerView
    }
    
    // MARK: - Functions
    
    // Explain: Saves the new push-up count and clears the input
    private func logPushUps() {
        if let count = Int(pushUpCount) {
            let newEntry = PushUpEntry(count: count, timestamp: Date())
            history.append(newEntry)
            pushUpCount = ""
            
            // Hide keyboard
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Timeline Sub-component
struct TimelineRow: View {
    let entry: PushUpEntry
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // THE VERTICAL LINE & DOT
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            
            // THE CONTENT
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(entry.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Push-ups")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
                    .frame(height: 20)
            }
        }
    }
}

#Preview {
    PushUpsView()
}
