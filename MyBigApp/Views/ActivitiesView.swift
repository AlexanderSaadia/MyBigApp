//
//  HomeView.swift
//  MyBigApp
//
//  Created by Alexander Saadia on 02/03/26.
//

import SwiftUI

struct ActivitiesView: View {
    var body: some View {
        VStack {
            
            HStack {
                Text ("Activities")
                    .font(.system(size: 21.0, weight: .regular, design: .default))
                Spacer()
            }
            
            VStack {
                ActivityView(activity: "Running", timesWeekly: "2/7 this week", percentage: "29%", symbol: "figure.run")
                
                ActivityView(activity: "Video Games", timesWeekly: "1/7 this week", percentage: "7%", symbol: "gamecontroller.fill")
                
                ActivityView(activity: "Skiing", timesWeekly: "2/7 this week", percentage: "14%", symbol: "figure.skiing.downhill")
                
                ActivityView(activity: "Skating", timesWeekly: "1/7 this week", percentage: "7%", symbol: "figure.skating")
                
                ActivityView(activity: "Basketball", timesWeekly: "1/7 this week", percentage: "90%", symbol: "basketball.fill")
                
                ActivityView(activity: "Walking", timesWeekly: "7/7 this week", percentage: "100%", symbol: "figure.walk")
                
                ActivityView(activity: "GYM", timesWeekly: "7/7 this week", percentage: "100%", symbol: "dumbbell")
                
                ActivityView(activity: "Swimming", timesWeekly: "3/7 this week", percentage: "30%", symbol: "figure.pool.swim")
                
                ActivityView(activity: "Studying", timesWeekly: "6/7 this week", percentage: "92%", symbol: "book.fill")
                
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        
                        (Image(systemName: "chevron.backward"))
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

