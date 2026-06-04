import SwiftUI

// MARK: - Activity Record Row Component
// This is the card-like view used in the "Stats" list to summarize a single activity.
struct ActivityRecordRow: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // TOP ROW: Icon, Name, Date, and Points.
            HStack {
                HStack(spacing: 12) {
                    // Rounded background for the activity symbol.
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 40, height: 40)
                        Image(systemName: activity.symbol)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.name)
                            .font(.headline)
                        Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Display the calculated total points for this session.
                let points = calculatePoints(for: activity)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(points) PTS")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    // Show a "Confirmed" badge if the activity is marked as completed.
                    if activity.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Confirmed")
                        }
                        .font(.caption2)
                        .foregroundColor(.green)
                    }
                }
            }
            
            // BOTTOM ROW: A horizontal grid of secondary stats (Rebounds, Assists, etc).
            HStack(spacing: 15) {
                SmallMetric(label: "REB", value: activity.rebounds)
                SmallMetric(label: "AST", value: activity.assists)
                SmallMetric(label: "STL", value: activity.steals)
                SmallMetric(label: "BLK", value: activity.blocks)
                
                Spacer()
                
                // EFFORT BAR: A small visual progress bar representing the effort percentage.
                VStack(alignment: .trailing, spacing: 4) {
                    Text("EFFORT")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .leading) {
                        // The gray background track.
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 60, height: 4)
                        // The blue progress indicator (scaled by effort/100).
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: CGFloat(activity.effort) * 0.6, height: 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Small Metric Component
// A simple vertical layout for displaying a label and a value (e.g., REB 5).
struct SmallMetric: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Activity Detail View
// The full-screen page that opens when you tap an activity in the list.
struct ActivityDetailView: View {
    let activity: Activity
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // HERO SECTION: Large icon and name.
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: activity.symbol)
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                }
                .padding(.top)
                
                VStack(spacing: 5) {
                    Text(activity.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(activity.date.formatted(date: .complete, time: .shortened))
                        .foregroundColor(.secondary)
                    
                    if activity.isCompleted {
                        Label("Confirmed", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.top, 5)
                    }
                }
                
                // STATS GRID: Detailed metric boxes for every recorded value.
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        DetailStatBox(label: "Effort", value: "\(activity.effort)%", icon: "bolt.fill", color: .yellow)
                        DetailStatBox(label: "Distance", value: String(format: "%.1fkm", activity.distance), icon: "figure.walk", color: .green)
                    }
                    
                    HStack(spacing: 20) {
                        DetailStatBox(label: "FG", value: activity.fg, icon: "target", color: .orange)
                        DetailStatBox(label: "3s", value: activity.threes, icon: "3.circle", color: .orange)
                        DetailStatBox(label: "FT", value: activity.ft, icon: "1.circle", color: .orange)
                    }
                    
                    HStack(spacing: 20) {
                        DetailStatBox(label: "REB", value: activity.rebounds, icon: "arrow.up.and.down.circle", color: .blue)
                        DetailStatBox(label: "AST", value: activity.assists, icon: "person.2.fill", color: .blue)
                    }
                    
                    HStack(spacing: 20) {
                        DetailStatBox(label: "STL", value: activity.steals, icon: "hand.raised.fill", color: .red)
                        DetailStatBox(label: "BLK", value: activity.blocks, icon: "hand.wave.fill", color: .red)
                    }
                }
                .padding(.horizontal)
                
                // NOTES SECTION: Displays both initial details and completion notes.
                if !activity.extra.isEmpty || !activity.completionNote.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.headline)
                        
                        if !activity.extra.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Activity Details:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(activity.extra)
                                    .font(.body)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        if !activity.completionNote.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Completion Note:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(activity.completionNote)
                                    .font(.body)
                                    .italic()
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // PHOTO SECTION: If a photo was saved, it is displayed here at full width.
                if let imageData = activity.imageData, let uiImage = UIImage(data: imageData) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Photo")
                            .font(.headline)
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Activity Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Detail Stat Box Component
// A reusable component for the statistics grid in the detail view.
struct DetailStatBox: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Stat Counter Component
// This is the custom input field used in Add and Complete views.
// It supports text entry (like "3/9") while still allowing the Stepper to work.
struct StatCounter: View {
    let label: String
    @Binding var value: String // Bound to the activity's string property.
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 5) {
                // TextField allows manual typing of fractions or special characters.
                TextField("", text: $value)
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .frame(width: 60, height: 45)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Stepper allows quick +1 or -1 adjustments.
                Stepper("", onIncrement: {
                    updateValue(by: 1)
                }, onDecrement: {
                    updateValue(by: -1)
                })
                .labelsHidden()
                .controlSize(.small)
            }
        }
    }
    
    // Logic to increment the first part of a fraction (the "made" shots).
    private func updateValue(by delta: Int) {
        // Split the string by the "/" character if it exists.
        let components = value.components(separatedBy: "/")
        if let firstPart = components.first, var made = Int(firstPart.trimmingCharacters(in: .whitespaces)) {
            // Update the count, preventing it from going below zero.
            made = max(0, made + delta)
            if components.count > 1 {
                // If it was a fraction (e.g., "3/9"), reassemble it with the updated numerator.
                value = "\(made)/\(components[1])"
            } else {
                // If it was just a number, update it.
                value = "\(made)"
            }
        } else if value.isEmpty {
            // Default to the increment value if the field was empty.
            value = "\(max(0, delta))"
        }
    }
}

// MARK: - Global Math Helpers
// These functions are available to any view in the app.

// Calculates the total basketball points (2s, 3s, FTs).
func calculatePoints(for activity: Activity) -> Int {
    let fgMade = parseStat(activity.fg)
    let threesMade = parseStat(activity.threes)
    let ftMade = parseStat(activity.ft)
    
    // Calculate 2-pointers by subtracting 3s from total Field Goals.
    let twos = max(0, fgMade - threesMade)
    return (twos * 2) + (threesMade * 3) + ftMade
}

// Helper to extract the first integer from a string like "3/9" or "10".
func parseStat(_ stat: String) -> Int {
    let components = stat.components(separatedBy: "/")
    if let first = components.first, let val = Int(first.trimmingCharacters(in: .whitespaces)) {
        return val
    }
    return 0
}
