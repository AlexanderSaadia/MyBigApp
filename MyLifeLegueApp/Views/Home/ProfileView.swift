import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Profile View
// This view displays and allows editing of the user's profile and progress.
struct ProfileView: View {
    
    // MARK: - Environment
    @Environment(ActivityStore.self) private var activityStore
    
    // MARK: - State Properties
    @State private var isEditing = false
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // MARK: - Profile Header
                profileHeader
                
                // MARK: - Progress Stats
                progressStats
                
                // MARK: - Bio Section
                bioSection
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveProfile()
                    }
                    isEditing.toggle()
                }
            }
        }
        .onAppear {
            if let profile = activityStore.userProfile {
                name = profile.name
                bio = profile.bio
                selectedImageData = profile.avatarData
            }
        }
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var profileHeader: some View {
        VStack(spacing: 15) {
            ZStack(alignment: .bottomTrailing) {
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                }
                
                if isEditing {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
            
            if isEditing {
                TextField("Name", text: $name)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(name)
                    .font(.title2)
                    .bold()
            }
        }
    }
    
    private var progressStats: some View {
        HStack(spacing: 20) {
            StatBox(title: "Total Activities", value: "\(activityStore.activities.filter { $0.isCompleted }.count)", color: .blue)
            StatBox(title: "Journals", value: "\(activityStore.journalEntries.count)", color: .purple)
        }
    }
    
    private var bioSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("About Me")
                .font(.headline)
            
            if isEditing {
                TextEditor(text: $bio)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 10))
            } else {
                Text(bio.isEmpty ? "No bio yet." : bio)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.secondary.opacity(0.05))
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Functions
    
    private func saveProfile() {
        if let profile = activityStore.userProfile {
            profile.name = name
            profile.bio = bio
            profile.avatarData = selectedImageData
            activityStore.save()
        }
    }
}

// MARK: - Supporting Views

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .bold()
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(.rect(cornerRadius: 15))
    }
}

// MARK: - Preview
#Preview {
    ProfileView()
        .environment(ActivityStore.preview)
}
