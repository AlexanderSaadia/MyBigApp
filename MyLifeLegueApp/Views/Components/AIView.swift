import SwiftUI

// MARK: - AI Insights View
// This view is designed to provide automated feedback on the user's progress.
// Currently, it serves as a placeholder for future machine-learning features.
struct AIView: View {
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            // Header icon and title.
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.purple)
            
            Text("AI Training Coach")
                .font(.title)
                .fontWeight(.bold)
            
            // Description of future functionality.
            Text("Analyzing your performance to provide customized training advice.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            // Decorative background card.
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.purple.opacity(0.1))
                .frame(height: 100)
                .overlay {
                    Text("Coming Soon...")
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                .padding()
        }
        .navigationTitle("Insights")
    }
}

// MARK: - Preview
#Preview {
    AIView()
}
