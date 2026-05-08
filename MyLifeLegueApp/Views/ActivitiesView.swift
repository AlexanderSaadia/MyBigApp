//
//  HomeView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct ActivitiesView: View {
    // MARK: - Stored properties
    @Environment(ActivityStore.self) private var activityStore
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                Text ("Activities")
                    .font(.system(size: 21.0, weight: .regular, design: .default))
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(activityStore.activities) { activity in
                        ActivityView(activity: activity.name, 
                                     timesWeekly: "Added on " + activity.date.formatted(date: .abbreviated, time: .omitted), 
                                     percentage: "", 
                                     symbol: activity.symbol)
                    }
                }
                .padding()
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Back action handled by PickerView state
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
            }
        }
    }
}



#Preview {
    PickerView()
}

struct ActivityView: View {
    
    let activity: String
    let timesWeekly: String
    let percentage: String
    let symbol: String
    
    var body: some View {
        
        Rectangle()
            .fill(.gray)
            .overlay {
                
                HStack {
                    
                    Image(systemName: symbol)
                        .font(.system(size: 25.0))

                    
                    VStack(alignment: .leading){
                        Text(activity)
                            .font(.system(size: 25.0, weight: .semibold, design: .default))
                        Text(timesWeekly)
                    }
                    
                    Spacer()
                    
                    Text(percentage)
                        .foregroundStyle(.green)
                }
                .padding(8)
            }
    }
}

