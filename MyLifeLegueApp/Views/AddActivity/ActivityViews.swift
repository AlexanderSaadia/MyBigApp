import SwiftUI
import SwiftData

// MARK: - Activity Record Row Component
// This is the card-like view used in the "Stats" list to summarize a single activity.
struct ActivityRecordRow: View {
    // --- INPUT: A single activity object from an array ---
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // OUTPUT: Summary data.
            HStack {
                HStack(spacing: 12) {
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
                
                // OUTPUT: Points calculation from a math helper.
                let points = calculatePoints(for: activity)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(points) PTS")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
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
            
            // OUTPUT: Grid of secondary stats.
            HStack(spacing: 15) {
                SmallMetric(label: "REB", value: activity.rebounds)
                SmallMetric(label: "AST", value: activity.assists)
                SmallMetric(label: "STL", value: activity.steals)
                SmallMetric(label: "BLK", value: activity.blocks)
                
                Spacer()
                
                // OUTPUT: visual effort bar.
                VStack(alignment: .trailing, spacing: 4) {
                    Text("EFFORT")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 60, height: 4)
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
struct ActivityDetailView: View {
    // --- INPUT: Detailed activity data ---
    let activity: Activity
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // OUTPUT: Hero header.
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
                }
                
                // OUTPUT: Full statistics grid.
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
                
                // OUTPUT: Notes.
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
                
                // OUTPUT: Image viewer.
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
struct StatCounter: View {
    let label: String
    // --- INPUT: Bidirectional link to view state ---
    @Binding var value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 5) {
                // --- INPUT: Manual typing ---
                TextField("", text: $value)
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .frame(width: 60, height: 45)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // --- INPUT: Button adjustments ---
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
    
    // --- DATA FLOW: Logic to parse and update text-based numbers ---
    private func updateValue(by delta: Int) {
        let components = value.components(separatedBy: "/")
        if let firstPart = components.first, var made = Int(firstPart.trimmingCharacters(in: .whitespaces)) {
            made = max(0, made + delta)
            if components.count > 1 {
                value = "\(made)/\(components[1])"
            } else {
                value = "\(made)"
            }
        } else if value.isEmpty {
            value = "\(max(0, delta))"
        }
    }
}

// MARK: - Global Math Helpers
// DATA FLOW: Functions used across multiple arrays and views to process raw strings into numbers.

func calculatePoints(for activity: Activity) -> Int {
    let fgMade = parseStat(activity.fg)
    let threesMade = parseStat(activity.threes)
    let ftMade = parseStat(activity.ft)
    
    let twos = max(0, fgMade - threesMade)
    return (twos * 2) + (threesMade * 3) + ftMade
}

func parseStat(_ stat: String) -> Int {
    let components = stat.components(separatedBy: "/")
    if let first = components.first, let val = Int(first.trimmingCharacters(in: .whitespaces)) {
        return val
    }
    return 0
}

#Preview {
    ActivityRecordRow(activity: Activity(
        name: "Basketball Session",
        date: .now,
        symbol: "figure.basketball",
        effort: 85,
        fg: "5/10",
        threes: "2/4",
        rebounds: "5",
        assists: "3",
        isCompleted: true
    ))
    .padding()
}
