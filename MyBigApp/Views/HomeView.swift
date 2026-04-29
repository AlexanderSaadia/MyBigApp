import SwiftUI

struct HomeView: View {
    @State private var selection = 1
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    ZStack {
                        Circle()
                    }
                    .containerRelativeFrame(.horizontal, count: 5, span: 1, spacing: 0)
                    
                    Text ("Alexander Saadia")
                    
                    Spacer()
                }
                
                VStack {
                    Rectangle()
                        .fill(Color.blue)
                        .overlay {
                            VStack {
                                HStack {
                                    Text ("Activities Complited")
                                    
                                    Spacer()
                                    
                                    Text ("View Stats")
                                }
                                Spacer()
                                
                                Circle()
                                    .aspectRatio(2.0/1.0, contentMode: .fit)
                            }
                            
                            
                            
                        }
                }
                .containerRelativeFrame(.vertical, count: 7, span: 2, spacing: 0)
                
                Spacer()
                
                Text ("Todays Activities")
                
                List {
                    VStack {
                        MainActivityView(activity: "Running", checkmark: true)
                        MainActivityView(activity: "Basketball", checkmark: true)
                        MainActivityView(activity: "Meditating ", checkmark: true)
                        
                    
                    }
                }
                .listStyle(.plain)
            }
            
           
            
            Text ("Goals")
            
            Rectangle()
                .fill(.yellow)
                .overlay {
                    VStack{
                        
                        Picker ("Current Selection", selection: $selection) {
                            Text ("Daily") .tag("Daily")
                            Text ("Weekly") .tag("Weekly")
                            Text ("Monthly") .tag("Monthly")
                            Text ("Yearly") .tag("Yearly")
                        }
                        .pickerStyle(.segmented)
                        
                        Spacer()
                        
                        HStack {
                            Text ("Goals...")
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    
                }
        }
        
    }
    
}
#Preview {
    PickerView()
}

struct MainActivityView: View {
    
    let activity: String
    let checkmark: Bool
    
    var body: some View {
        HStack {
            Text (activity)
            
            Spacer()
            
            VStack(alignment: .trailing){
                Text("\(Image(systemName: checkmark ? "checkmark.circle.fill" : "checkmark.circle  "))")
                    .foregroundStyle(.green)
            }
        }
    }
}
